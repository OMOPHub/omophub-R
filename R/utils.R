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

#' Abort with OMOPHub API Error
#'
#' @param status HTTP status code.
#' @param message Error message.
#' @param endpoint API endpoint that failed.
#' @param call The calling environment.
#' @keywords internal
abort_api_error <- function(status, message, endpoint, call = rlang::caller_env()) {
  rlang::abort(
    message = c(
      glue::glue("OMOPHub API error ({status})"),
      "x" = message,
      "i" = glue::glue("Endpoint: {endpoint}")
    ),
    class = c("omophub_api_error", "omophub_error"),
    status = status,
    endpoint = endpoint,
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
