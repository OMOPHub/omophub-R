#' Check if Error is Transient (Retryable)
#'
#' @param resp An httr2 response object.
#' @returns `TRUE` if the error is transient and should be retried.
#' @keywords internal
is_transient_error <- function(resp) {
  status <- httr2::resp_status(resp)
  status %in% c(429L, 500L, 502L, 503L, 504L)
}

#' Extract Error Message from API Response
#'
#' @param resp An httr2 response object.
#' @returns A character string with the error message.
#' @keywords internal
extract_error_message <- function(resp) {
  tryCatch(
    {
      body <- httr2::resp_body_json(resp)
      # Try different error message locations
      msg <- body$error$message %||%
        body$message %||%
        body$detail %||%
        body$error %||%
        "Unknown API error"
      as.character(msg)
    },
    error = function(e) {
      paste("HTTP", httr2::resp_status(resp), "error")
    }
  )
}

#' Parse the OMOPHub Error Envelope
#'
#' The API answers failures with
#' `{"success": false, "error": {"code", "message", "details"}, "meta": {"request_id"}}`.
#' Anything else (an HTML page from a proxy, an empty body) degrades to a
#' status-only message rather than failing inside the error path.
#'
#' @param resp An httr2 response object.
#' @returns A list with `message`, `error_code`, `details`, and `request_id`
#'   (each possibly `NULL` except `message`).
#' @keywords internal
parse_error_body <- function(resp) {
  status <- httr2::resp_status(resp)
  body <- tryCatch(httr2::resp_body_json(resp), error = function(e) NULL)

  error <- if (is.list(body)) body$error else NULL
  if (is.character(error)) {
    error <- list(message = error)
  }
  if (!is.list(error)) {
    error <- list()
  }

  message <- error$message %||%
    (if (is.list(body)) body$message %||% body$detail) %||%
    paste("HTTP", status, "error")

  request_id <- httr2::resp_header(resp, "x-request-id")
  if (is.null(request_id) && is.list(body) && is.list(body$meta)) {
    request_id <- body$meta$request_id
  }
  # The server fills a missing request id with the literal "unknown".
  if (identical(request_id, "unknown")) {
    request_id <- NULL
  }

  list(
    message = as.character(message)[[1]],
    error_code = error$code,
    details = error$details,
    request_id = request_id
  )
}

#' Abort with OMOPHub API Error
#'
#' @param status HTTP status code.
#' @param message Error message.
#' @param endpoint API endpoint that failed.
#' @param error_code The server's `error.code`, if any.
#' @param details The server's `error.details`, if any.
#' @param request_id The request ID, if any.
#' @param class Additional condition classes, most specific first. They are
#'   placed ahead of `omophub_api_error`.
#' @param hint Optional extra `i` bullet for the message.
#' @param ... Additional fields stored on the condition.
#' @param call The calling environment.
#' @keywords internal
abort_api_error <- function(status, message, endpoint, error_code = NULL,
                            details = NULL, request_id = NULL, class = NULL,
                            hint = NULL, ..., call = rlang::caller_env()) {
  bullets <- c(
    glue::glue("OMOPHub API error ({status})"),
    "x" = message,
    "i" = glue::glue("Endpoint: {endpoint}")
  )
  if (!is.null(error_code)) {
    bullets <- c(bullets, "i" = glue::glue("Error code: {error_code}"))
  }
  if (!is.null(request_id)) {
    bullets <- c(bullets, "i" = glue::glue("Request ID: {request_id}"))
  }
  if (!is.null(hint)) {
    bullets <- c(bullets, "i" = hint)
  }

  rlang::abort(
    message = bullets,
    class = c(class, "omophub_api_error", "omophub_error"),
    status = status,
    status_code = status,
    endpoint = endpoint,
    error_code = error_code,
    details = details,
    request_id = request_id,
    ...,
    call = call
  )
}

#' Abort with the OMOPHub Condition for an HTTP Error Response
#'
#' Maps a failed response to the documented condition hierarchy:
#'
#' * 400 → `omophub_validation_error`
#' * 401, or `error.code` `invalid_api_key` / `missing_api_key` →
#'   `omophub_auth_error`
#' * 403 → `omophub_forbidden_error` (valid key, but not permitted)
#' * 404 → `omophub_not_found`
#' * 429 → `omophub_rate_limit_error` (with `retry_after`)
#' * 5xx → `omophub_server_error`
#' * anything else → `omophub_api_error`
#'
#' Every class inherits from `omophub_api_error` and `omophub_error`. The
#' condition also keeps httr2's own classes (`httr2_http_<status>`,
#' `httr2_http`, `httr2_error`) and `resp`, so handlers written against the
#' httr2 conditions keep working.
#'
#' @param resp The failed httr2 response.
#' @param endpoint API endpoint that failed.
#' @param call The calling environment.
#' @keywords internal
abort_http_error <- function(resp, endpoint, call = rlang::caller_env()) {
  status <- httr2::resp_status(resp)
  parsed <- parse_error_body(resp)
  code <- parsed$error_code

  retry_after <- NULL
  hint <- NULL
  class <- if (identical(code, "invalid_api_key") ||
               identical(code, "missing_api_key") ||
               status == 401L) {
    hint <- "Check your API key with `get_api_key()`."
    "omophub_auth_error"
  } else if (status == 400L) {
    "omophub_validation_error"
  } else if (status == 403L) {
    hint <- "The API key is valid but is not permitted to access this resource."
    "omophub_forbidden_error"
  } else if (status == 404L) {
    "omophub_not_found"
  } else if (status == 429L) {
    retry_after <- suppressWarnings(
      as.numeric(httr2::resp_header(resp, "retry-after"))
    )
    if (length(retry_after) == 0 || is.na(retry_after)) {
      retry_after <- NULL
    }
    "omophub_rate_limit_error"
  } else if (status >= 500L) {
    "omophub_server_error"
  } else {
    NULL
  }

  abort_api_error(
    status = status,
    message = parsed$message,
    endpoint = endpoint,
    error_code = code,
    details = parsed$details,
    request_id = parsed$request_id,
    class = c(class, paste0("httr2_http_", status), "httr2_http", "httr2_error"),
    hint = hint,
    retry_after = retry_after,
    resp = resp,
    call = call
  )
}

#' Abort with Connection Error
#'
#' @param parent The underlying `httr2_failure` condition.
#' @param endpoint API endpoint that was being requested.
#' @param call The calling environment.
#' @keywords internal
abort_connection_error <- function(parent, endpoint, call = rlang::caller_env()) {
  rlang::abort(
    message = c(
      "Could not reach the OMOPHub API",
      "i" = glue::glue("Endpoint: {endpoint}")
    ),
    class = c("omophub_connection_error", "omophub_error", "httr2_failure", "httr2_error"),
    endpoint = endpoint,
    parent = parent,
    call = call
  )
}

#' Abort with Authentication Error
#'
#' @param message Error message.
#' @param call The calling environment.
#' @keywords internal
abort_auth_error <- function(message, call = rlang::caller_env()) {
  rlang::abort(
    message = c(
      "OMOPHub authentication failed",
      "x" = message,
      "i" = "Check your API key with {.fun get_api_key}"
    ),
    class = c("omophub_auth_error", "omophub_error"),
    call = call
  )
}

#' Abort with Rate Limit Error
#'
#' @param retry_after Seconds until rate limit resets.
#' @param call The calling environment.
#' @keywords internal
abort_rate_limit <- function(retry_after = NULL, call = rlang::caller_env()) {
  msg <- "Rate limit exceeded"
  if (!is.null(retry_after)) {
    msg <- c(msg, "i" = glue::glue("Retry after {retry_after} seconds"))
  }
  rlang::abort(
    message = c("OMOPHub rate limit exceeded", "x" = msg),
    class = c("omophub_rate_limit_error", "omophub_error"),
    retry_after = retry_after,
    call = call
  )
}

#' Abort with Validation Error
#'
#' @param message Error message.
#' @param arg The argument that failed validation.
#' @param call The calling environment.
#' @keywords internal
abort_validation <- function(message, arg = NULL, call = rlang::caller_env()) {
  msg_parts <- "Invalid input"
  if (!is.null(arg)) {
    msg_parts <- c(msg_parts, "x" = glue::glue("Argument: {arg}"))
  }
  msg_parts <- c(msg_parts, "x" = message)

  rlang::abort(
    message = msg_parts,
    class = c("omophub_validation_error", "omophub_error"),
    arg = arg,
    call = call
  )
}

# Null coalescing operator (not exported, no Rd file)
# @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Convert Boolean to API String
#'
#' @param x A logical value.
#' @returns "true" or "false" string, or NULL if x is NULL.
#' @keywords internal
bool_to_str <- function(x) {
  if (is.null(x)) return(NULL)
  if (isTRUE(x)) "true" else "false"
}

#' Join List Elements for Query Parameter
#'
#' @param x A character vector.
#' @param sep Separator (default comma).
#' @returns A single comma-separated string, or NULL if x is NULL/empty.
#' @keywords internal
join_params <- function(x, sep = ",") {
  if (is.null(x) || length(x) == 0) return(NULL)
  paste(x, collapse = sep)
}

#' Validate Concept ID
#'
#' @param concept_id A concept ID to validate.
#' @param arg Argument name for error messages.
#' @param call The calling environment.
#' @keywords internal
validate_concept_id <- function(concept_id, arg = "concept_id", call = rlang::caller_env()) {
  if (!checkmate::test_integerish(concept_id, len = 1, lower = 1)) {
    abort_validation(
      "Must be a positive integer",
      arg = arg,
      call = call
    )
  }
  as.integer(concept_id)
}

#' Validate Page Parameters
#'
#' @param page Page number.
#' @param page_size Page size.
#' @param max_page_size Maximum allowed page size.
#' @param call The calling environment.
#' @keywords internal
validate_pagination <- function(page, page_size, max_page_size = 1000, call = rlang::caller_env()) {
  if (!checkmate::test_integerish(page, len = 1, lower = 1)) {
    abort_validation("Must be a positive integer", arg = "page", call = call)
  }
  if (!checkmate::test_integerish(page_size, len = 1, lower = 1, upper = max_page_size)) {
    abort_validation(
      glue::glue("Must be between 1 and {max_page_size}"),
      arg = "page_size",
      call = call
    )
  }
  list(page = as.integer(page), page_size = as.integer(page_size))
}
