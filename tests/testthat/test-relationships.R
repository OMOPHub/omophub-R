# Unit tests for RelationshipsResource (R/relationships.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# RelationshipsResource initialization
# ==============================================================================

test_that("RelationshipsResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  expect_s3_class(resource, "RelationshipsResource")
  expect_s3_class(resource, "R6")
})

test_that("RelationshipsResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  expect_output(print(resource), "<OMOPHub RelationshipsResource>")
  expect_output(print(resource), "get, types")
})

# ==============================================================================
# get() method
# ==============================================================================

test_that("relationships$get validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  expect_error(resource$get("invalid"))
  expect_error(resource$get(-1))
})

test_that("relationships$get calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(relationships = list())
    }
  )

  resource$get(201826, page = 1, page_size = 50)

  expect_equal(called_with$path, "concepts/201826/relationships")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 50L)
})

test_that("relationships$get includes optional filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(relationships = list())
    }
  )

  resource$get(
    201826,
    relationship_type = "Is a",
    target_vocabulary = "SNOMED",
    include_invalid = TRUE
  )

  expect_equal(called_with$query$relationship_type, "Is a")
  expect_equal(called_with$query$target_vocabulary, "SNOMED")
  expect_equal(called_with$query$include_invalid, "true")
})

# ==============================================================================
# types() method
# ==============================================================================

test_that("relationships$types calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(relationship_types = list())
    }
  )

  resource$types(page = 1, page_size = 100)

  expect_equal(called_with$path, "relationships/types")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 100L)
})

test_that("relationships$types includes vocabulary filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(relationship_types = list())
    }
  )

  resource$types(vocabulary_ids = c("SNOMED", "RxNorm"))

  expect_equal(called_with$query$vocabulary_ids, "SNOMED,RxNorm")
})

test_that("relationships$types includes boolean options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(relationship_types = list())
    }
  )

  resource$types(
    include_reverse = TRUE,
    include_usage_stats = TRUE,
    include_examples = TRUE,
    standard_only = TRUE
  )

  expect_equal(called_with$query$include_reverse, "true")
  expect_equal(called_with$query$include_usage_stats, "true")
  expect_equal(called_with$query$include_examples, "true")
  expect_equal(called_with$query$standard_only, "true")
})

test_that("relationships$types includes category and is_defining filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(relationship_types = list())
    }
  )

  resource$types(category = "hierarchical", is_defining = TRUE)

  expect_equal(called_with$query$category, "hierarchical")
  expect_equal(called_with$query$is_defining, "true")
})
