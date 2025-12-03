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

  resource$get(201826, page = 1, page_size = 50)

  expect_equal(called_with$path, "concepts/201826/mappings")
  expect_equal(called_with$query$direction, "both")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 50L)
})

test_that("mappings$get includes target vocabularies filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, target_vocabularies = c("ICD10CM", "ICD9CM"))

  expect_equal(called_with$query$target_vocabularies, "ICD10CM,ICD9CM")
})

test_that("mappings$get includes mapping types filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, mapping_types = c("equivalent", "broader"))

  expect_equal(called_with$query$mapping_types, "equivalent,broader")
})

test_that("mappings$get includes direction parameter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, direction = "outgoing")

  expect_equal(called_with$query$direction, "outgoing")
})

test_that("mappings$get includes boolean options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(
    201826,
    include_indirect = TRUE,
    standard_only = TRUE,
    include_mapping_quality = TRUE,
    include_synonyms = TRUE,
    include_context = TRUE,
    active_only = FALSE
  )

  expect_equal(called_with$query$include_indirect, "true")
  expect_equal(called_with$query$standard_only, "true")
  expect_equal(called_with$query$include_mapping_quality, "true")
  expect_equal(called_with$query$include_synonyms, "true")
  expect_equal(called_with$query$include_context, "true")
  expect_equal(called_with$query$active_only, "false")
})

test_that("mappings$get includes sorting options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, sort_by = "target_vocabulary_id", sort_order = "asc")

  expect_equal(called_with$query$sort_by, "target_vocabulary_id")
  expect_equal(called_with$query$sort_order, "asc")
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
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
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
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
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
