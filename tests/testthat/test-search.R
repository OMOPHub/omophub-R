# Unit tests for SearchResource (R/search.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# SearchResource initialization
# ==============================================================================

test_that("SearchResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_s3_class(resource, "SearchResource")
  expect_s3_class(resource, "R6")
})

test_that("SearchResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_output(print(resource), "<OMOPHub SearchResource>")
  expect_output(print(resource), "basic, basic_all, advanced, autocomplete")
})

# ==============================================================================
# basic() method
# ==============================================================================

test_that("search$basic validates query", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$basic(""))  # Empty query
})

test_that("search$basic calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(data = list(), meta = list())
    }
  )

  resource$basic("diabetes", page = 1, page_size = 20)

  expect_equal(called_with$path, "search/concepts")
  expect_equal(called_with$query$query, "diabetes")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 20L)
})

test_that("search$basic includes vocabulary filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$basic("diabetes", vocabulary_ids = c("SNOMED", "ICD10CM"))

  expect_equal(called_with$query$vocabulary_ids, "SNOMED,ICD10CM")
})

test_that("search$basic includes domain filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$basic("aspirin", domain_ids = c("Drug", "Ingredient"))

  expect_equal(called_with$query$domain_ids, "Drug,Ingredient")
})

test_that("search$basic includes concept_class filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$basic("diabetes", concept_class_ids = "Clinical Finding")

  expect_equal(called_with$query$concept_class_ids, "Clinical Finding")
})

test_that("search$basic includes standard_concept filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$basic("diabetes", standard_concept = "S")

  expect_equal(called_with$query$standard_concept, "S")
})

test_that("search$basic includes boolean options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$basic(
    "diabetes",
    include_synonyms = TRUE,
    include_invalid = TRUE,
    exact_match = TRUE
  )

  expect_equal(called_with$query$include_synonyms, "true")
  expect_equal(called_with$query$include_invalid, "true")
  expect_equal(called_with$query$exact_match, "true")
})

test_that("search$basic includes scoring and sorting", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$basic(
    "diabetes",
    min_score = 0.5,
    sort_by = "concept_name",
    sort_order = "asc"
  )

  expect_equal(called_with$query$min_score, 0.5)
  expect_equal(called_with$query$sort_by, "concept_name")
  expect_equal(called_with$query$sort_order, "asc")
})

# ==============================================================================
# basic_all() method
# ==============================================================================

test_that("search$basic_all fetches multiple pages", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  page_calls <- 0
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      page_calls <<- page_calls + 1
      list(
        data = list(mock_concept(concept_id = page_calls)),
        meta = list(
          page = query$page,
          page_size = query$page_size,
          has_next = page_calls < 3
        )
      )
    }
  )

  result <- resource$basic_all("diabetes", page_size = 1, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)  # 3 pages
  expect_equal(page_calls, 3)
})

test_that("search$basic_all respects max_pages", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  page_calls <- 0
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      page_calls <<- page_calls + 1
      list(
        data = list(mock_concept()),
        meta = list(has_next = TRUE)
      )
    }
  )

  result <- resource$basic_all("diabetes", max_pages = 2, progress = FALSE)

  expect_equal(page_calls, 2)
})

test_that("search$basic_all handles concepts key in response", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      list(
        concepts = list(mock_concept()),
        meta = list(has_next = FALSE)
      )
    }
  )

  result <- resource$basic_all("diabetes", progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
})

# ==============================================================================
# advanced() method
# ==============================================================================

test_that("search$advanced validates query", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$advanced(""))
})

test_that("search$advanced calls correct endpoint with body", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
      list(results = list(), facets = list())
    }
  )

  resource$advanced("diabetes")

  expect_equal(called_with$path, "concepts/search/advanced")
  expect_equal(called_with$body$query, "diabetes")
})

test_that("search$advanced includes filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(results = list())
    }
  )

  resource$advanced(
    "diabetes",
    vocabularies = c("SNOMED", "ICD10CM"),
    domains = c("Condition"),
    concept_classes = c("Clinical Finding"),
    standard_concepts_only = TRUE,
    include_invalid = TRUE
  )

  expect_equal(called_with$body$vocabularies, c("SNOMED", "ICD10CM"))
  expect_equal(called_with$body$domains, "Condition")
  expect_equal(called_with$body$concept_classes, "Clinical Finding")
  expect_true(called_with$body$standard_concepts_only)
  expect_true(called_with$body$include_invalid)
})

test_that("search$advanced includes pagination params", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(results = list())
    }
  )

  resource$advanced("diabetes", limit = 50, offset = 100)

  expect_equal(called_with$body$limit, 50L)
  expect_equal(called_with$body$offset, 100L)
})

test_that("search$advanced omits default limit", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(results = list())
    }
  )

  resource$advanced("diabetes", limit = 20)  # Default

  expect_null(called_with$body$limit)
})

# ==============================================================================
# autocomplete() method
# ==============================================================================

test_that("search$autocomplete validates query", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$autocomplete(""))
})

test_that("search$autocomplete calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(suggestions = list())
    }
  )

  resource$autocomplete("diab", max_suggestions = 5)

  expect_equal(called_with$path, "search/suggest")
  expect_equal(called_with$query$query, "diab")
  expect_equal(called_with$query$max_suggestions, 5L)
})

test_that("search$autocomplete includes filters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(suggestions = list())
    }
  )

  resource$autocomplete(
    "diab",
    vocabulary_ids = c("SNOMED"),
    domains = c("Condition", "Drug")
  )

  expect_equal(called_with$query$vocabulary_ids, "SNOMED")
  expect_equal(called_with$query$domains, "Condition,Drug")
})

