# HTTP failures must surface as the documented omophub_* condition classes
# (see abort_http_error()), not only as httr2's generic httr2_http_* ones.

error_response <- function(status, code = NULL, message = "Something went wrong",
                           details = NULL, request_id = "req-123",
                           headers = list()) {
  body <- list(
    success = FALSE,
    error = Filter(Negate(is.null), list(code = code, message = message, details = details)),
    meta = list(request_id = request_id)
  )
  httr2::response(
    status_code = status,
    headers = c(list("Content-Type" = "application/json"), headers),
    body = charToRaw(as.character(jsonlite::toJSON(body, auto_unbox = TRUE, null = "null")))
  )
}

# The real client request, minus retries so 429/5xx don't back off in tests.
test_request <- function() {
  omophub:::build_request(
    base_url = "https://api.omophub.com/v1",
    api_key = "oh_test",
    max_retries = 1
  )
}

capture_get_error <- function(resp, endpoint = "concepts/201826") {
  httr2::local_mocked_responses(function(req) resp)
  rlang::catch_cnd(omophub:::perform_get(test_request(), endpoint), classes = "error")
}

capture_post_error <- function(resp, endpoint = "search/bulk") {
  httr2::local_mocked_responses(function(req) resp)
  rlang::catch_cnd(
    omophub:::perform_post(test_request(), endpoint, body = list(searches = list())),
    classes = "error"
  )
}

test_that("400 validation_error raises omophub_validation_error", {
  err <- capture_get_error(error_response(
    400, "validation_error", "page_size must be <= 1000",
    details = list(field = "page_size")
  ))

  expect_s3_class(err, "omophub_validation_error")
  expect_s3_class(err, "omophub_api_error")
  expect_s3_class(err, "omophub_error")
  expect_equal(err$status, 400)
  expect_equal(err$status_code, 400)
  expect_equal(err$error_code, "validation_error")
  expect_equal(err$details, list(field = "page_size"))
  expect_equal(err$request_id, "req-123")
  expect_equal(err$endpoint, "concepts/201826")
  expect_match(conditionMessage(err), "page_size must be <= 1000", fixed = TRUE)
})

test_that("401 invalid_api_key raises omophub_auth_error", {
  err <- capture_get_error(error_response(401, "invalid_api_key", "Invalid API key"))

  expect_s3_class(err, "omophub_auth_error")
  expect_s3_class(err, "omophub_api_error")
  expect_s3_class(err, "omophub_error")
  expect_equal(err$error_code, "invalid_api_key")
  expect_equal(err$status_code, 401)
  expect_match(conditionMessage(err), "Invalid API key", fixed = TRUE)
})

test_that("401 missing_api_key raises omophub_auth_error", {
  err <- capture_get_error(error_response(401, "missing_api_key", "API key required"))

  expect_s3_class(err, "omophub_auth_error")
  expect_equal(err$error_code, "missing_api_key")
})

test_that("an API-key error code maps to omophub_auth_error regardless of status", {
  err <- capture_get_error(error_response(403, "invalid_api_key", "Key revoked"))

  expect_s3_class(err, "omophub_auth_error")
  expect_false(inherits(err, "omophub_forbidden_error"))
})

test_that("403 is distinct from invalid credentials", {
  err <- capture_get_error(error_response(403, "forbidden", "Vocabulary restricted"))

  expect_s3_class(err, "omophub_forbidden_error")
  expect_s3_class(err, "omophub_api_error")
  expect_false(inherits(err, "omophub_auth_error"))
  expect_equal(err$error_code, "forbidden")
})

test_that("404 raises omophub_not_found", {
  err <- capture_get_error(error_response(404, "not_found", "Concept not found"))

  expect_s3_class(err, "omophub_not_found")
  expect_s3_class(err, "omophub_api_error")
})

test_that("429 raises omophub_rate_limit_error with retry_after", {
  err <- capture_get_error(error_response(
    429, "rate_limit_exceeded", "Too many requests",
    headers = list("Retry-After" = "7")
  ))

  expect_s3_class(err, "omophub_rate_limit_error")
  expect_s3_class(err, "omophub_api_error")
  expect_equal(err$retry_after, 7)
})

test_that("429 without Retry-After leaves retry_after NULL", {
  err <- capture_get_error(error_response(429, "rate_limit_exceeded"))

  expect_s3_class(err, "omophub_rate_limit_error")
  expect_null(err$retry_after)
})

test_that("5xx raises omophub_server_error", {
  err <- capture_get_error(error_response(503, "service_unavailable", "Down"))

  expect_s3_class(err, "omophub_server_error")
  expect_s3_class(err, "omophub_api_error")
  expect_equal(err$status_code, 503)
})

test_that("unmapped 4xx raises plain omophub_api_error", {
  err <- capture_get_error(error_response(409, "conflict", "Conflict"))

  expect_s3_class(err, "omophub_api_error")
  for (cls in c("omophub_validation_error", "omophub_auth_error",
                "omophub_forbidden_error", "omophub_not_found",
                "omophub_rate_limit_error", "omophub_server_error")) {
    expect_false(inherits(err, cls))
  }
})

test_that("httr2 condition classes and resp are preserved for existing handlers", {
  err <- capture_get_error(error_response(404, "not_found"))

  expect_s3_class(err, "httr2_http_404")
  expect_s3_class(err, "httr2_http")
  expect_s3_class(err, "httr2_error")
  expect_s3_class(err$resp, "httr2_response")
})

test_that("X-Request-Id header takes precedence over meta.request_id", {
  err <- capture_get_error(error_response(
    400, "validation_error",
    request_id = "from-body",
    headers = list("X-Request-Id" = "from-header")
  ))

  expect_equal(err$request_id, "from-header")
  expect_match(conditionMessage(err), "from-header", fixed = TRUE)
})

test_that("the server's 'unknown' request id placeholder is dropped", {
  err <- capture_get_error(error_response(400, "validation_error", request_id = "unknown"))

  expect_null(err$request_id)
})

test_that("non-JSON error bodies still map by status", {
  resp <- httr2::response(
    status_code = 502,
    headers = list("Content-Type" = "text/html"),
    body = charToRaw("<html>Bad gateway</html>")
  )
  err <- capture_get_error(resp)

  expect_s3_class(err, "omophub_server_error")
  expect_null(err$error_code)
  expect_match(conditionMessage(err), "HTTP 502 error", fixed = TRUE)
})

test_that("perform_post maps errors the same way", {
  err <- capture_post_error(error_response(400, "validation_error", "searches is required"))

  expect_s3_class(err, "omophub_validation_error")
  expect_s3_class(err, "omophub_api_error")
  expect_equal(err$endpoint, "search/bulk")
})

test_that("transport failures raise omophub_connection_error", {
  httr2::local_mocked_responses(function(req) {
    rlang::abort("Could not resolve host", class = c("httr2_failure", "httr2_error"))
  })
  err <- rlang::catch_cnd(
    omophub:::perform_get(test_request(), "concepts/201826"),
    classes = "error"
  )

  expect_s3_class(err, "omophub_connection_error")
  expect_s3_class(err, "omophub_error")
  expect_s3_class(err, "httr2_failure")
  expect_false(inherits(err, "omophub_api_error"))
})

test_that("resource methods surface the mapped class to callers", {
  httr2::local_mocked_responses(function(req) {
    error_response(401, "invalid_api_key", "Invalid API key")
  })
  client <- OMOPHubClient$new(api_key = "oh_test", max_retries = 1)

  expect_error(client$concepts$get(201826), class = "omophub_auth_error")
})
