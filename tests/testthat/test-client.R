test_that("OMOPHubClient initializes with API key", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      client <- OMOPHubClient$new()
      expect_s3_class(client, "OMOPHubClient")
    }
  )
})

test_that("OMOPHubClient accepts explicit API key", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = NA),
    {
      client <- OMOPHubClient$new(api_key = "explicit_key")
      expect_s3_class(client, "OMOPHubClient")
    }
  )
})

test_that("OMOPHubClient errors without API key", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = NA),
    {
      expect_error(OMOPHubClient$new(), "No API key found")
    }
  )
})

test_that("OMOPHubClient accepts custom base_url", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      client <- OMOPHubClient$new(base_url = "https://custom.api.com/v1")
      expect_s3_class(client, "OMOPHubClient")
    }
  )
})

test_that("OMOPHubClient accepts timeout and max_retries", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      client <- OMOPHubClient$new(timeout = 60, max_retries = 5)
      expect_s3_class(client, "OMOPHubClient")
    }
  )
})

test_that("OMOPHubClient accepts vocab_version", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      client <- OMOPHubClient$new(vocab_version = "2025.1")
      expect_s3_class(client, "OMOPHubClient")
    }
  )
})

test_that("OMOPHubClient has resource accessors", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      client <- OMOPHubClient$new()

      expect_s3_class(client$concepts, "ConceptsResource")
      expect_s3_class(client$search, "SearchResource")
      expect_s3_class(client$vocabularies, "VocabulariesResource")
      expect_s3_class(client$domains, "DomainsResource")
      expect_s3_class(client$hierarchy, "HierarchyResource")
      expect_s3_class(client$relationships, "RelationshipsResource")
      expect_s3_class(client$mappings, "MappingsResource")
    }
  )
})

test_that("OMOPHubClient print method works", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      client <- OMOPHubClient$new()
      expect_output(print(client), "OMOPHubClient")
      expect_output(print(client), "Base URL")
      expect_output(print(client), "Authenticated: TRUE")
    }
  )
})

test_that("OMOPHubClient resources are lazy-loaded", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      client <- OMOPHubClient$new()

      # Access concepts twice - should be same object (cached)
      concepts1 <- client$concepts
      concepts2 <- client$concepts
      expect_identical(concepts1, concepts2)
    }
  )
})
