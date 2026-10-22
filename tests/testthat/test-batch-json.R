# Exercise httr2's JSON encoding against its local echo server, not production.
capture_batch_json <- function(...) {
  skip_if_not_installed("httpuv")
  skip_if_not_installed("jsonlite")
  captured <- NULL
  local_mocked_bindings(
    perform_request = function(req, endpoint, call) {
      wire <- httr2::req_dry_run(req, quiet = TRUE)
      expect_identical(wire$method, "POST")
      expect_identical(wire$path, "/v1/concepts/batch")
      captured <<- jsonlite::fromJSON(rawToChar(wire$body), simplifyVector = FALSE)
      httr2::response(
        status_code = 200L,
        headers = list(`content-type` = "application/json"),
        body = charToRaw('{"data":{"concepts":[]}}')
      )
    },
    .package = "omophub"
  )
  resource <- ConceptsResource$new(httr2::request("https://api.omophub.test/v1"))
  resource$batch(...)
  captured
}

test_that("batch encodes singleton IDs and vocabulary filters as arrays", {
  body <- capture_batch_json(201826L, vocabulary_filter = "SNOMED")
  expect_equal(body$concept_ids, list(201826L))
  expect_equal(body$vocabulary_filter, list("SNOMED"))
  expect_identical(body$standard_only, TRUE)
})

test_that("batch preserves multiple array items and scalar boolean flags", {
  body <- capture_batch_json(
    c(201826L, 4329847L),
    vocabulary_filter = c("SNOMED", "ICD10CM"),
    include_relationships = TRUE,
    include_synonyms = TRUE,
    include_mappings = TRUE
  )
  expect_equal(body$concept_ids, list(201826L, 4329847L))
  expect_equal(body$vocabulary_filter, list("SNOMED", "ICD10CM"))
  expect_identical(body$include_relationships, TRUE)
  expect_identical(body$include_synonyms, TRUE)
  expect_identical(body$include_mappings, TRUE)
  expect_identical(body$standard_only, TRUE)
})

test_that("batch drops input names and leaves omitted filters absent", {
  body <- capture_batch_json(
    c(diabetes = 201826L),
    vocabulary_filter = c(preferred = "SNOMED")
  )
  expect_equal(body$concept_ids, list(201826L))
  expect_equal(body$vocabulary_filter, list("SNOMED"))

  body <- capture_batch_json(201826L, standard_only = FALSE)
  expect_equal(body$concept_ids, list(201826L))
  expect_false("vocabulary_filter" %in% names(body))
  expect_false("standard_only" %in% names(body))
  expect_false("include_relationships" %in% names(body))
  expect_false("include_synonyms" %in% names(body))
  expect_false("include_mappings" %in% names(body))
})

test_that("batch rejects invalid vocabulary filters before making a request", {
  resource <- ConceptsResource$new(httr2::request("https://api.omophub.test/v1"))
  local_mocked_bindings(
    perform_post = function(...) stop("request should not be sent"),
    .package = "omophub"
  )
  for (filter in list(123, TRUE, list("SNOMED"), NA_character_)) {
    expect_error(
      resource$batch(201826L, vocabulary_filter = filter),
      "vocabulary_filter", class = "simpleError"
    )
  }
})
