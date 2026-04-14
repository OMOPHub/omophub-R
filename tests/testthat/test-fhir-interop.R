# Unit tests for omophub_fhir_url() (R/fhir_interop.R)

test_that("omophub_fhir_url() defaults to r4", {
  expect_equal(omophub_fhir_url(), "https://fhir.omophub.com/fhir/r4")
})

test_that("omophub_fhir_url() supports all four FHIR versions", {
  expect_equal(omophub_fhir_url("r4"), "https://fhir.omophub.com/fhir/r4")
  expect_equal(omophub_fhir_url("r4b"), "https://fhir.omophub.com/fhir/r4b")
  expect_equal(omophub_fhir_url("r5"), "https://fhir.omophub.com/fhir/r5")
  expect_equal(omophub_fhir_url("r6"), "https://fhir.omophub.com/fhir/r6")
})

test_that("omophub_fhir_url() rejects invalid versions", {
  expect_error(omophub_fhir_url("stu3"))
  expect_error(omophub_fhir_url("invalid"))
})
