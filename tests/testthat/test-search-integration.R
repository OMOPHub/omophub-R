# Integration tests for search resource
# Run with: testthat::test_file("tests/testthat/test-search-integration.R")

test_that("basic search works", {
  skip_if_no_integration_key()
  client <- integration_client()

  results <- client$search$basic("diabetes mellitus", page_size = 10)

  concepts <- extract_data(results, "concepts")
  expect_gt(length(concepts), 0)
})

test_that("search with vocabulary filter works", {
  skip_if_no_integration_key()
  client <- integration_client()

  results <- client$search$basic(
    "myocardial infarction",
    vocabulary_ids = "SNOMED",
    page_size = 20
  )

  concepts <- extract_data(results, "concepts")
  # If results exist, all should be SNOMED
  for (concept in concepts) {
    expect_equal(concept$vocabulary_id, "SNOMED")
  }
})

test_that("search with domain filter works", {
  skip_if_no_integration_key()
  client <- integration_client()

  results <- client$search$basic(
    "aspirin",
    domain_ids = "Drug",
    page_size = 10
  )

  concepts <- extract_data(results, "concepts")
  # If results exist, all should be in Drug domain
  for (concept in concepts) {
    expect_equal(concept$domain_id, "Drug")
  }
})

test_that("search with standard_concept filter works", {
  skip_if_no_integration_key()
  client <- integration_client()

  results <- client$search$basic(
    "diabetes",
    standard_concept = "S",
    page_size = 20
  )

  concepts <- extract_data(results, "concepts")
  expect_gt(length(concepts), 0)

  # All results should be standard concepts
  for (concept in concepts) {
    expect_equal(concept$standard_concept, "S")
  }
})

test_that("search with multiple filters and pagination works", {
  skip_if_no_integration_key()
  client <- integration_client()

  # This combination triggers the COUNT query with all parameters
  results <- client$search$basic(
    "diabetes",
    vocabulary_ids = "SNOMED",
    domain_ids = "Condition",
    standard_concept = "S",
    page_size = 10
  )

  concepts <- extract_data(results, "concepts")
  expect_gt(length(concepts), 0)

  # Verify all filters applied correctly
  for (concept in concepts) {
    expect_equal(concept$vocabulary_id, "SNOMED")
    expect_equal(concept$domain_id, "Condition")
    expect_equal(concept$standard_concept, "S")
  }

  # Verify pagination metadata exists (proves COUNT query worked)
  expect_true(!is.null(results$meta))
  expect_true(!is.null(results$meta$total_items))
})

test_that("autocomplete works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$autocomplete(
    "diab",
    max_suggestions = 10
  )

  suggestions <- extract_data(result, "suggestions")
  expect_gt(length(suggestions), 0)

  # Suggestions should contain the query
  for (suggestion in suggestions) {
    if (is.list(suggestion)) {
      text <- suggestion$suggestion %||% suggestion$concept_name %||% ""
      if (is.list(text)) {
        text <- text$concept_name %||% ""
      }
      text <- tolower(as.character(text))
    } else {
      text <- tolower(as.character(suggestion))
    }
    expect_match(text, "diab", ignore.case = TRUE)
  }
})

test_that("autocomplete with filters works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$autocomplete(
    "hyper",
    vocabulary_ids = "SNOMED",
    domains = "Condition",
    max_suggestions = 5
  )

  suggestions <- extract_data(result, "suggestions")
  expect_true(is.list(suggestions))
})

test_that("basic_all pagination works", {
  skip_if_no_integration_key()
  client <- integration_client()

  # Fetch multiple pages - returns a tibble
  results <- client$search$basic_all(
    "diabetes",
    page_size = 5,
    max_pages = 2
  )

  # Results should be a tibble with concept_id column
  expect_true(is.data.frame(results))
  expect_gt(nrow(results), 0)
  expect_true("concept_id" %in% names(results))
})

# ==============================================================================
# semantic() integration tests
# ==============================================================================

test_that("semantic search returns results", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$semantic("myocardial infarction", page_size = 5)

  # Extract results from response
  data <- extract_data(result, "results")
  expect_true(is.list(data) || is.data.frame(data))
})

test_that("semantic search respects threshold", {
  skip_if_no_integration_key()
  client <- integration_client()

  # Higher threshold should return fewer or equal results
  high <- client$search$semantic("heart attack", threshold = 0.8, page_size = 20)
  low <- client$search$semantic("heart attack", threshold = 0.3, page_size = 20)

  high_data <- extract_data(high, "results")
  low_data <- extract_data(low, "results")

  high_count <- if (is.data.frame(high_data)) nrow(high_data) else length(high_data)
  low_count <- if (is.data.frame(low_data)) nrow(low_data) else length(low_data)

  expect_lte(high_count, low_count)
})

test_that("semantic search filters by vocabulary", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$semantic(
    "diabetes",
    vocabulary_ids = "SNOMED",
    page_size = 10
  )

  data <- extract_data(result, "results")
  # Verify all results have vocabulary_id = SNOMED
  if (is.list(data) && length(data) > 0) {
    for (item in data) {
      if (!is.null(item$vocabulary_id)) {
        expect_equal(item$vocabulary_id, "SNOMED")
      }
    }
  }
})

test_that("semantic search filters by domain", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$semantic(
    "heart attack",
    domain_ids = "Condition",
    page_size = 10
  )

  data <- extract_data(result, "results")
  # Verify all results have domain_id = Condition
  if (is.list(data) && length(data) > 0) {
    for (item in data) {
      if (!is.null(item$domain_id)) {
        expect_equal(item$domain_id, "Condition")
      }
    }
  }
})

# ==============================================================================
# semantic_all() integration tests
# ==============================================================================

test_that("semantic_all returns tibble with pagination", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$semantic_all(
    "diabetes",
    page_size = 5,
    max_pages = 2,
    progress = FALSE
  )

  expect_s3_class(result, "tbl_df")
  expect_true("concept_id" %in% names(result))
  # Should have fetched some results
  expect_gt(nrow(result), 0)
})

# ==============================================================================
# similar() integration tests
# ==============================================================================

test_that("similar by concept_id returns results", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$similar(concept_id = MI_CONCEPT_ID, page_size = 5)

  # Result should be a list with similar_concepts or be directly the list
  expect_true(is.list(result))
})

test_that("similar by query returns results", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$similar(query = "elevated blood glucose", page_size = 5)

  expect_true(is.list(result))
})

test_that("similar with semantic algorithm works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$similar(
    concept_id = MI_CONCEPT_ID,
    algorithm = "semantic",
    similarity_threshold = 0.6,
    page_size = 5
  )

  expect_true(is.list(result))
})

test_that("similar by concept_name returns results", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$similar(
    concept_name = "Type 2 diabetes mellitus",
    page_size = 5
  )

  expect_true(is.list(result))
})

test_that("similar with vocabulary filter works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$similar(
    concept_id = DIABETES_CONCEPT_ID,
    vocabulary_ids = "SNOMED",
    page_size = 10
  )

  # Verify results, if any, are from SNOMED
  similar <- result$similar_concepts %||% result
  if (is.list(similar) && length(similar) > 0) {
    for (concept in similar) {
      if (!is.null(concept$vocabulary_id)) {
        expect_equal(concept$vocabulary_id, "SNOMED")
      }
    }
  }
})

# ==============================================================================
# Bulk lexical search integration tests
# ==============================================================================

test_that("bulk_basic search works with multiple queries", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$bulk_basic(list(
    list(search_id = "q1", query = "diabetes mellitus"),
    list(search_id = "q2", query = "hypertension"),
    list(search_id = "q3", query = "aspirin")
  ), defaults = list(page_size = 5))

  results <- extract_data(result, "results")
  expect_length(results, 3)

  for (item in results) {
    expect_true(item$search_id %in% c("q1", "q2", "q3"))
    expect_equal(item$status, "completed")
    expect_gt(length(item$results), 0)
  }
})

test_that("bulk_basic search works with vocabulary filter", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$bulk_basic(
    list(list(search_id = "snomed1", query = "diabetes")),
    defaults = list(vocabulary_ids = list("SNOMED"), page_size = 3)
  )

  results <- extract_data(result, "results")
  expect_length(results, 1)
  expect_equal(results[[1]]$status, "completed")
})

# ==============================================================================
# Bulk semantic search integration tests
# ==============================================================================

test_that("bulk_semantic search works with multiple queries", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$bulk_semantic(list(
    list(search_id = "s1", query = "heart failure treatment options"),
    list(search_id = "s2", query = "type 2 diabetes medication")
  ), defaults = list(threshold = 0.5, page_size = 5))

  results <- extract_data(result, "results")
  expect_length(results, 2)

  for (item in results) {
    expect_true(item$search_id %in% c("s1", "s2"))
    expect_equal(item$status, "completed")
  }
})

test_that("bulk_semantic search works with single query", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$search$bulk_semantic(
    list(list(search_id = "one", query = "elevated blood pressure", threshold = 0.5))
  )

  results <- extract_data(result, "results")
  expect_length(results, 1)
  expect_equal(results[[1]]$search_id, "one")
})
