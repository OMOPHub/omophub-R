# Unit tests for HierarchyResource (R/hierarchy.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# HierarchyResource initialization
# ==============================================================================

test_that("HierarchyResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  expect_s3_class(resource, "HierarchyResource")
  expect_s3_class(resource, "R6")
})

test_that("HierarchyResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  expect_output(print(resource), "<OMOPHub HierarchyResource>")
  expect_output(print(resource), "ancestors, descendants")
})

# ==============================================================================
# ancestors() method
# ==============================================================================

test_that("hierarchy$ancestors validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  expect_error(resource$ancestors("invalid"))
  expect_error(resource$ancestors(-1))
})

test_that("hierarchy$ancestors calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(ancestors = list())
    }
  )

  resource$ancestors(201826, page = 1, page_size = 100)

  expect_equal(called_with$path, "concepts/201826/ancestors")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 100L)
})

test_that("hierarchy$ancestors includes optional params", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(ancestors = list())
    }
  )

  resource$ancestors(
    201826,
    vocabulary_ids = c("SNOMED"),
    max_levels = 5,
    relationship_types = c("Is a", "Subsumes"),
    include_paths = TRUE,
    include_distance = TRUE,
    include_invalid = TRUE
  )

  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
  expect_equal(called_with$query$max_levels, 5L)
  expect_equal(called_with$query$relationship_types, "Is a,Subsumes")
  expect_equal(called_with$query$include_paths, "true")
  expect_equal(called_with$query$include_distance, "true")
  expect_equal(called_with$query$include_invalid, "true")
})

# ==============================================================================
# descendants() method
# ==============================================================================

test_that("hierarchy$descendants validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  expect_error(resource$descendants("invalid"))
  expect_error(resource$descendants(0))
})

test_that("hierarchy$descendants calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(descendants = list())
    }
  )

  resource$descendants(201826, page = 1, page_size = 100)

  expect_equal(called_with$path, "concepts/201826/descendants")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 100L)
})

test_that("hierarchy$descendants limits max_levels to 20", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(descendants = list())
    }
  )

  resource$descendants(201826, max_levels = 50)  # Request 50

  expect_equal(called_with$query$max_levels, 20L)  # Capped at 20
})

test_that("hierarchy$descendants includes optional params", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- HierarchyResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(descendants = list())
    }
  )

  resource$descendants(
    201826,
    vocabulary_ids = c("SNOMED"),
    max_levels = 5,
    relationship_types = c("Is a"),
    include_distance = TRUE,
    include_paths = TRUE,
    include_invalid = TRUE,
    domain_ids = c("Condition")
  )

  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
  expect_equal(called_with$query$max_levels, 5L)
  expect_equal(called_with$query$relationship_types, "Is a")
  expect_equal(called_with$query$include_distance, "true")
  expect_equal(called_with$query$include_paths, "true")
  expect_equal(called_with$query$include_invalid, "true")
  expect_equal(called_with$query$domain_ids, "Condition")
})
