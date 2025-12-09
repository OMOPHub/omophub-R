# Integration test helpers and constants for omophub package
# These are loaded automatically by testthat before tests run

# Import null coalescing operator from rlang for test use
`%||%` <- rlang::`%||%`

# Well-known test concept IDs for integration tests
DIABETES_CONCEPT_ID <- 201826L    # Type 2 diabetes mellitus (SNOMED)
ASPIRIN_CONCEPT_ID <- 1112807L    # Aspirin (RxNorm)
MI_CONCEPT_ID <- 4329847L         # Myocardial infarction (SNOMED)
HYPERTENSION_CONCEPT_ID <- 316866L  # Hypertensive disorder (SNOMED)
DIABETES_PARENT_ID <- 201820L     # Diabetes mellitus (parent of Type 2)

#' Skip if integration API key is not available
#'
#' Checks for OMOPHUB_API_KEY or TEST_API_KEY in environment.
#' Skips the test if neither is set.
#'
#' @keywords internal
skip_if_no_integration_key <- function() {
  key <- get_integration_api_key()
  if (is.null(key) || key == "" || key == "test_api_key_for_mocking") {
    testthat::skip("Integration API key not available (set OMOPHUB_API_KEY or TEST_API_KEY)")
  }
}

#' Get API key for integration tests
#'
#' Checks TEST_API_KEY first, then OMOPHUB_API_KEY.
#'
#' @returns API key string or NULL if not set
#' @keywords internal
get_integration_api_key <- function() {
  # Check TEST_API_KEY first (explicit test key), then OMOPHUB_API_KEY
  key <- Sys.getenv("TEST_API_KEY", unset = "")
  if (key != "") return(key)

  key <- Sys.getenv("OMOPHUB_API_KEY", unset = "")
  if (key != "" && key != "test_api_key_for_mocking") return(key)

  NULL
}

#' Create an integration test client
#'
#' Creates an OMOPHubClient configured for integration tests.
#' Skips the test if no API key is available.
#'
#' @returns An OMOPHubClient object
#' @keywords internal
integration_client <- function() {
  skip_if_no_integration_key()
  key <- get_integration_api_key()
  Sys.sleep(1)  # Rate limit delay between tests
  OMOPHubClient$new(api_key = key)
}

#' Safely extract data from API response
#'
#' Handles both old format (direct array) and new format (wrapped in named key).
#'
#' @param result API response, either a list or named list with data
#' @param key The key to extract (e.g., "concepts", "vocabularies", "suggestions")
#' @returns The extracted list of items, always a list
#' @keywords internal
extract_data <- function(result, key) {
  if (is.null(result)) return(list())

  # If result is already a data.frame/tibble, return it as-is
  if (is.data.frame(result)) return(result)

  # If it's a list with the key, extract it
  if (is.list(result) && !is.data.frame(result)) {
    # Check for the requested key
    if (key %in% names(result)) {
      return(result[[key]])
    }

    # Fallback: check 'results' key for batch endpoint backward compatibility
    if (key == "concepts" && "results" %in% names(result)) {
      return(result[["results"]])
    }

    # If it's an unnamed list (array), return as-is
    if (is.null(names(result)) || all(names(result) == "")) {
      return(result)
    }

    # Check if the result has a 'data' wrapper
    if ("data" %in% names(result)) {
      data <- result[["data"]]
      if (is.list(data) && key %in% names(data)) {
        return(data[[key]])
      }
      return(data)
    }
  }

  # Return empty list if extraction failed
  list()
}

#' Load .env file if it exists
#'
#' Attempts to load environment variables from .env file.
#'
#' @keywords internal
load_env_file <- function() {
  env_paths <- c(
    ".env",
    "../.env",
    "../../.env",
    file.path(testthat::test_path(), "..", "..", ".env")
  )

  for (path in env_paths) {
    if (file.exists(path)) {
      lines <- readLines(path, warn = FALSE)
      for (line in lines) {
        # Skip comments and empty lines
        if (grepl("^\\s*#", line) || grepl("^\\s*$", line)) next
        # Parse KEY=VALUE
        parts <- strsplit(line, "=", fixed = TRUE)[[1]]
        if (length(parts) >= 2) {
          key <- trimws(parts[1])
          value <- trimws(paste(parts[-1], collapse = "="))
          # Remove quotes if present
          value <- gsub("^['\"]|['\"]$", "", value)
          if (Sys.getenv(key) == "") {
            Sys.setenv(key = value)
            do.call(Sys.setenv, stats::setNames(list(value), key))
          }
        }
      }
      break
    }
  }
}

# Load .env file on helper load
load_env_file()
