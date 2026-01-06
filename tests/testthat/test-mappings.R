# Unit tests for MappingsResource (R/mappings.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# MappingsResource initialization
# ==============================================================================

test_that("MappingsResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_s3_class(resource, "MappingsResource")
  expect_s3_class(resource, "R6")
})

test_that("MappingsResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_output(print(resource), "<OMOPHub MappingsResource>")
  expect_output(print(resource), "get, map")
})

# ==============================================================================
# get() method
# ==============================================================================

test_that("mappings$get validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(resource$get("invalid"))
  expect_error(resource$get(-1))
})

test_that("mappings$get calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(mappings = list())
    }
  )

  resource$get(201826)

  expect_equal(called_with$path, "concepts/201826/mappings")
})

test_that("mappings$get includes target vocabulary filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, target_vocabulary = "ICD10CM")

  expect_equal(called_with$query$target_vocabulary, "ICD10CM")
})

test_that("mappings$get includes include_invalid option", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, include_invalid = TRUE)

  expect_equal(called_with$query$include_invalid, "true")
})

test_that("mappings$get includes vocab_release option", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, vocab_release = "2025.1")

  expect_equal(called_with$query$vocab_release, "2025.1")
})

# ==============================================================================
# map() method
# ==============================================================================

test_that("mappings$map validates source_concepts", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(resource$map(c(), "ICD10CM"))
  expect_error(resource$map("invalid", "ICD10CM"))
})

test_that("mappings$map validates target_vocabulary", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(resource$map(c(201826), ""))
  expect_error(resource$map(c(201826), 123))
})

test_that("mappings$map calls correct endpoint with body", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(path = path, body = body, query = query)
      list(mappings = list(), summary = list())
    }
  )

  resource$map(c(201826, 12345), "ICD10CM")

  expect_equal(called_with$path, "concepts/map")
  expect_equal(called_with$body$source_concepts, c(201826L, 12345L))
  expect_equal(called_with$body$target_vocabulary, "ICD10CM")
})

test_that("mappings$map includes optional parameters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(body = body, query = query)
      list(mappings = list())
    }
  )

  resource$map(
    c(201826),
    "ICD10CM",
    mapping_type = "equivalent",
    include_invalid = TRUE
  )

  expect_equal(called_with$body$mapping_type, "equivalent")
  expect_true(called_with$body$include_invalid)
})
