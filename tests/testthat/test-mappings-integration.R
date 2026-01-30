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
    target_vocabulary = "ICD10CM",
    source_concepts = c(DIABETES_CONCEPT_ID, MI_CONCEPT_ID)
  )

  # Should get some result structure
  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
})

# ==============================================================================
# map() with source_codes integration tests
# ==============================================================================

test_that("map concepts with source_codes works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$mappings$map(
    target_vocabulary = "RxNorm",
    source_codes = list(
      list(vocabulary_id = "SNOMED", concept_code = "387517004"),
      list(vocabulary_id = "SNOMED", concept_code = "108774000")
    )
  )

  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
})

test_that("map concepts with source_codes and mapping_type works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$mappings$map(
    target_vocabulary = "RxNorm",
    source_codes = list(
      list(vocabulary_id = "SNOMED", concept_code = "387517004")
    ),
    mapping_type = "equivalent"
  )

  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
})

test_that("map concepts with invalid source_codes returns empty", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$mappings$map(
    target_vocabulary = "RxNorm",
    source_codes = list(
      list(vocabulary_id = "SNOMED", concept_code = "INVALID_CODE_12345")
    )
  )

  mappings <- extract_data(result, "mappings")
  expect_true(is.list(mappings))
  expect_equal(length(mappings), 0)
})
