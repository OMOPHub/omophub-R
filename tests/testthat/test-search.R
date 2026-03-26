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

  expect_equal(called_with$path, "search/advanced")
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
    vocabulary_ids = c("SNOMED", "ICD10CM"),
    domain_ids = c("Condition"),
    concept_class_ids = c("Clinical Finding"),
    standard_concepts_only = TRUE,
    include_invalid = TRUE
  )

  expect_equal(called_with$body$vocabulary_ids, c("SNOMED", "ICD10CM"))
  expect_equal(called_with$body$domain_ids, "Condition")
  expect_equal(called_with$body$concept_class_ids, "Clinical Finding")
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

  resource$advanced("diabetes", page = 3, page_size = 50)

  expect_equal(called_with$body$page, 3L)
  expect_equal(called_with$body$page_size, 50L)
})

test_that("search$advanced omits default page_size", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(results = list())
    }
  )

  resource$advanced("diabetes", page_size = 20)  # Default

  expect_null(called_with$body$page_size)
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

# ==============================================================================
# semantic() method
# ==============================================================================

test_that("search$semantic validates query", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$semantic(""))  # Empty query
})

test_that("search$semantic calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(data = list(), meta = list())
    }
  )

  resource$semantic("heart attack", page = 1, page_size = 20)

  expect_equal(called_with$path, "concepts/semantic-search")
  expect_equal(called_with$query$query, "heart attack")
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 20L)
})

test_that("search$semantic includes vocabulary filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$semantic("heart attack", vocabulary_ids = c("SNOMED", "ICD10CM"))

  expect_equal(called_with$query$vocabulary_ids, "SNOMED,ICD10CM")
})

test_that("search$semantic includes domain filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$semantic("diabetes", domain_ids = c("Condition", "Observation"))

  expect_equal(called_with$query$domain_ids, "Condition,Observation")
})

test_that("search$semantic includes standard_concept filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$semantic("diabetes", standard_concept = "S")

  expect_equal(called_with$query$standard_concept, "S")
})

test_that("search$semantic includes threshold", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$semantic("diabetes", threshold = 0.5)

  expect_equal(called_with$query$threshold, 0.5)
})

test_that("search$semantic includes concept_class_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  resource$semantic("diabetes", concept_class_id = "Clinical Finding")

  expect_equal(called_with$query$concept_class_id, "Clinical Finding")
})

test_that("search$semantic validates threshold range", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$semantic("diabetes", threshold = 1.5))
  expect_error(resource$semantic("diabetes", threshold = -0.1))
})

test_that("search$semantic validates standard_concept choices", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$semantic("diabetes", standard_concept = "X"))
})

test_that("search$semantic rejects page_size over 100", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  # semantic uses max_page_size = 100
  expect_error(resource$semantic("diabetes", page_size = 101))
})

# ==============================================================================
# semantic_all() method
# ==============================================================================

test_that("search$semantic_all fetches multiple pages", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  page_calls <- 0
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      page_calls <<- page_calls + 1
      list(
        data = list(
          results = list(
            list(concept_id = page_calls, similarity_score = 0.9)
          )
        ),
        meta = list(
          page = query$page,
          page_size = query$page_size,
          has_next = page_calls < 3
        )
      )
    }
  )

  result <- resource$semantic_all("heart attack", page_size = 1, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)  # 3 pages
  expect_equal(page_calls, 3)
})

test_that("search$semantic_all respects max_pages", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  page_calls <- 0
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      page_calls <<- page_calls + 1
      list(
        data = list(results = list(mock_concept())),
        meta = list(has_next = TRUE)
      )
    }
  )

  result <- resource$semantic_all("diabetes", max_pages = 2, progress = FALSE)

  expect_equal(page_calls, 2)
})

# ==============================================================================
# similar() method
# ==============================================================================

test_that("search$similar requires exactly one search parameter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  # No parameters
  expect_error(resource$similar(), "Exactly one")

  # Multiple parameters
  expect_error(
    resource$similar(concept_id = 123, concept_name = "test"),
    "Exactly one"
  )
  expect_error(
    resource$similar(concept_id = 123, query = "test"),
    "Exactly one"
  )
})

test_that("search$similar by concept_id calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_id = 4329847)

  expect_equal(called_with$path, "search/similar")
  expect_equal(called_with$body$concept_id, 4329847L)
  expect_equal(called_with$body$algorithm, "hybrid")
  expect_equal(called_with$body$similarity_threshold, 0.7)
})

test_that("search$similar by concept_name works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_name = "Type 2 diabetes mellitus")

  expect_equal(called_with$body$concept_name, "Type 2 diabetes mellitus")
})

test_that("search$similar by query works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(query = "high blood sugar condition")

  expect_equal(called_with$body$query, "high blood sugar condition")
})

test_that("search$similar includes algorithm option", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_id = 123, algorithm = "semantic")

  expect_equal(called_with$body$algorithm, "semantic")
})

test_that("search$similar includes similarity_threshold", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_id = 123, similarity_threshold = 0.85)

  expect_equal(called_with$body$similarity_threshold, 0.85)
})

test_that("search$similar includes vocabulary_ids as list", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_id = 123, vocabulary_ids = c("SNOMED", "ICD10CM"))

  # POST body uses array format
  expect_equal(called_with$body$vocabulary_ids, list("SNOMED", "ICD10CM"))
})

test_that("search$similar includes domain_ids as list", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_id = 123, domain_ids = c("Condition", "Observation"))

  expect_equal(called_with$body$domain_ids, list("Condition", "Observation"))
})

test_that("search$similar includes boolean options", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(
    concept_id = 123,
    include_invalid = TRUE,
    include_scores = TRUE,
    include_explanations = TRUE
  )

  expect_true(called_with$body$include_invalid)
  expect_true(called_with$body$include_scores)
  expect_true(called_with$body$include_explanations)
})

test_that("search$similar validates algorithm choices", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$similar(concept_id = 123, algorithm = "invalid"))
})

test_that("search$similar validates similarity_threshold range", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$similar(concept_id = 123, similarity_threshold = 1.5))
  expect_error(resource$similar(concept_id = 123, similarity_threshold = -0.1))
})

test_that("search$similar validates standard_concept choices", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$similar(concept_id = 123, standard_concept = "X"))
})

test_that("search$similar omits default page_size", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_id = 123, page_size = 20)  # Default

  expect_null(called_with$body$page_size)
})

test_that("search$similar includes non-default page_size", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  resource$similar(concept_id = 123, page_size = 50)

  expect_equal(called_with$body$page_size, 50L)
})

test_that("search$similar rejects concept_name and query together", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  # Test the third mutual exclusion pair
  expect_error(
    resource$similar(concept_name = "diabetes", query = "high blood sugar"),
    "Exactly one"
  )
})

test_that("search$similar rejects page_size zero", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$similar(concept_id = 123, page_size = 0))
})

test_that("search$similar rejects page_size over 1000", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$similar(concept_id = 123, page_size = 1001))
})

test_that("search$similar accepts standard_concept N", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(body = body)
      list(similar_concepts = list(), search_metadata = list())
    }
  )

  # "N" is a valid value for similar() but wasn't tested
  resource$similar(concept_id = 123, standard_concept = "N")

  expect_equal(called_with$body$standard_concept, "N")
})

test_that("search$semantic accepts standard_concept C", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(data = list(), meta = list())
    }
  )

  # "C" is a valid value for semantic() - test it explicitly
  resource$semantic("diabetes", standard_concept = "C")

  expect_equal(called_with$query$standard_concept, "C")
})

test_that("search$semantic_all returns empty tibble for no results", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      list(
        data = list(results = list()),
        meta = list(has_next = FALSE)
      )
    }
  )

  result <- resource$semantic_all("nonexistent query xyz", progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("search$semantic_all handles top-level results key", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      # Response structure with top-level 'results' key
      list(
        results = list(
          list(concept_id = 1, similarity_score = 0.9),
          list(concept_id = 2, similarity_score = 0.8)
        ),
        meta = list(has_next = FALSE)
      )
    }
  )

  result <- resource$semantic_all("test", progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
})

# ==============================================================================
# print() method update
# ==============================================================================

test_that("SearchResource print method includes new methods", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_output(print(resource), "semantic")
  expect_output(print(resource), "semantic_all")
  expect_output(print(resource), "similar")
})

# ==============================================================================
# bulk_basic() method
# ==============================================================================

test_that("search$bulk_basic validates searches", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$bulk_basic(list()))  # Empty list
  expect_error(resource$bulk_basic(list(list(search_id = "", query = "test"))))  # Empty search_id
  expect_error(resource$bulk_basic(list(list(search_id = "q1", query = ""))))  # Empty query
})

test_that("search$bulk_basic calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
      list(results = list(), total_searches = 0, completed_searches = 0, failed_searches = 0)
    }
  )

  resource$bulk_basic(list(
    list(search_id = "q1", query = "diabetes"),
    list(search_id = "q2", query = "hypertension")
  ))

  expect_equal(called_with$path, "search/bulk")
  expect_length(called_with$body$searches, 2)
  expect_equal(called_with$body$searches[[1]]$search_id, "q1")
  expect_equal(called_with$body$searches[[2]]$query, "hypertension")
})

test_that("search$bulk_basic passes defaults", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
      list(results = list(), total_searches = 1, completed_searches = 1, failed_searches = 0)
    }
  )

  resource$bulk_basic(
    list(list(search_id = "q1", query = "diabetes")),
    defaults = list(vocabulary_ids = list("SNOMED"), page_size = 5)
  )

  expect_equal(called_with$body$defaults$vocabulary_ids, list("SNOMED"))
  expect_equal(called_with$body$defaults$page_size, 5)
})

# ==============================================================================
# bulk_semantic() method
# ==============================================================================

test_that("search$bulk_semantic validates searches", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_error(resource$bulk_semantic(list()))  # Empty list
  expect_error(resource$bulk_semantic(list(list(search_id = "", query = "test"))))  # Empty search_id
  expect_error(resource$bulk_semantic(list(list(search_id = "s1", query = ""))))  # Empty query
})

test_that("search$bulk_semantic calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
      list(results = list(), total_searches = 0, completed_count = 0, failed_count = 0)
    }
  )

  resource$bulk_semantic(list(
    list(search_id = "s1", query = "heart failure treatment")
  ))

  expect_equal(called_with$path, "search/semantic-bulk")
  expect_length(called_with$body$searches, 1)
  expect_equal(called_with$body$searches[[1]]$search_id, "s1")
})

test_that("search$bulk_semantic passes defaults", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL) {
      called_with <<- list(path = path, body = body)
      list(results = list(), total_searches = 1, completed_count = 1, failed_count = 0)
    }
  )

  resource$bulk_semantic(
    list(list(search_id = "s1", query = "diabetes medications")),
    defaults = list(threshold = 0.8, page_size = 10)
  )

  expect_equal(called_with$body$defaults$threshold, 0.8)
  expect_equal(called_with$body$defaults$page_size, 10)
})

test_that("SearchResource print includes bulk methods", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- SearchResource$new(base_req)

  expect_output(print(resource), "bulk_basic")
  expect_output(print(resource), "bulk_semantic")
})
