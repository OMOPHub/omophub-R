#!/usr/bin/env Rscript
#' Example: Error Handling
#'
#' Demonstrates error handling strategies:
#' - Handling not found errors (404)
#' - Authentication errors
#' - Validation errors
#' - Rate limiting
#' - Using tryCatch() patterns
#'
#' Run with: Rscript inst/examples/error_handling.R

library(omophub)

# ============================================================================
# Setup
# ============================================================================

cat("OMOPHub R Client - Error Handling Examples\n")
cat("==========================================\n\n")

# ============================================================================
# Basic tryCatch Pattern
# ============================================================================

cat("1. Basic error handling with tryCatch\n")
cat("-------------------------------------\n")

# Initialize client
client <- omophub()

# Try to get a concept that doesn't exist
tryCatch(
  {
    concept <- client$concepts$get(999999999)  # Non-existent ID
    cat("Concept found:", concept$concept_name, "\n")
  },
  omophub_error = function(e) {
    cat("OMOPHub Error:\n")
    cat("  Message:", conditionMessage(e), "\n")
    if (!is.null(e$status_code)) {
      cat("  Status code:", e$status_code, "\n")
    }
  },
  error = function(e) {
    cat("General error:", conditionMessage(e), "\n")
  }
)
cat("\n")

# ============================================================================
# Handling Specific Error Types
# ============================================================================

cat("2. Handling specific error types\n")
cat("--------------------------------\n")

# Not Found Error (404)
cat("Testing 404 Not Found:\n")
tryCatch(
  {
    concept <- client$concepts$get(999999999)
  },
  omophub_not_found_error = function(e) {
    cat("  Concept not found (404)\n")
    cat("  Message:", conditionMessage(e), "\n")
  },
  omophub_error = function(e) {
    cat("  Other OMOPHub error:", conditionMessage(e), "\n")
  }
)

# Validation Error (400)
cat("\nTesting validation error:\n")
tryCatch(
  {
    # Empty query should fail validation
    results <- client$search$basic("")
  },
  omophub_validation_error = function(e) {
    cat("  Validation error (400)\n")
    cat("  Message:", conditionMessage(e), "\n")
  },
  omophub_error = function(e) {
    cat("  OMOPHub error:", conditionMessage(e), "\n")
  },
  error = function(e) {
    cat("  Error:", conditionMessage(e), "\n")
  }
)
cat("\n")

# ============================================================================
# Authentication Errors
# ============================================================================

cat("3. Handling authentication errors\n")
cat("---------------------------------\n")

# Try with invalid API key
tryCatch(
  {
    bad_client <- omophub(api_key = "oh_invalid_key_12345")
    concept <- bad_client$concepts$get(201826)
  },
  omophub_auth_error = function(e) {
    cat("  Authentication failed (401/403)\n")
    cat("  Message:", conditionMessage(e), "\n")
    cat("  Solution: Check your API key\n")
  },
  omophub_error = function(e) {
    cat("  OMOPHub error:", conditionMessage(e), "\n")
  },
  error = function(e) {
    cat("  Error:", conditionMessage(e), "\n")
  }
)
cat("\n")

# ============================================================================
# Retry Pattern for Rate Limiting
# ============================================================================

cat("4. Retry pattern for rate limiting\n")
cat("----------------------------------\n")

# Function that retries on rate limit
fetch_with_retry <- function(client, concept_id, max_retries = 3) {
  for (attempt in seq_len(max_retries)) {
    tryCatch(
      {
        concept <- client$concepts$get(concept_id)
        return(concept)
      },
      omophub_rate_limit_error = function(e) {
        retry_after <- e$retry_after %||% 60
        cat(sprintf("  Rate limited. Retry after %d seconds (attempt %d/%d)\n",
                    retry_after, attempt, max_retries))
        if (attempt < max_retries) {
          Sys.sleep(min(retry_after, 5))  # Cap at 5 seconds for demo
        } else {
          stop("Max retries exceeded")
        }
      }
    )
  }
  stop("Failed after all retries")
}

# Demo (won't actually hit rate limit in normal usage)
cat("Fetching with retry logic...\n")
tryCatch(
  {
    concept <- fetch_with_retry(client, 201826)
    cat("  Success! Got:", concept$concept_name, "\n")
  },
  error = function(e) {
    cat("  Error:", conditionMessage(e), "\n")
  }
)
cat("\n")

# ============================================================================
# Graceful Degradation Pattern
# ============================================================================

cat("5. Graceful degradation pattern\n")
cat("-------------------------------\n")

# Function that returns NULL on error instead of failing
safe_get_concept <- function(client, concept_id) {
  tryCatch(
    {
      client$concepts$get(concept_id)
    },
    omophub_not_found_error = function(e) {
      message("Concept ", concept_id, " not found, returning NULL")
      NULL
    },
    omophub_error = function(e) {
      message("API error for concept ", concept_id, ": ", conditionMessage(e))
      NULL
    },
    error = function(e) {
      message("Error fetching concept ", concept_id, ": ", conditionMessage(e))
      NULL
    }
  )
}

# Try to fetch multiple concepts, some may not exist
concept_ids <- c(201826, 999999999, 320128)
cat("Fetching concepts with graceful degradation:\n")

for (id in concept_ids) {
  concept <- safe_get_concept(client, id)
  if (!is.null(concept)) {
    cat(sprintf("  [%d] %s\n", id, concept$concept_name))
  } else {
    cat(sprintf("  [%d] (not found or error)\n", id))
  }
}
cat("\n")

# ============================================================================
# Batch Error Handling
# ============================================================================

cat("6. Handling errors in batch operations\n")
cat("--------------------------------------\n")

# When doing batch operations, some items may fail
process_concepts <- function(client, concept_ids) {
  results <- list()
  errors <- list()

  for (id in concept_ids) {
    tryCatch(
      {
        concept <- client$concepts$get(id)
        results[[as.character(id)]] <- concept
      },
      error = function(e) {
        errors[[as.character(id)]] <<- conditionMessage(e)
      }
    )
  }

  list(
    results = results,
    errors = errors,
    success_count = length(results),
    error_count = length(errors)
  )
}

batch_ids <- c(201826, 999999999, 320128, 888888888, 4329847)
cat("Processing batch of", length(batch_ids), "concepts:\n")

batch_result <- process_concepts(client, batch_ids)
cat(sprintf("  Successful: %d\n", batch_result$success_count))
cat(sprintf("  Failed: %d\n", batch_result$error_count))

if (batch_result$error_count > 0) {
  cat("  Failed IDs:", paste(names(batch_result$errors), collapse = ", "), "\n")
}
cat("\n")

# ============================================================================
# Error Information Extraction
# ============================================================================

cat("7. Extracting error details\n")
cat("---------------------------\n")

tryCatch(
  {
    concept <- client$concepts$get(999999999)
  },
  omophub_error = function(e) {
    cat("Error details:\n")
    cat("  Class:", paste(class(e), collapse = ", "), "\n")
    cat("  Message:", conditionMessage(e), "\n")

    # Additional details if available
    if (!is.null(e$status_code)) {
      cat("  HTTP Status:", e$status_code, "\n")
    }
    if (!is.null(e$request_id)) {
      cat("  Request ID:", e$request_id, "\n")
    }
    if (!is.null(e$details)) {
      cat("  Details:", e$details, "\n")
    }
  }
)
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
