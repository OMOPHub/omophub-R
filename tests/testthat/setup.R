# Test setup for omophub package

# Only set mock API key if no real key is present
# This allows integration tests to run when OMOPHUB_API_KEY is set externally
if (Sys.getenv("OMOPHUB_API_KEY") == "" && Sys.getenv("TEST_API_KEY") == "") {
  Sys.setenv(OMOPHUB_API_KEY = "test_api_key_for_mocking")
}

# Helper to skip tests that require real API
skip_if_no_auth <- function() {
  real_key <- Sys.getenv("OMOPHUB_API_KEY_REAL", unset = "")
  if (real_key == "" || real_key == "test_api_key_for_mocking") {
    testthat::skip("Real OMOPHUB_API_KEY not available")
  }
}

# Skip on CRAN and CI for integration tests
skip_on_cran_and_ci <- function() {
  testthat::skip_on_cran()
  if (Sys.getenv("CI") != "") {
    testthat::skip("Skipping on CI")
  }
}
