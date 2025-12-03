# Integration tests for domains resource
# Run with: testthat::test_file("tests/testthat/test-domains-integration.R")

test_that("list domains works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$domains$list()

  domains <- extract_data(result, "domains")
  expect_gt(length(domains), 0)

  # Check for common domains
  domain_ids <- vapply(domains, function(d) d$domain_id %||% "", character(1))
  expect_true("Condition" %in% domain_ids)
  expect_true("Drug" %in% domain_ids)
  expect_true("Procedure" %in% domain_ids)
})

test_that("list domains with options works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$domains$list(
    include_concept_counts = TRUE,
    include_statistics = TRUE
  )

  domains <- extract_data(result, "domains")
  expect_gt(length(domains), 0)
  # Verify domains are returned with expected structure
  for (domain in domains) {
    expect_true("domain_id" %in% names(domain))
  }
})

test_that("list domains with vocabulary filter works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$domains$list(
    vocabulary_ids = "SNOMED",
    include_concept_counts = TRUE
  )

  domains <- extract_data(result, "domains")
  expect_true(is.list(domains))
  expect_gt(length(domains), 0)
})

test_that("get domain concepts works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$domains$concepts(
    "Condition",
    vocabulary_ids = "SNOMED",
    standard_only = TRUE,
    page_size = 20
  )

  concepts <- extract_data(result, "concepts")
  expect_true(is.list(concepts))
  # All concepts should be in Condition domain
  for (concept in concepts) {
    expect_equal(concept$domain_id, "Condition")
  }
})

test_that("get drug domain concepts works", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$domains$concepts(
    "Drug",
    vocabulary_ids = "RxNorm",
    standard_only = TRUE,
    page_size = 10
  )

  concepts <- extract_data(result, "concepts")
  expect_true(is.list(concepts))
  # Verify all concepts are in Drug domain
  for (concept in concepts) {
    expect_equal(concept$domain_id, "Drug")
  }
})
