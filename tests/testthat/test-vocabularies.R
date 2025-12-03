# Unit tests for VocabulariesResource (R/vocabularies.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# VocabulariesResource initialization
# ==============================================================================

test_that("VocabulariesResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  expect_s3_class(resource, "VocabulariesResource")
  expect_s3_class(resource, "R6")
})

test_that("VocabulariesResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  expect_output(print(resource), "<OMOPHub VocabulariesResource>")
  expect_output(print(resource), "list, get, stats")
})

# ==============================================================================
# list() method
# ==============================================================================

test_that("vocabularies$list calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(vocabularies = list())
    }
  )

  resource$list()

  expect_equal(called_with$path, "vocabularies")
  expect_equal(called_with$query$sort_by, "name")
  expect_equal(called_with$query$sort_order, "asc")
})

test_that("vocabularies$list includes optional params", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(vocabularies = list())
    }
  )

  resource$list(
    include_stats = TRUE,
    include_inactive = TRUE,
    sort_by = "priority",
    sort_order = "desc",
    page = 2,
    page_size = 50
  )

  expect_equal(called_with$query$include_stats, "true")
  expect_equal(called_with$query$include_inactive, "true")
  expect_equal(called_with$query$sort_by, "priority")
  expect_equal(called_with$query$sort_order, "desc")
  expect_equal(called_with$query$page, 2L)
  expect_equal(called_with$query$page_size, 50L)
})

# ==============================================================================
# get() method
# ==============================================================================

test_that("vocabularies$get validates vocabulary_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  expect_error(resource$get(""))
  expect_error(resource$get(123))
})

test_that("vocabularies$get calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      mock_vocabulary()
    }
  )

  resource$get("SNOMED")

  expect_equal(called_with$path, "vocabularies/SNOMED")
  expect_null(called_with$query)
})

test_that("vocabularies$get includes optional params", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      mock_vocabulary()
    }
  )

  resource$get("SNOMED", include_stats = TRUE, include_domains = TRUE)

  expect_equal(called_with$query$include_stats, "true")
  expect_equal(called_with$query$include_domains, "true")
})

# ==============================================================================
# stats() method
# ==============================================================================

test_that("vocabularies$stats validates vocabulary_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  expect_error(resource$stats(""))
})

test_that("vocabularies$stats calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path)
      list(total_concepts = 1000)
    }
  )

  resource$stats("SNOMED")

  expect_equal(called_with$path, "vocabularies/SNOMED/stats")
})

# ==============================================================================
# domains() method
# ==============================================================================

test_that("vocabularies$domains calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(domains = list())
    }
  )

  resource$domains(page = 1, page_size = 50)

  expect_equal(called_with$path, "vocabularies/domains")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 50L)
})

test_that("vocabularies$domains includes vocabulary filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(domains = list())
    }
  )

  resource$domains(vocabulary_ids = c("SNOMED", "ICD10CM"))

  expect_equal(called_with$query$vocabulary_ids, "SNOMED,ICD10CM")
})

# ==============================================================================
# concepts() method
# ==============================================================================

test_that("vocabularies$concepts validates vocabulary_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  expect_error(resource$concepts(""))
})

test_that("vocabularies$concepts calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(concepts = list())
    }
  )

  resource$concepts("SNOMED", page = 1, page_size = 50)

  expect_equal(called_with$path, "vocabularies/SNOMED/concepts")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 50L)
})

test_that("vocabularies$concepts includes optional filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- VocabulariesResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(concepts = list())
    }
  )

  resource$concepts(
    "SNOMED",
    domain_id = "Condition",
    concept_class_id = "Clinical Finding",
    standard_only = TRUE
  )

  expect_equal(called_with$query$domain_id, "Condition")
  expect_equal(called_with$query$concept_class_id, "Clinical Finding")
  expect_equal(called_with$query$standard_only, "true")
})
