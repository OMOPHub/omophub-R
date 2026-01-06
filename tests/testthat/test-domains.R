# Unit tests for DomainsResource (R/domains.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# DomainsResource initialization
# ==============================================================================

test_that("DomainsResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  expect_s3_class(resource, "DomainsResource")
  expect_s3_class(resource, "R6")
})

test_that("DomainsResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  expect_output(print(resource), "<OMOPHub DomainsResource>")
  expect_output(print(resource), "list, concepts")
})

# ==============================================================================
# list() method
# ==============================================================================

test_that("domains$list calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(domains = list())
    }
  )

  resource$list()

  expect_equal(called_with$path, "domains")
  # No params when include_stats is FALSE (default)
  expect_equal(length(called_with$query), 0)
})

test_that("domains$list includes include_stats parameter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(domains = list())
    }
  )

  resource$list(include_stats = TRUE)

  expect_equal(called_with$query$include_stats, "true")
})

test_that("domains$list without stats has no query params", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(domains = list())
    }
  )

  resource$list(include_stats = FALSE)

  # Should not have include_stats in query when FALSE
  expect_null(called_with$query$include_stats)
})

# ==============================================================================
# concepts() method
# ==============================================================================

test_that("domains$concepts validates domain_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  expect_error(resource$concepts(""))
  expect_error(resource$concepts(123))
})

test_that("domains$concepts calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(concepts = list())
    }
  )

  resource$concepts("Condition", page = 1, page_size = 50)

  expect_equal(called_with$path, "domains/Condition/concepts")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 50L)
})

test_that("domains$concepts includes optional filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(concepts = list())
    }
  )

  resource$concepts(
    "Condition",
    vocabulary_ids = c("SNOMED"),
    standard_only = TRUE,
    include_invalid = TRUE
  )

  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
  expect_equal(called_with$query$standard_only, "true")
  expect_equal(called_with$query$include_invalid, "true")
})
