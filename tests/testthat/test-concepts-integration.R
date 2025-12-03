# Integration tests for concepts resource
# Run with: testthat::test_file("tests/testthat/test-concepts-integration.R")

test_that("get real concept works", {
  skip_if_no_integration_key()
  client <- integration_client()

  concept <- client$concepts$get(DIABETES_CONCEPT_ID)

  expect_equal(concept$concept_id, DIABETES_CONCEPT_ID)
  expect_match(concept$concept_name, "Type 2 diabetes", ignore.case = TRUE)
  expect_equal(concept$vocabulary_id, "SNOMED")
  expect_equal(concept$domain_id, "Condition")
  expect_equal(concept$standard_concept, "S")
})

test_that("get concept with synonyms works", {
  skip_if_no_integration_key()
  client <- integration_client()

  concept <- client$concepts$get(
    DIABETES_CONCEPT_ID,
    include_synonyms = TRUE
  )

  expect_equal(concept$concept_id, DIABETES_CONCEPT_ID)
})

test_that("get concept by code works", {
  skip_if_no_integration_key()
  client <- integration_client()

  # SNOMED code for Type 2 diabetes mellitus
  concept <- client$concepts$get_by_code("SNOMED", "44054006")

  expect_equal(concept$concept_id, DIABETES_CONCEPT_ID)
  expect_equal(concept$concept_code, "44054006")
})

test_that("batch concepts works", {
  skip_if_no_integration_key()
  client <- integration_client()

  concept_ids <- c(DIABETES_CONCEPT_ID, ASPIRIN_CONCEPT_ID, MI_CONCEPT_ID)
  result <- client$concepts$batch(concept_ids)

  # Extract concepts from result
  concepts <- extract_data(result, "concepts")
  expect_true(is.list(concepts) || is.data.frame(concepts))
  expect_gte(length(concepts), 1)
})

test_that("suggest concepts works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$concepts$suggest("diabetes", limit = 5)

  # Extract suggestions
  suggestions <- extract_data(result, "suggestions")
  expect_true(is.list(suggestions) || is.data.frame(suggestions))
  expect_gt(length(suggestions), 0)

  # Check at least one suggestion contains 'diabetes'
  suggestion_texts <- vapply(suggestions, function(s) {
    if (is.list(s)) {
      text <- s$concept_name %||% s$suggestion %||% ""
      tolower(as.character(text))
    } else {
      tolower(as.character(s))
    }
  }, character(1))
  expect_true(any(grepl("diabetes", suggestion_texts, ignore.case = TRUE)))
})

test_that("suggest concepts with filters works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$concepts$suggest(
    "aspirin",
    vocabulary = "RxNorm",
    domain = "Drug",
    limit = 10
  )

  suggestions <- extract_data(result, "suggestions")
  expect_true(is.list(suggestions))
})

test_that("get related concepts works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$concepts$related(
    DIABETES_CONCEPT_ID,
    max_results = 10
  )

  related <- extract_data(result, "related_concepts")
  expect_true(is.list(related))
})

test_that("get concept relationships works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$concepts$relationships(
    DIABETES_CONCEPT_ID,
    page_size = 20
  )

  relationships <- extract_data(result, "relationships")
  expect_true(is.list(relationships))
})
