# Unit tests for ConceptsResource (R/concepts.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# ConceptsResource initialization
# ==============================================================================

test_that("ConceptsResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_s3_class(resource, "ConceptsResource")
  expect_s3_class(resource, "R6")
})

test_that("ConceptsResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_output(print(resource), "<OMOPHub ConceptsResource>")
  expect_output(print(resource), "get, get_by_code, batch")
})

# ==============================================================================
# get() method
# ==============================================================================

test_that("concepts$get validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_error(resource$get("not_a_number"), class = "omophub_validation_error")
  expect_error(resource$get(-1), class = "omophub_validation_error")
  expect_error(resource$get(0), class = "omophub_validation_error")
})

test_that("concepts$get calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  # Mock the perform_get function
  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      mock_concept()
    }
  )

  resource$get(201826)

  expect_equal(called_with$path, "concepts/201826")
  expect_null(called_with$query)
})

test_that("concepts$get adds query params for options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      mock_concept()
    }
  )

  resource$get(201826, include_relationships = TRUE, include_synonyms = TRUE)

  expect_equal(called_with$query$include_relationships, "true")
  expect_equal(called_with$query$include_synonyms, "true")
})

# ==============================================================================
# get_by_code() method
# ==============================================================================

test_that("concepts$get_by_code validates arguments", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_error(resource$get_by_code("", "12345"))
  expect_error(resource$get_by_code("SNOMED", ""))
  expect_error(resource$get_by_code(123, "12345"))
})

test_that("concepts$get_by_code calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path)
      mock_concept()
    }
  )

  resource$get_by_code("SNOMED", "44054006")

  expect_equal(called_with$path, "concepts/by-code/SNOMED/44054006")
})

# ==============================================================================
# batch() method
# ==============================================================================

test_that("concepts$batch validates concept_ids", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_error(resource$batch(c()))  # Empty
  expect_error(resource$batch("not_numbers"))  # Not integers
})

test_that("concepts$batch calls correct endpoint with body", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
      list(concepts = list(mock_concept()))
    }
  )

  resource$batch(c(201826, 12345))

  expect_equal(called_with$path, "concepts/batch")
  expect_equal(called_with$body$concept_ids, c(201826L, 12345L))
})

test_that("concepts$batch includes optional parameters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(concepts = list())
    }
  )

  resource$batch(
    c(201826),
    include_relationships = TRUE,
    include_synonyms = TRUE,
    include_mappings = TRUE,
    vocabulary_filter = c("SNOMED", "ICD10CM"),
    standard_only = TRUE
  )

  expect_true(called_with$body$include_relationships)
  expect_true(called_with$body$include_synonyms)
  expect_true(called_with$body$include_mappings)
  expect_equal(called_with$body$vocabulary_filter, c("SNOMED", "ICD10CM"))
  expect_true(called_with$body$standard_only)
})

# ==============================================================================
# suggest() method
# ==============================================================================

test_that("concepts$suggest validates query length", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_error(resource$suggest("a"))  # Too short
  expect_error(resource$suggest(""))
})

test_that("concepts$suggest validates limit range", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) list()
  )

  expect_error(resource$suggest("diabetes", limit = 0))
  expect_error(resource$suggest("diabetes", limit = 100))
})

test_that("concepts$suggest calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(suggestions = list())
    }
  )

  resource$suggest("diab", vocabulary_ids = "SNOMED", domain_ids = "Condition", page_size = 5)

  expect_equal(called_with$path, "concepts/suggest")
  expect_equal(called_with$query$query, "diab")
  expect_equal(called_with$query$page_size, 5L)
  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
  expect_equal(called_with$query$domain_ids, "Condition")
})

# ==============================================================================
# related() method
# ==============================================================================

test_that("concepts$related validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_error(resource$related("invalid"))
})

test_that("concepts$related calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(related_concepts = list())
    }
  )

  resource$related(201826, page_size = 10)

  expect_equal(called_with$path, "concepts/201826/related")
  expect_equal(called_with$query$page_size, 10L)
})

test_that("concepts$related includes optional filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list()
    }
  )

  resource$related(
    201826,
    relationship_types = c("Is a", "Maps to"),
    min_score = 0.5,
    page_size = 50
  )

  expect_equal(called_with$query$relationship_types, "Is a,Maps to")
  expect_equal(called_with$query$min_score, 0.5)
  expect_equal(called_with$query$page_size, 50L)
})

# ==============================================================================
# relationships() method
# ==============================================================================

test_that("concepts$relationships validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  expect_error(resource$relationships("invalid"))
})

test_that("concepts$relationships calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(relationships = list())
    }
  )

  resource$relationships(201826)

  expect_equal(called_with$path, "concepts/201826/relationships")
})

test_that("concepts$relationships includes optional filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- ConceptsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list()
    }
  )

  resource$relationships(
    201826,
    relationship_ids = "Is a",
    vocabulary_ids = "SNOMED",
    include_invalid = TRUE
  )

  expect_equal(called_with$query$relationship_ids, "Is a")
  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
  expect_equal(called_with$query$include_invalid, "true")
})
