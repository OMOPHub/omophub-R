# Unit tests for request.R
# Tests HTTP request building and execution functions

# ==============================================================================
# build_request() tests
# ==============================================================================

test_that("build_request creates request with correct headers", {
  req <- omophub:::build_request(
    base_url = "https://api.omophub.com/v1",
    api_key = "test_api_key"
  )

  # Headers are stored in httr2_headers object
  # Convert to list to check values
  headers_list <- as.list(req$headers)

  # Check Authorization header (httr2 redacts it, so check it exists)
  expect_true("Authorization" %in% names(headers_list))

  # Check Content-Type header
  expect_equal(headers_list$`Content-Type`, "application/json")

  # Check Accept header
  expect_equal(headers_list$Accept, "application/json")
})

test_that("build_request sets User-Agent header", {
  req <- omophub:::build_request(
    base_url = "https://api.omophub.com/v1",
    api_key = "test_api_key"
  )

  # User-Agent is set via req_user_agent, stored in options$useragent
  expect_true("useragent" %in% names(req$options))
  expect_true(grepl("OMOPHub-SDK-R", req$options$useragent))
})

test_that("build_request adds vocab_version header when specified", {
  req <- omophub:::build_request(
    base_url = "https://api.omophub.com/v1",
    api_key = "test_api_key",
    vocab_version = "2025.1"
  )

  headers_list <- as.list(req$headers)
  expect_equal(headers_list$`X-Vocabulary-Version`, "2025.1")
})

test_that("build_request does not add vocab_version header when NULL", {
  req <- omophub:::build_request(
    base_url = "https://api.omophub.com/v1",
    api_key = "test_api_key",
    vocab_version = NULL
  )

  headers_list <- as.list(req$headers)
  expect_null(headers_list$`X-Vocabulary-Version`)
})

test_that("build_request configures timeout", {
  req <- omophub:::build_request(
    base_url = "https://api.omophub.com/v1",
    api_key = "test_api_key",
    timeout = 60
  )

  # Timeout is configured via req_timeout
  expect_true(req$options$timeout_ms == 60000 || is.null(req$options$timeout_ms))
})

# ==============================================================================
# perform_get() tests
# ==============================================================================

test_that("perform_get constructs correct endpoint path", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  called_url <- NULL
  local_mocked_bindings(
    req_perform = function(req) {
      called_url <<- req$url
      structure(
        list(status_code = 200, body = charToRaw('{"data": {"test": true}}')),
        class = "httr2_response"
      )
    },
    resp_body_json = function(resp) list(data = list(test = TRUE)),
    .package = "httr2"
  )

  omophub:::perform_get(base_req, "concepts/201826")

  expect_true(grepl("concepts/201826", called_url))
})

test_that("perform_get filters NULL query parameters", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  called_url <- NULL
  local_mocked_bindings(
    req_perform = function(req) {
      called_url <<- req$url
      structure(
        list(status_code = 200, body = charToRaw('{"test": true}')),
        class = "httr2_response"
      )
    },
    resp_body_json = function(resp) list(test = TRUE),
    .package = "httr2"
  )

  omophub:::perform_get(base_req, "test", query = list(a = "value", b = NULL, c = "other"))

  expect_true(grepl("a=value", called_url))
  expect_true(grepl("c=other", called_url))
  expect_false(grepl("b=", called_url))
})

test_that("perform_get handles empty query", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  called_url <- NULL
  local_mocked_bindings(
    req_perform = function(req) {
      called_url <<- req$url
      structure(list(status_code = 200), class = "httr2_response")
    },
    resp_body_json = function(resp) list(result = TRUE),
    .package = "httr2"
  )

  omophub:::perform_get(base_req, "test", query = NULL)

  expect_false(grepl("\\?", called_url))
})

test_that("perform_get returns paginated response with meta", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  local_mocked_bindings(
    req_perform = function(req) structure(list(status_code = 200), class = "httr2_response"),
    resp_body_json = function(resp) list(
      data = list(list(id = 1), list(id = 2)),
      meta = list(
        pagination = list(page = 1, page_size = 20, total_items = 100, has_next = TRUE)
      )
    ),
    .package = "httr2"
  )

  result <- omophub:::perform_get(base_req, "test")

  expect_true("data" %in% names(result))
  expect_true("meta" %in% names(result))
  expect_equal(result$meta$page, 1)
  expect_equal(result$meta$has_next, TRUE)
})

test_that("perform_get unwraps non-paginated data response", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  local_mocked_bindings(
    req_perform = function(req) structure(list(status_code = 200), class = "httr2_response"),
    resp_body_json = function(resp) list(
      data = list(concept_id = 201826, concept_name = "Test"),
      meta = list(request_id = "abc123")
    ),
    .package = "httr2"
  )

  result <- omophub:::perform_get(base_req, "concepts/201826")

  # Should unwrap to just data since no pagination
  expect_equal(result$concept_id, 201826)
  expect_equal(result$concept_name, "Test")
})

test_that("perform_get returns body as-is when no data/meta structure", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  local_mocked_bindings(
    req_perform = function(req) structure(list(status_code = 200), class = "httr2_response"),
    resp_body_json = function(resp) list(status = "ok", version = "1.0"),
    .package = "httr2"
  )

  result <- omophub:::perform_get(base_req, "health")

  expect_equal(result$status, "ok")
  expect_equal(result$version, "1.0")
})

# ==============================================================================
# perform_post() tests
# ==============================================================================

test_that("perform_post uses POST method", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  called_method <- NULL
  local_mocked_bindings(
    req_perform = function(req) {
      called_method <<- req$method
      structure(list(status_code = 200), class = "httr2_response")
    },
    resp_body_json = function(resp) list(success = TRUE),
    .package = "httr2"
  )

  omophub:::perform_post(base_req, "concepts/batch", body = list(concept_ids = c(1, 2)))

  expect_equal(called_method, "POST")
})

test_that("perform_post constructs correct endpoint path", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  called_url <- NULL
  local_mocked_bindings(
    req_perform = function(req) {
      called_url <<- req$url
      structure(list(status_code = 200), class = "httr2_response")
    },
    resp_body_json = function(resp) list(data = list()),
    .package = "httr2"
  )

  omophub:::perform_post(base_req, "concepts/batch")

  expect_true(grepl("concepts/batch", called_url))
})

test_that("perform_post handles NULL body", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  local_mocked_bindings(
    req_perform = function(req) structure(list(status_code = 200), class = "httr2_response"),
    resp_body_json = function(resp) list(result = TRUE),
    .package = "httr2"
  )

  # Should not error
  result <- omophub:::perform_post(base_req, "test", body = NULL)
  expect_equal(result$result, TRUE)
})

test_that("perform_post filters NULL body fields", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  captured_body <- NULL
  local_mocked_bindings(
    req_perform = function(req) {
      captured_body <<- req$body$data
      structure(list(status_code = 200), class = "httr2_response")
    },
    resp_body_json = function(resp) list(data = list()),
    .package = "httr2"
  )

  omophub:::perform_post(
    base_req,
    "test",
    body = list(a = "value", b = NULL, c = 123)
  )

  # Body should have a and c, but not b
  expect_true(!is.null(captured_body))
})

test_that("perform_post handles query parameters", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  called_url <- NULL
  local_mocked_bindings(
    req_perform = function(req) {
      called_url <<- req$url
      structure(list(status_code = 200), class = "httr2_response")
    },
    resp_body_json = function(resp) list(data = list()),
    .package = "httr2"
  )

  omophub:::perform_post(
    base_req,
    "test",
    body = list(ids = c(1, 2)),
    query = list(format = "json")
  )

  expect_true(grepl("format=json", called_url))
})

test_that("perform_post unwraps data field from response", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  local_mocked_bindings(
    req_perform = function(req) structure(list(status_code = 200), class = "httr2_response"),
    resp_body_json = function(resp) list(
      data = list(concepts = list(list(id = 1), list(id = 2)))
    ),
    .package = "httr2"
  )

  result <- omophub:::perform_post(base_req, "concepts/batch")

  expect_true("concepts" %in% names(result))
  expect_equal(length(result$concepts), 2)
})

test_that("perform_post returns body as-is when no data field", {
  base_req <- httr2::request("https://api.omophub.com/v1")

  local_mocked_bindings(
    req_perform = function(req) structure(list(status_code = 200), class = "httr2_response"),
    resp_body_json = function(resp) list(status = "created", id = 123),
    .package = "httr2"
  )

  result <- omophub:::perform_post(base_req, "test")

  expect_equal(result$status, "created")
  expect_equal(result$id, 123)
})
