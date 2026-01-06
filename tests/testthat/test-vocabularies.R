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

test_that("vocabularies$get only accepts vocabulary_id", {
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

  resource$domains()

  expect_equal(called_with$path, "vocabularies/domains")
  expect_null(called_with$query)
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

  resource$concepts("SNOMED", page = 1, page_size = 20)

  expect_equal(called_with$path, "vocabularies/SNOMED/concepts")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 20L)
  expect_equal(called_with$query$standard_concept, "all")
  expect_equal(called_with$query$sort_by, "name")
  expect_equal(called_with$query$sort_order, "asc")
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
    search = "diabetes",
    standard_concept = "S",
    include_invalid = TRUE,
    include_relationships = TRUE,
    include_synonyms = TRUE,
    sort_by = "concept_id",
    sort_order = "desc"
  )

  expect_equal(called_with$query$search, "diabetes")
  expect_equal(called_with$query$standard_concept, "S")
  expect_equal(called_with$query$include_invalid, "true")
  expect_equal(called_with$query$include_relationships, "true")
  expect_equal(called_with$query$include_synonyms, "true")
  expect_equal(called_with$query$sort_by, "concept_id")
  expect_equal(called_with$query$sort_order, "desc")
})
