test_that("bool_to_str converts booleans correctly", {
  expect_equal(omophub:::bool_to_str(TRUE), "true")
  expect_equal(omophub:::bool_to_str(FALSE), "false")
  expect_null(omophub:::bool_to_str(NULL))
})

test_that("join_params joins vectors correctly", {
  expect_equal(omophub:::join_params(c("a", "b", "c")), "a,b,c")
  expect_equal(omophub:::join_params(c("SNOMED", "ICD10CM")), "SNOMED,ICD10CM")
  expect_null(omophub:::join_params(NULL))
  expect_null(omophub:::join_params(character(0)))
})

test_that("validate_concept_id accepts valid IDs", {
  expect_equal(omophub:::validate_concept_id(201826), 201826L)
  expect_equal(omophub:::validate_concept_id(1L), 1L)
})

test_that("validate_concept_id rejects invalid IDs", {
  expect_error(omophub:::validate_concept_id(0), "positive integer")
  expect_error(omophub:::validate_concept_id(-1), "positive integer")
  expect_error(omophub:::validate_concept_id("abc"), "positive integer")
  expect_error(omophub:::validate_concept_id(c(1, 2)), "positive integer")
})

test_that("validate_pagination accepts valid params", {
  result <- omophub:::validate_pagination(1, 20)
  expect_equal(result$page, 1L)
  expect_equal(result$page_size, 20L)
})

test_that("validate_pagination rejects invalid params", {
  expect_error(omophub:::validate_pagination(0, 20), "positive integer")
  expect_error(omophub:::validate_pagination(1, 0), "between 1 and")
  expect_error(omophub:::validate_pagination(1, 2000), "between 1 and")
})

test_that("null coalescing operator works", {
  # Use rlang's %||% as our internal one is not exported
  # This test verifies the basic behavior
  expect_equal(rlang::`%||%`(NULL, "default"), "default")
  expect_equal(rlang::`%||%`("value", "default"), "value")
  expect_equal(rlang::`%||%`(0, "default"), 0)
  expect_equal(rlang::`%||%`("", "default"), "")
})

# ==============================================================================
# is_transient_error() tests
# ==============================================================================

test_that("is_transient_error returns TRUE for retryable status codes", {
  # Create mock responses with different status codes
  local_mocked_bindings(
    resp_status = function(resp) resp$status_code,
    .package = "httr2"
  )

  mock_resp <- function(status) list(status_code = status)

  expect_true(omophub:::is_transient_error(mock_resp(429L)))  # Rate limit
  expect_true(omophub:::is_transient_error(mock_resp(500L)))  # Internal server error
  expect_true(omophub:::is_transient_error(mock_resp(502L)))  # Bad gateway
  expect_true(omophub:::is_transient_error(mock_resp(503L)))  # Service unavailable
  expect_true(omophub:::is_transient_error(mock_resp(504L)))  # Gateway timeout
})

test_that("is_transient_error returns FALSE for non-retryable status codes", {
  local_mocked_bindings(
    resp_status = function(resp) resp$status_code,
    .package = "httr2"
  )

  mock_resp <- function(status) list(status_code = status)

  expect_false(omophub:::is_transient_error(mock_resp(200L)))  # Success
  expect_false(omophub:::is_transient_error(mock_resp(400L)))  # Bad request
  expect_false(omophub:::is_transient_error(mock_resp(401L)))  # Unauthorized
  expect_false(omophub:::is_transient_error(mock_resp(403L)))  # Forbidden
  expect_false(omophub:::is_transient_error(mock_resp(404L)))  # Not found
  expect_false(omophub:::is_transient_error(mock_resp(422L)))  # Validation error
})

# ==============================================================================
# extract_error_message() tests
# ==============================================================================

test_that("extract_error_message extracts error.message", {
  local_mocked_bindings(
    resp_body_json = function(resp) list(error = list(message = "Detailed error message")),
    resp_status = function(resp) 400L,
    .package = "httr2"
  )

  result <- omophub:::extract_error_message(list())
  expect_equal(result, "Detailed error message")
})

test_that("extract_error_message extracts message field", {
  local_mocked_bindings(
    resp_body_json = function(resp) list(message = "Simple message"),
    resp_status = function(resp) 400L,
    .package = "httr2"
  )

  result <- omophub:::extract_error_message(list())
  expect_equal(result, "Simple message")
})

test_that("extract_error_message extracts detail field", {
  local_mocked_bindings(
    resp_body_json = function(resp) list(detail = "Detail message"),
    resp_status = function(resp) 400L,
    .package = "httr2"
  )

  result <- omophub:::extract_error_message(list())
  expect_equal(result, "Detail message")
})

test_that("extract_error_message handles error as object with message", {
  # When error is an object with a message field
  local_mocked_bindings(
    resp_body_json = function(resp) list(error = list(message = "Nested error message")),
    resp_status = function(resp) 400L,
    .package = "httr2"
  )

  result <- omophub:::extract_error_message(list())
  expect_equal(result, "Nested error message")
})

test_that("extract_error_message returns Unknown API error when no message found", {
  local_mocked_bindings(
    resp_body_json = function(resp) list(status = "failed"),
    resp_status = function(resp) 400L,
    .package = "httr2"
  )

  result <- omophub:::extract_error_message(list())
  expect_equal(result, "Unknown API error")
})

test_that("extract_error_message handles JSON parse failure", {
  local_mocked_bindings(
    resp_body_json = function(resp) stop("JSON parse error"),
    resp_status = function(resp) 500L,
    .package = "httr2"
  )

  result <- omophub:::extract_error_message(list())
  expect_equal(result, "HTTP 500 error")
})

# ==============================================================================
# abort_api_error() tests
# ==============================================================================

test_that("abort_api_error throws error with correct class", {
  err <- rlang::catch_cnd(
    omophub:::abort_api_error(404, "Not found", "/concepts/999")
  )

  expect_s3_class(err, "omophub_api_error")
  expect_s3_class(err, "omophub_error")
})

test_that("abort_api_error includes status and endpoint", {
  err <- rlang::catch_cnd(
    omophub:::abort_api_error(400, "Invalid request", "/search")
  )

  expect_equal(err$status, 400)
  expect_equal(err$endpoint, "/search")
})

test_that("abort_api_error message includes status code", {
  expect_error(
    omophub:::abort_api_error(404, "Resource not found", "/test"),
    "404"
  )
})

# ==============================================================================
# abort_auth_error() tests
# ==============================================================================

test_that("abort_auth_error throws error with correct class", {
  err <- rlang::catch_cnd(
    omophub:::abort_auth_error("Invalid API key")
  )

  expect_s3_class(err, "omophub_auth_error")
  expect_s3_class(err, "omophub_error")
})

test_that("abort_auth_error mentions authentication", {
  expect_error(
    omophub:::abort_auth_error("Invalid key"),
    "authentication"
  )
})

# ==============================================================================
# abort_rate_limit() tests
# ==============================================================================

test_that("abort_rate_limit throws error with correct class", {
  err <- rlang::catch_cnd(
    omophub:::abort_rate_limit(60)
  )

  expect_s3_class(err, "omophub_rate_limit_error")
  expect_s3_class(err, "omophub_error")
})

test_that("abort_rate_limit includes retry_after when provided", {
  err <- rlang::catch_cnd(
    omophub:::abort_rate_limit(60)
  )

  expect_equal(err$retry_after, 60)
})

test_that("abort_rate_limit works without retry_after", {
  err <- rlang::catch_cnd(
    omophub:::abort_rate_limit()
  )

  expect_null(err$retry_after)
  expect_s3_class(err, "omophub_rate_limit_error")
})

# ==============================================================================
# abort_validation() tests
# ==============================================================================

test_that("abort_validation throws error with correct class", {
  err <- rlang::catch_cnd(
    omophub:::abort_validation("Invalid value", arg = "concept_id")
  )

  expect_s3_class(err, "omophub_validation_error")
  expect_s3_class(err, "omophub_error")
})

test_that("abort_validation includes arg when provided", {
  err <- rlang::catch_cnd(
    omophub:::abort_validation("Must be positive", arg = "page")
  )

  expect_equal(err$arg, "page")
})

test_that("abort_validation works without arg", {
  err <- rlang::catch_cnd(
    omophub:::abort_validation("Generic validation error")
  )

  expect_null(err$arg)
  expect_s3_class(err, "omophub_validation_error")
})
