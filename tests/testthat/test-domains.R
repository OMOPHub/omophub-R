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
  expect_equal(called_with$query$sort_by, "domain_id")
  expect_equal(called_with$query$sort_order, "asc")
})

test_that("domains$list includes vocabulary filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(domains = list())
    }
  )

  resource$list(vocabulary_ids = c("SNOMED", "ICD10CM"))

  expect_equal(called_with$query$vocabulary_ids, "SNOMED,ICD10CM")
})

test_that("domains$list includes boolean options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- DomainsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(domains = list())
    }
  )

  resource$list(
    include_concept_counts = TRUE,
    include_statistics = TRUE,
    include_examples = TRUE,
    standard_only = TRUE,
    active_only = FALSE
  )

  expect_equal(called_with$query$include_concept_counts, "true")
  expect_equal(called_with$query$include_statistics, "true")
  expect_equal(called_with$query$include_examples, "true")
  expect_equal(called_with$query$standard_only, "true")
  expect_equal(called_with$query$active_only, "false")
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
    concept_class_ids = c("Clinical Finding"),
    standard_only = TRUE
  )

  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
  expect_equal(called_with$query$concept_class_ids, "Clinical Finding")
  expect_equal(called_with$query$standard_only, "true")
})
