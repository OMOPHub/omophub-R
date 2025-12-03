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
