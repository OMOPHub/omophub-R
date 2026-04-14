#!/usr/bin/env Rscript
#' Example: Error Handling
#'
#' Demonstrates error handling strategies for the omophub R SDK:
#'
#' - HTTP errors (404 Not Found, 401 Unauthorized, 429 Rate Limited) are
#'   raised as httr2 conditions (`httr2_http_404`, `httr2_http_401`,
#'   `httr2_http_429`). Catch them with their specific classes.
#' - Input validation errors raised before the HTTP call (empty query,
#'   invalid concept ID, bad pagination) use the `omophub_validation_error`
#'   class from the SDK's `abort_validation()` helper.
#' - Any error you don't specifically handle falls through to the base
#'   `error` handler.
#'
#' Run with: Rscript inst/examples/error_handling.R

library(omophub)

# Null-coalescing operator (available in base R 4.4+; define locally for
# compatibility with the R >= 4.1 package requirement).
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================================
# Setup
# ============================================================================

cat("OMOPHub R Client - Error Handling Examples\n")
cat("==========================================\n\n")

client <- OMOPHubClient$new()

# ============================================================================
# 1. 404 Not Found
# ============================================================================

cat("1. Handling 404 Not Found\n")
cat("-------------------------\n")

tryCatch(
  {
    concept <- client$concepts$get(999999999)  # Non-existent ID
    cat("Concept found:", concept$concept_name, "\n")
  },
  httr2_http_404 = function(e) {
    cat("  Not found (404)\n")
    cat("  Message:", conditionMessage(e), "\n")
  },
  error = function(e) {
    cat("  Unexpected error:", conditionMessage(e), "\n")
  }
)
cat("\n")

# ============================================================================
# 2. Validation errors raised BEFORE the HTTP call
# ============================================================================

cat("2. Handling validation errors (pre-request)\n")
cat("-------------------------------------------\n")

# Empty query - caught by the SDK's argument validator before any HTTP call
cat("  Empty search query:\n")
tryCatch(
  client$search$basic(""),
  omophub_validation_error = function(e) {
    cat("    validation error:", conditionMessage(e), "\n")
  },
  error = function(e) {
    cat("    error:", conditionMessage(e)[[1]], "\n")
  }
)

# Invalid concept ID type
cat("  Invalid concept ID:\n")
tryCatch(
  client$concepts$get("not-an-integer"),
  omophub_validation_error = function(e) {
    cat("    validation error:", conditionMessage(e), "\n")
  },
  error = function(e) {
    cat("    error:", conditionMessage(e)[[1]], "\n")
  }
)
cat("\n")

# ============================================================================
# 3. Authentication errors (401 / 403)
# ============================================================================

cat("3. Handling authentication errors (401 / 403)\n")
cat("---------------------------------------------\n")

tryCatch(
  {
    bad_client <- OMOPHubClient$new(api_key = "oh_invalid_key_12345")
    concept <- bad_client$concepts$get(201826)
  },
  httr2_http_401 = function(e) {
    cat("  Unauthorized (401): invalid API key\n")
    cat("  Message:", conditionMessage(e)[[1]], "\n")
  },
  httr2_http_403 = function(e) {
    cat("  Forbidden (403): API key lacks permission\n")
    cat("  Message:", conditionMessage(e)[[1]], "\n")
  },
  error = function(e) {
    cat("  Error:", conditionMessage(e)[[1]], "\n")
  }
)
cat("\n")

# ============================================================================
# 4. Retry pattern for rate limiting (429)
# ============================================================================

cat("4. Retry pattern for rate limiting\n")
cat("----------------------------------\n")

# Note: the SDK already retries 429 responses automatically via
# httr2::req_retry() with exponential backoff. This example shows the
# user-space retry pattern for cases where you want custom handling
# (e.g. logging each attempt, falling back after a cap).
fetch_with_retry <- function(client, concept_id, max_retries = 3) {
  for (attempt in seq_len(max_retries)) {
    result <- tryCatch(
      list(ok = TRUE, value = client$concepts$get(concept_id)),
      httr2_http_429 = function(e) {
        retry_after <- e$retry_after %||% 5L
        cat(sprintf(
          "  Rate limited. Retry after %ds (attempt %d/%d)\n",
          retry_after, attempt, max_retries
        ))
        Sys.sleep(min(retry_after, 5))
        list(ok = FALSE)
      }
    )
    if (isTRUE(result$ok)) return(result$value)
  }
  stop("Max retries exceeded")
}

cat("  Fetching with retry logic...\n")
tryCatch(
  {
    concept <- fetch_with_retry(client, 201826)
    cat("    Success:", concept$concept_name, "\n")
  },
  error = function(e) {
    cat("    Error:", conditionMessage(e)[[1]], "\n")
  }
)
cat("\n")

# ============================================================================
# 5. Graceful degradation pattern
# ============================================================================

cat("5. Graceful degradation\n")
cat("-----------------------\n")

# Function that returns a structured result instead of failing. The
# caller can distinguish "not found" from other error categories so
# downstream logging / reporting is honest about what went wrong.
safe_get_concept <- function(client, concept_id) {
  tryCatch(
    list(ok = TRUE, value = client$concepts$get(concept_id), reason = NA_character_),
    httr2_http_404 = function(e) {
      list(ok = FALSE, value = NULL, reason = "not found")
    },
    httr2_http = function(e) {
      list(
        ok = FALSE,
        value = NULL,
        reason = sprintf("HTTP error: %s", conditionMessage(e)[[1]])
      )
    },
    error = function(e) {
      list(
        ok = FALSE,
        value = NULL,
        reason = sprintf("error: %s", conditionMessage(e)[[1]])
      )
    }
  )
}

concept_ids <- c(201826, 999999999, 320128)
cat("  Fetching concepts with structured results:\n")
for (id in concept_ids) {
  result <- safe_get_concept(client, id)
  if (isTRUE(result$ok)) {
    cat(sprintf("    [%d] %s\n", id, result$value$concept_name))
  } else {
    cat(sprintf("    [%d] (%s)\n", id, result$reason))
  }
}
cat("\n")

# ============================================================================
# 6. Batch operations with error collection
# ============================================================================

cat("6. Batch operations with error collection\n")
cat("-----------------------------------------\n")

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
        errors[[as.character(id)]] <<- conditionMessage(e)[[1]]
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
cat(sprintf("  Processing batch of %d concepts:\n", length(batch_ids)))

batch_result <- process_concepts(client, batch_ids)
cat(sprintf("    Successful: %d\n", batch_result$success_count))
cat(sprintf("    Failed:     %d\n", batch_result$error_count))

if (batch_result$error_count > 0) {
  cat("    Failed IDs:", paste(names(batch_result$errors), collapse = ", "), "\n")
}

# For real batch-resolving many concepts at once, use client$concepts$batch()
# which sends a single HTTP request for up to 100 concepts and has a
# significantly smaller rate-limit footprint.
cat("\n")

# ============================================================================
# 7. Extracting error details from httr2 conditions
# ============================================================================

cat("7. Extracting error details from httr2 conditions\n")
cat("-------------------------------------------------\n")

tryCatch(
  client$concepts$get(999999999),
  httr2_http = function(e) {
    cat("  Class chain:", paste(head(class(e), 3), collapse = " -> "), "\n")
    cat("  Message:    ", conditionMessage(e)[[1]], "\n")

    # httr2 attaches the response object for deeper inspection
    if (!is.null(e$resp)) {
      cat("  HTTP status:", httr2::resp_status(e$resp), "\n")
      url <- httr2::resp_url(e$resp)
      if (!is.null(url)) cat("  URL:        ", url, "\n")
    }
  }
)
cat("\n")

cat("Done!\n")
