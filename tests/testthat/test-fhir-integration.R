# Integration tests for FhirResource against the live OMOPHub API
# Uses the same skip_if_no_integration_key() pattern as other integration tests.

test_that("fhir$resolve resolves SNOMED 44054006 live", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$fhir$resolve(
    system = "http://snomed.info/sct",
    code = "44054006",
    resource_type = "Condition"
  )

  res <- result$resolution
  expect_equal(res$mapping_type, "direct")
  expect_equal(res$target_table, "condition_occurrence")
  expect_equal(res$standard_concept$vocabulary_id, "SNOMED")
  expect_equal(res$domain_resource_alignment, "aligned")
})

test_that("fhir$resolve resolves ICD-10-CM E11.9 live", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$fhir$resolve(
    system = "http://hl7.org/fhir/sid/icd-10-cm",
    code = "E11.9"
  )

  res <- result$resolution
  expect_equal(res$vocabulary_id, "ICD10CM")
  expect_equal(res$source_concept$vocabulary_id, "ICD10CM")
  expect_equal(res$standard_concept$standard_concept, "S")
  expect_equal(res$target_table, "condition_occurrence")
})

test_that("fhir$resolve_batch resolves 3 codings live", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$fhir$resolve_batch(list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://loinc.org", code = "2339-0"),
    list(system = "http://www.nlm.nih.gov/research/umls/rxnorm", code = "197696")
  ))

  expect_equal(result$summary$total, 3L)
  expect_equal(
    result$summary$resolved + result$summary$failed,
    result$summary$total
  )
  expect_equal(length(result$results), 3L)
})

test_that("fhir$resolve_codeable_concept picks SNOMED over ICD-10-CM live", {
  skip_if_no_integration_key()
  client <- integration_client()

  result <- client$fhir$resolve_codeable_concept(
    coding = list(
      list(system = "http://snomed.info/sct", code = "44054006"),
      list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
    ),
    resource_type = "Condition"
  )

  expect_false(is.null(result$best_match))
  best <- result$best_match$resolution
  expect_equal(best$source_concept$vocabulary_id, "SNOMED")
  expect_equal(best$target_table, "condition_occurrence")
})
