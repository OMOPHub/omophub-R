# Integration tests for hierarchy resource
# Run with: testthat::test_file("tests/testthat/test-hierarchy-integration.R")

test_that("get ancestors works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$hierarchy$ancestors(
    DIABETES_CONCEPT_ID,
    max_levels = 3
  )

  ancestors <- extract_data(result, "ancestors")
  expect_true(is.list(ancestors))
  # Type 2 diabetes in SNOMED should have ancestors (parent concepts)
  # Empty list is acceptable if concept has no hierarchy
})

test_that("get ancestors with options works", {

  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$hierarchy$ancestors(
    DIABETES_CONCEPT_ID,
    vocabulary_ids = c("SNOMED"),
    max_levels = 5,
    include_distance = TRUE,
    page_size = 50
  )

  ancestors <- extract_data(result, "ancestors")
  expect_true(is.list(ancestors))

  # Verify hierarchy_summary structure if present
  if ("hierarchy_summary" %in% names(result)) {
    expect_true(
      "max_hierarchy_depth" %in% names(result$hierarchy_summary) ||
      "total_ancestors" %in% names(result$hierarchy_summary)
    )
  }
})

test_that("get descendants works", {
  skip_if_no_integration_key()
  client <- integration_client()

  # 201820 is Diabetes mellitus (parent of Type 2)
  result <- client$hierarchy$descendants(
    DIABETES_PARENT_ID,
    max_levels = 2
  )

  descendants <- extract_data(result, "descendants")
  expect_true(is.list(descendants))
})

test_that("get descendants with filters works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$hierarchy$descendants(
    DIABETES_PARENT_ID,
    vocabulary_ids = c("SNOMED"),
    max_levels = 3,
    include_distance = TRUE,
    include_invalid = FALSE,
    page_size = 100
  )

  descendants <- extract_data(result, "descendants")
  expect_true(is.list(descendants))

  # Verify hierarchy_summary structure if present
  if ("hierarchy_summary" %in% names(result)) {
    expect_true(
      "max_hierarchy_depth" %in% names(result$hierarchy_summary) ||
      "total_descendants" %in% names(result$hierarchy_summary)
    )
  }
})
