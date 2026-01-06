# Integration tests for mappings resource
# Run with: testthat::test_file("tests/testthat/test-mappings-integration.R")

test_that("get mappings works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$mappings$get(DIABETES_CONCEPT_ID)

  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
})

test_that("get mappings to ICD-10 works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$mappings$get(
    DIABETES_CONCEPT_ID,
    target_vocabulary = "ICD10CM"
  )

  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
})

test_that("get mappings with options works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$mappings$get(
    DIABETES_CONCEPT_ID,
    include_invalid = TRUE
  )

  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
})

test_that("map concepts batch works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$mappings$map(
    source_concepts = c(DIABETES_CONCEPT_ID, MI_CONCEPT_ID),
    target_vocabulary = "ICD10CM"
  )

  # Should get some result structure
  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
})
