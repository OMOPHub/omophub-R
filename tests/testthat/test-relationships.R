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
    relationship_ids = "Is a",
    vocabulary_ids = "SNOMED",
    include_invalid = TRUE
  )

  expect_equal(called_with$query$relationship_ids, "Is a")
  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
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

test_that("relationships$types includes pagination options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- RelationshipsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(relationship_types = list())
    }
  )

  resource$types(page = 2, page_size = 50)

  expect_equal(called_with$query$page, 2L)
  expect_equal(called_with$query$page_size, 50L)
})
