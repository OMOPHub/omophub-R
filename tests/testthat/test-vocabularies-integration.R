# Integration tests for vocabularies resource
# Run with: testthat::test_file("tests/testthat/test-vocabularies-integration.R")

test_that("list vocabularies works", {
  skip_if_no_integration_key()
  client <- integration_client()

  # Use larger page_size to ensure common vocabularies are included
  result <- client$vocabularies$list(page_size = 200)

  vocabs <- extract_data(result, "vocabularies")
  expect_gt(length(vocabs), 0)

  # Check for common vocabularies
  vocab_ids <- vapply(vocabs, function(v) v$vocabulary_id %||% "", character(1))
  expect_true("SNOMED" %in% vocab_ids)
  expect_true("ICD10CM" %in% vocab_ids)
})

test_that("list vocabularies with stats works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$vocabularies$list(
    include_stats = TRUE,
    page_size = 50
  )

  vocabs <- extract_data(result, "vocabularies")
  expect_gt(length(vocabs), 0)
  # Verify vocabularies are returned with expected structure
  for (vocab in vocabs) {
    expect_true("vocabulary_id" %in% names(vocab))
  }
})

test_that("get vocabulary works", {
  skip_if_no_integration_key()
  client <- integration_client()

  vocab <- client$vocabularies$get("SNOMED")

  expect_equal(vocab$vocabulary_id, "SNOMED")
  expect_true("vocabulary_name" %in% names(vocab))
})

test_that("get vocabulary with options works", {
  skip_if_no_integration_key()
  client <- integration_client()

  vocab <- client$vocabularies$get(
    "SNOMED",
    include_stats = TRUE,
    include_domains = TRUE
  )

  expect_equal(vocab$vocabulary_id, "SNOMED")
  expect_true("vocabulary_name" %in% names(vocab))
})

test_that("get vocabulary stats works", {
  skip_if_no_integration_key()
  client <- integration_client()

  stats <- client$vocabularies$stats("SNOMED")

  expect_equal(stats$vocabulary_id, "SNOMED")
  # Should have concept counts
  expect_true(
    "total_concepts" %in% names(stats) ||
      "concept_count" %in% names(stats) ||
      "standard_concepts" %in% names(stats)
  )
})

test_that("get vocabulary domains works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$vocabularies$domains(vocabulary_ids = "SNOMED")

  domains <- extract_data(result, "domains")
  expect_true(is.list(domains))
})

test_that("get vocabulary concepts works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$vocabularies$concepts(
    "SNOMED",
    domain_id = "Condition",
    standard_only = TRUE,
    page_size = 10
  )

  concepts <- extract_data(result, "concepts")
  expect_true(is.list(concepts))
})
