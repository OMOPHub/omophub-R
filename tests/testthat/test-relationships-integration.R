# Integration tests for relationships resource
# Run with: testthat::test_file("tests/testthat/test-relationships-integration.R")

test_that("get relationships works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$relationships$get(DIABETES_CONCEPT_ID)

  relationships <- extract_data(result, "relationships")
  expect_true(is.list(relationships))
})

test_that("get relationships with type filter works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$relationships$get(
    DIABETES_CONCEPT_ID,
    relationship_ids = "Is a",
    page_size = 50
  )

  relationships <- extract_data(result, "relationships")
  expect_true(is.list(relationships))
})

test_that("get relationships with vocabulary filter works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$relationships$get(
    DIABETES_CONCEPT_ID,
    vocabulary_ids = "SNOMED",
    page_size = 100
  )

  relationships <- extract_data(result, "relationships")
  expect_true(is.list(relationships))
})

test_that("get relationship types works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$relationships$types()

  types <- extract_data(result, "relationship_types")
  expect_true(is.list(types))
  expect_gt(length(types), 0)
})

test_that("get relationship types with filters works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$relationships$types(
    page_size = 50
  )

  types <- extract_data(result, "relationship_types")
  expect_true(is.list(types))
})

test_that("get relationship types by category works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$relationships$types()

  types <- extract_data(result, "relationship_types")
  expect_true(is.list(types))
})
