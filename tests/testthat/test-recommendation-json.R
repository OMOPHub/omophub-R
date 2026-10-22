# Inspect the JSON httr2 actually sends, rather than mocking perform_post before
# vectors are encoded. req_dry_run uses a local echo server, never production.
capture_recommended_json <- function(...) {
  skip_if_not_installed("httpuv")
  skip_if_not_installed("jsonlite")
  captured <- NULL
  local_mocked_bindings(
    perform_request = function(req, endpoint, call) {
      wire <- httr2::req_dry_run(req, quiet = TRUE)
      expect_identical(wire$method, "POST")
      expect_identical(wire$path, "/v1/concepts/recommended")
      captured <<- jsonlite::fromJSON(rawToChar(wire$body), simplifyVector = FALSE)
      httr2::response(
        status_code = 200L,
        headers = list(`content-type` = "application/json"),
        body = charToRaw('{"data":{"317009":[]}}')
      )
    },
    .package = "omophub"
  )
  resource <- ConceptsResource$new(httr2::request("https://api.omophub.test/v1"))
  resource$recommended(...)
  captured
}

test_that("recommendations encode every singleton array as a JSON array", {
  body <- capture_recommended_json(
    317009L,
    relationship_types = "Ontology-descendant",
    vocabulary_ids = "SNOMED",
    domain_ids = "Condition"
  )

  expect_equal(body$concept_ids, list(317009L))
  expect_equal(body$relationship_types, list("Ontology-descendant"))
  expect_equal(body$vocabulary_ids, list("SNOMED"))
  expect_equal(body$domain_ids, list("Condition"))
  expect_identical(body$standard_only, TRUE)
  expect_identical(body$include_invalid, FALSE)
  expect_identical(body$page, 1L)
  expect_identical(body$page_size, 100L)
})

test_that("recommendations retain multiple array items and scalar options", {
  body <- capture_recommended_json(
    c(317009L, 201826L),
    relationship_types = c("Ontology-descendant", "Ontology-parent"),
    vocabulary_ids = c("SNOMED", "ICD10CM"),
    domain_ids = c("Condition", "Observation"),
    standard_only = FALSE,
    include_invalid = TRUE,
    page = 2L,
    page_size = 10L
  )

  expect_equal(body$concept_ids, list(317009L, 201826L))
  expect_equal(body$relationship_types, list("Ontology-descendant", "Ontology-parent"))
  expect_equal(body$vocabulary_ids, list("SNOMED", "ICD10CM"))
  expect_equal(body$domain_ids, list("Condition", "Observation"))
  expect_identical(body$standard_only, FALSE)
  expect_identical(body$include_invalid, TRUE)
  expect_identical(body$page, 2L)
  expect_identical(body$page_size, 10L)
})

test_that("named input vectors stay arrays and omitted filters stay absent", {
  body <- capture_recommended_json(
    c(asthma = 317009L),
    vocabulary_ids = c(preferred = "SNOMED")
  )

  expect_equal(body$concept_ids, list(317009L))
  expect_equal(body$vocabulary_ids, list("SNOMED"))
  expect_false("relationship_types" %in% names(body))
  expect_false("domain_ids" %in% names(body))
})

test_that("recommendation filters reject missing strings before sending", {
  resource <- ConceptsResource$new(httr2::request("https://api.omophub.test/v1"))
  local_mocked_bindings(
    perform_post = function(...) stop("request should not be sent"),
    .package = "omophub"
  )

  for (filter in c("relationship_types", "vocabulary_ids", "domain_ids")) {
    for (value in list(NA_character_, c("valid", NA_character_))) {
      args <- c(list(concept_ids = 317009L), setNames(list(value), filter))
      expect_error(do.call(resource$recommended, args), filter, class = "simpleError")
    }
  }
})
