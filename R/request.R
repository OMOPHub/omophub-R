#' Build Base OMOPHub Request
#'
#' @description
#' Creates an httr2 request object with authentication, rate limiting,
#' and retry logic configured.
#'
#' @param base_url API base URL.
#' @param api_key API key for authentication.
#' @param timeout Request timeout in seconds.
#' @param max_retries Maximum retry attempts.
#' @param vocab_version Optional vocabulary version.
#'
#' @returns An httr2 request object.
#' @keywords internal
build_request <- function(base_url, api_key, timeout = 30, max_retries = 3,
                          vocab_version = NULL) {
  req <- httr2::request(base_url) |>
    httr2::req_headers(
      "Authorization" = paste("Bearer", api_key),
      "Content-Type" = "application/json",
      "Accept" = "application/json"
    ) |>
    httr2::req_user_agent(paste0("OMOPHub-SDK-R/", utils::packageVersion("omophub"))) |>
    httr2::req_timeout(timeout) |>
    httr2::req_throttle(
      rate = .omophub_env$rate_limit_capacity / .omophub_env$rate_limit_fill_time
    ) |>
    httr2::req_retry(
      max_tries = max_retries,
      is_transient = is_transient_error
    ) |>
    httr2::req_error(body = extract_error_message)

  # Add vocabulary version header if specified
  if (!is.null(vocab_version)) {
    req <- httr2::req_headers(req, "X-Vocabulary-Version" = vocab_version)
  }

  req
}

#' Perform GET Request
#'
#' @param base_req Base request object.
#' @param endpoint API endpoint path.
#' @param query Named list of query parameters.
#'
#' @returns Parsed JSON response. For paginated endpoints, returns a list with
#'   `data` (the results) and `meta` (pagination info). For single-item endpoints,
#'   returns the unwrapped data directly.
#' @keywords internal
perform_get <- function(base_req, endpoint, query = NULL) {
  req <- base_req |>
    httr2::req_url_path_append(endpoint)

  # Add query parameters, removing NULLs
  if (!is.null(query)) {
    query <- Filter(Negate(is.null), query)
    if (length(query) > 0) {
      req <- httr2::req_url_query(req, !!!query)
    }
  }

  resp <- httr2::req_perform(req)
  body <- httr2::resp_body_json(resp)

  # Check if response has pagination info - if so, preserve structure for pagination
  if (is.list(body) && "meta" %in% names(body) && "data" %in% names(body)) {
    meta <- body$meta
    has_pagination <- !is.null(meta$pagination) ||
                      !is.null(meta$page) ||
                      !is.null(meta$total_pages) ||
                      !is.null(meta$has_next)

    if (has_pagination) {
      # Return with pagination structure preserved
      return(list(
        data = body$data,
        meta = meta$pagination %||% meta
      ))
    }
    # No pagination - unwrap to just data
    return(body$data)
  }

  body
}

#' Perform POST Request
#'
#' @param base_req Base request object.
#' @param endpoint API endpoint path.
#' @param body Named list for JSON body.
#' @param query Named list of query parameters.
#' @param preserve_pagination If `TRUE`, copy `meta$pagination` from the
#'   response envelope onto the returned list as a `pagination` element.
#'   Paginated POST endpoints carry their pagination in `meta` while the results
#'   sit in `data`, so unwrapping to `data` alone leaves the caller with a
#'   `page` argument and no way to know whether another page exists. Added as an
#'   element rather than changing the return shape, so existing accessors keep
#'   working.
#'
#' @returns Parsed JSON response (unwrapped from `data` field if present).
#' @keywords internal
perform_post <- function(base_req, endpoint, body = NULL, query = NULL,
                         preserve_pagination = FALSE) {
  req <- base_req |>
    httr2::req_url_path_append(endpoint) |>
    httr2::req_method("POST")

  # Add query parameters, removing NULLs
  if (!is.null(query)) {
    query <- Filter(Negate(is.null), query)
    if (length(query) > 0) {
      req <- httr2::req_url_query(req, !!!query)
    }
  }

  # Add JSON body
  if (!is.null(body)) {
    body <- Filter(Negate(is.null), body)
    req <- httr2::req_body_json(req, body)
  }

  resp <- httr2::req_perform(req)
  resp_body <- httr2::resp_body_json(resp)

  # Unwrap data field if present (matching Python SDK behavior)
  if (is.list(resp_body) && "data" %in% names(resp_body)) {
    if (isTRUE(preserve_pagination)) {
      pagination <- resp_body$meta$pagination
      if (!is.null(pagination)) {
        data <- resp_body$data
        if (is.list(data)) {
          data$pagination <- pagination
          return(data)
        }
      }
    }
    return(resp_body$data)
  }
  resp_body
}
