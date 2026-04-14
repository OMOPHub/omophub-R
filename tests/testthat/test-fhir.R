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

# ==============================================================================
# resolve_batch(as_tibble = TRUE)
# ==============================================================================

mock_fhir_batch_mixed <- function() {
  list(
    results = list(
      mock_fhir_resolution(),
      list(error = "unknown code", input = list(
        system = "http://snomed.info/sct", code = "bogus"
      ))
    ),
    summary = list(total = 2L, resolved = 1L, failed = 1L)
  )
}

test_that("resolve_batch returns tibble when as_tibble = TRUE", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      mock_fhir_batch_mixed()
    }
  )

  codings <- list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://snomed.info/sct", code = "bogus")
  )
  tbl <- resource$resolve_batch(codings, as_tibble = TRUE)

  expect_s3_class(tbl, "tbl_df")
  expect_equal(nrow(tbl), 2L)
  expect_true(all(c(
    "source_system", "source_code",
    "source_concept_id", "source_concept_name",
    "standard_concept_id", "standard_concept_name",
    "standard_vocabulary_id", "domain_id", "target_table",
    "mapping_type", "similarity_score",
    "status", "status_detail"
  ) %in% names(tbl)))

  expect_equal(tbl$status[1], "resolved")
  expect_equal(tbl$standard_concept_id[1], 201826L)
  expect_equal(tbl$target_table[1], "condition_occurrence")

  expect_equal(tbl$status[2], "failed")
  expect_false(is.na(tbl$status_detail[2]))

  # summary is attached as attribute
  summary <- attr(tbl, "summary")
  expect_equal(summary$total, 2L)
  expect_equal(summary$resolved, 1L)
  expect_equal(summary$failed, 1L)
})

test_that("resolve_batch default return is unchanged (list shape)", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      mock_fhir_batch()
    }
  )

  result <- resource$resolve_batch(
    list(list(system = "http://snomed.info/sct", code = "44054006"))
  )

  expect_false(inherits(result, "tbl_df"))
  expect_true(is.list(result))
  expect_named(result, c("results", "summary"))
  expect_equal(result$summary$total, 1L)
})

# ==============================================================================
# Standalone wrapper parity
# ==============================================================================

test_that("fhir_resolve standalone matches R6 method", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  client_stub <- list(fhir = FhirResource$new(base_req))

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      mock_fhir_resolution()
    }
  )

  r6_result <- client_stub$fhir$resolve(
    system = "http://snomed.info/sct",
    code = "44054006"
  )
  wrapper_result <- fhir_resolve(
    client_stub,
    system = "http://snomed.info/sct",
    code = "44054006"
  )

  expect_identical(r6_result, wrapper_result)
})

test_that("fhir_resolve_batch standalone matches R6 method", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  client_stub <- list(fhir = FhirResource$new(base_req))

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      mock_fhir_batch()
    }
  )

  codings <- list(list(system = "http://snomed.info/sct", code = "44054006"))
  r6_result <- client_stub$fhir$resolve_batch(codings)
  wrapper_result <- fhir_resolve_batch(client_stub, codings)

  expect_identical(r6_result, wrapper_result)
})

test_that("fhir_resolve_codeable_concept standalone matches R6 method", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  client_stub <- list(fhir = FhirResource$new(base_req))

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      mock_fhir_codeable_concept()
    }
  )

  coding <- list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
  )
  r6_result <- client_stub$fhir$resolve_codeable_concept(coding = coding)
  wrapper_result <- fhir_resolve_codeable_concept(client_stub, coding = coding)

  expect_identical(r6_result, wrapper_result)
})

# ==============================================================================
# resolve_batch(as_tibble = TRUE) with unusual `error` shapes
# ==============================================================================

test_that("resolve_batch(as_tibble = TRUE) handles zero-length error values", {
  # Regression for a bug where `as.character(err)[[1L]]` crashed with
  # "subscript out of bounds" when the API returned an empty character
  # vector (or any other length-0 value) in the `error` field.
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      list(
        results = list(
          list(error = character(0)),       # empty character vector
          list(error = integer(0)),         # empty integer vector
          list(error = list())              # empty list
        ),
        summary = list(total = 3L, resolved = 0L, failed = 3L)
      )
    }
  )

  codings <- list(
    list(system = "http://snomed.info/sct", code = "a"),
    list(system = "http://snomed.info/sct", code = "b"),
    list(system = "http://snomed.info/sct", code = "c")
  )

  # Must not throw, must return one row per input
  tbl <- resource$resolve_batch(codings, as_tibble = TRUE)
  expect_s3_class(tbl, "tbl_df")
  expect_equal(nrow(tbl), 3L)
  expect_true(all(tbl$status == "failed"))
})

test_that("resolve_batch(as_tibble = TRUE) handles unusual scalar error shapes", {
  # Coverage for the non-character fallback: numeric and logical errors
  # must be coerced via as.character() without throwing.
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      list(
        results = list(
          list(error = 42L),
          list(error = TRUE)
        ),
        summary = list(total = 2L, resolved = 0L, failed = 2L)
      )
    }
  )

  codings <- list(
    list(system = "http://snomed.info/sct", code = "a"),
    list(system = "http://snomed.info/sct", code = "b")
  )

  tbl <- resource$resolve_batch(codings, as_tibble = TRUE)
  expect_equal(nrow(tbl), 2L)
  expect_equal(tbl$status_detail, c("42", "TRUE"))
})

test_that("resolve_batch(as_tibble = TRUE) handles NULL and missing error", {
  # Coverage for the `is.null(err)` early return: a failed item with no
  # `error` field at all maps to NA_character_ in status_detail.
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      list(
        results = list(
          list(input = list(system = "http://snomed.info/sct", code = "a")),
          list(error = NULL)
        ),
        summary = list(total = 2L, resolved = 0L, failed = 2L)
      )
    }
  )

  codings <- list(
    list(system = "http://snomed.info/sct", code = "a"),
    list(system = "http://snomed.info/sct", code = "b")
  )

  tbl <- resource$resolve_batch(codings, as_tibble = TRUE)
  expect_equal(nrow(tbl), 2L)
  expect_true(all(tbl$status == "failed"))
  expect_true(all(is.na(tbl$status_detail)))
})

test_that("resolve_batch(as_tibble = TRUE) extracts message/code from list error", {
  # Coverage for the structured-list error branch: picks the first
  # usable of err$message, err$code, err$detail and returns it as
  # status_detail rather than a flattened name=value concatenation.
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- FhirResource$new(base_req)

  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      list(
        results = list(
          list(error = list(
            code = "concept_not_found",
            message = "No matching OMOP concept"
          )),
          list(error = list(code = "vocabulary_restricted")),  # message missing
          list(error = list(detail = "just a detail field"))   # only detail
        ),
        summary = list(total = 3L, resolved = 0L, failed = 3L)
      )
    }
  )

  codings <- list(
    list(system = "http://snomed.info/sct", code = "a"),
    list(system = "http://snomed.info/sct", code = "b"),
    list(system = "http://snomed.info/sct", code = "c")
  )

  tbl <- resource$resolve_batch(codings, as_tibble = TRUE)
  expect_equal(nrow(tbl), 3L)
  expect_equal(tbl$status_detail[1], "No matching OMOP concept")  # message wins
  expect_equal(tbl$status_detail[2], "vocabulary_restricted")     # code fallback
  expect_equal(tbl$status_detail[3], "just a detail field")       # detail fallback
})
