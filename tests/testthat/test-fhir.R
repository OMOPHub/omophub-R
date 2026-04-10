# Unit tests for FhirResource (R/fhir.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# FhirResource initialization
# ==============================================================================

test_that("FhirResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  expect_s3_class(resource, "FhirResource")
  expect_s3_class(resource, "R6")
})

# ==============================================================================
# Helper: mock FHIR response
# ==============================================================================

# Mocks return what perform_post actually returns: the unwrapped `data`
# field from the API response (perform_post strips the outer {success, data, meta}).
mock_fhir_resolution <- function() {
  list(
    input = list(system = "http://snomed.info/sct", code = "44054006"),
    resolution = list(
      vocabulary_id = "SNOMED",
      source_concept = list(
        concept_id = 201826L,
        concept_name = "Type 2 diabetes mellitus",
        concept_code = "44054006",
        vocabulary_id = "SNOMED",
        domain_id = "Condition",
        concept_class_id = "Clinical Finding",
        standard_concept = "S"
      ),
      standard_concept = list(
        concept_id = 201826L,
        concept_name = "Type 2 diabetes mellitus",
        concept_code = "44054006",
        vocabulary_id = "SNOMED",
        domain_id = "Condition",
        concept_class_id = "Clinical Finding",
        standard_concept = "S"
      ),
      mapping_type = "direct",
      target_table = "condition_occurrence",
      domain_resource_alignment = "aligned"
    )
  )
}

mock_fhir_batch <- function() {
  list(
    results = list(mock_fhir_resolution()),
    summary = list(total = 1L, resolved = 1L, failed = 0L)
  )
}

mock_fhir_codeable_concept <- function() {
  list(
    input = list(
      coding = list(
        list(system = "http://snomed.info/sct", code = "44054006"),
        list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
      )
    ),
    best_match = mock_fhir_resolution(),
    alternatives = list(),
    unresolved = list()
  )
}

# ==============================================================================
# resolve()
# ==============================================================================

test_that("fhir$resolve calls correct endpoint with body", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(path = path, body = body)
      mock_fhir_resolution()
    }
  )

  result <- resource$resolve(
    system = "http://snomed.info/sct",
    code = "44054006",
    resource_type = "Condition"
  )

  expect_equal(called_with$path, "fhir/resolve")
  expect_equal(called_with$body$system, "http://snomed.info/sct")
  expect_equal(called_with$body$code, "44054006")
  expect_equal(called_with$body$resource_type, "Condition")
  # Optional flags should NOT be in body when FALSE
  expect_null(called_with$body$include_recommendations)
  expect_null(called_with$body$include_quality)
})

test_that("fhir$resolve includes recommendation flags when requested", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(body = body)
      mock_fhir_resolution()
    }
  )

  resource$resolve(
    system = "http://snomed.info/sct",
    code = "44054006",
    include_recommendations = TRUE,
    recommendations_limit = 3L,
    include_quality = TRUE
  )

  expect_true(called_with$body$include_recommendations)
  expect_equal(called_with$body$recommendations_limit, 3L)
  expect_true(called_with$body$include_quality)
})

test_that("fhir$resolve returns resolution data", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      mock_fhir_resolution()
    }
  )

  result <- resource$resolve(system = "http://snomed.info/sct", code = "44054006")

  expect_equal(result$resolution$mapping_type, "direct")
  expect_equal(result$resolution$target_table, "condition_occurrence")
  expect_equal(result$resolution$standard_concept$concept_id, 201826L)
})

# ==============================================================================
# resolve_batch()
# ==============================================================================

test_that("fhir$resolve_batch calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(path = path, body = body)
      mock_fhir_batch()
    }
  )

  codings <- list(
    list(system = "http://snomed.info/sct", code = "44054006")
  )
  result <- resource$resolve_batch(codings)

  expect_equal(called_with$path, "fhir/resolve/batch")
  expect_equal(length(called_with$body$codings), 1)
  expect_equal(result$summary$total, 1L)
  expect_equal(result$summary$resolved, 1L)
})

test_that("fhir$resolve_batch passes all optional flags", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(body = body)
      mock_fhir_batch()
    }
  )

  resource$resolve_batch(
    list(list(system = "http://snomed.info/sct", code = "44054006")),
    resource_type = "Condition",
    include_recommendations = TRUE,
    recommendations_limit = 3L,
    include_quality = TRUE
  )

  expect_equal(called_with$body$resource_type, "Condition")
  expect_true(called_with$body$include_recommendations)
  expect_equal(called_with$body$recommendations_limit, 3L)
  expect_true(called_with$body$include_quality)
})

test_that("fhir$resolve_batch validates codings length", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  expect_error(resource$resolve_batch(list()))
})

test_that("fhir$resolve_batch rejects a single coding (not list-of-lists)", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  # A single coding object (not wrapped in an outer list) should fail
  expect_error(
    resource$resolve_batch(list(system = "http://snomed.info/sct", code = "44054006")),
    "list of coding lists"
  )
})

test_that("fhir$resolve_codeable_concept rejects a single coding (not list-of-lists)", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  # A single coding object (not wrapped in an outer list) should fail
  expect_error(
    resource$resolve_codeable_concept(list(system = "http://snomed.info/sct", code = "44054006")),
    "list of coding lists"
  )
})

# ==============================================================================
# resolve_codeable_concept()
# ==============================================================================

test_that("fhir$resolve_codeable_concept calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(path = path, body = body)
      mock_fhir_codeable_concept()
    }
  )

  coding <- list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
  )
  result <- resource$resolve_codeable_concept(
    coding = coding,
    resource_type = "Condition"
  )

  expect_equal(called_with$path, "fhir/resolve/codeable-concept")
  expect_equal(called_with$body$resource_type, "Condition")
  expect_equal(length(called_with$body$coding), 2)
  expect_false(is.null(result$best_match))
})

test_that("fhir$resolve_codeable_concept passes all optional flags", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(body = body)
      mock_fhir_codeable_concept()
    }
  )

  resource$resolve_codeable_concept(
    coding = list(list(system = "http://snomed.info/sct", code = "44054006")),
    text = "diabetes",
    resource_type = "Condition",
    include_recommendations = TRUE,
    recommendations_limit = 3L,
    include_quality = TRUE
  )

  expect_equal(called_with$body$text, "diabetes")
  expect_equal(called_with$body$resource_type, "Condition")
  expect_true(called_with$body$include_recommendations)
  expect_equal(called_with$body$recommendations_limit, 3L)
  expect_true(called_with$body$include_quality)
})

test_that("fhir$resolve_codeable_concept includes text fallback", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(body = body)
      mock_fhir_codeable_concept()
    }
  )

  coding <- list(list(system = "http://loinc.org", code = "99999-9"))
  resource$resolve_codeable_concept(coding = coding, text = "Blood Sugar")

  expect_equal(called_with$body$text, "Blood Sugar")
})
