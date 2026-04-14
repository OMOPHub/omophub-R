#!/usr/bin/env Rscript
#' Example: FHIR Interop (omophub R SDK 1.7.0+)
#'
#' Demonstrates the 1.7.0 additions to the FHIR Concept Resolver:
#'
#'   1. Tibble output for batch resolution (as_tibble = TRUE)
#'   2. Standalone wrapper functions (fhir_resolve, fhir_resolve_batch,
#'      fhir_resolve_codeable_concept) for pipe-friendly workflows
#'   3. omophub_fhir_url() helper for configuring external FHIR clients
#'      (httr2, fhircrackr) to talk to the OMOPHub FHIR Terminology
#'      Service directly
#'
#' For the core Concept Resolver surface (single/batch/codeable-concept
#' resolution, recommendations, quality signals, error handling) see
#' inst/examples/fhir_resolver.R.
#'
#' Run with: Rscript inst/examples/fhir_interop.R

library(omophub)

# Null-coalescing operator (available in base R 4.4+; define locally for
# compatibility with the R >= 4.1 package requirement).
`%||%` <- function(a, b) if (is.null(a)) b else a

client <- OMOPHubClient$new()

cat("OMOPHub R Client - FHIR Interop Examples (1.7.0+)\n")
cat("==================================================\n\n")

# ============================================================================
# 1. Tibble output for batch resolution
# ============================================================================

cat("1. Tibble output for resolve_batch (as_tibble = TRUE)\n")
cat("-----------------------------------------------------\n")

tbl <- client$fhir$resolve_batch(
  list(
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "I10"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "J45.909"),
    list(system = "http://snomed.info/sct", code = "bogus-code")  # will fail
  ),
  as_tibble = TRUE
)

cat("  Tibble class:", paste(class(tbl), collapse = ", "), "\n")
cat("  Rows:        ", nrow(tbl), "\n")
cat("  Columns:     ", paste(names(tbl), collapse = ", "), "\n\n")

# Print per-row summary
for (i in seq_len(nrow(tbl))) {
  row <- tbl[i, ]
  if (row$status == "resolved") {
    cat(sprintf("  [%d] %s -> %s (%s)\n",
                i, row$source_code, row$standard_concept_name, row$target_table))
  } else {
    cat(sprintf("  [%d] %s -> FAILED (%s)\n",
                i, row$source_code, row$status_detail))
  }
}
cat("\n")

# Summary attached as attribute
summary_info <- attr(tbl, "summary")
cat(sprintf("  Summary: total=%d resolved=%d failed=%d\n",
            summary_info$total, summary_info$resolved, summary_info$failed))
cat("\n")

# dplyr-friendly filtering (optional - commented out to avoid forcing dplyr)
#
# library(dplyr)
# tbl |>
#   filter(status == "resolved") |>
#   select(source_code, standard_concept_name, target_table)

# Default as_tibble = FALSE still returns the legacy list shape
list_result <- client$fhir$resolve_batch(
  list(list(system = "http://snomed.info/sct", code = "44054006"))
)
cat("  as_tibble = FALSE still returns list:",
    paste(class(list_result), collapse = ", "), "\n\n")

# ============================================================================
# 2. Standalone wrapper functions
# ============================================================================

cat("2. Standalone wrapper functions\n")
cat("-------------------------------\n")

# fhir_resolve(client, ...) is equivalent to client$fhir$resolve(...)
result <- fhir_resolve(
  client,
  system = "http://snomed.info/sct",
  code = "44054006",
  resource_type = "Condition"
)
cat("  fhir_resolve: ", result$resolution$standard_concept$concept_name, "\n")

# Pipe-friendly form
result_piped <- client |>
  fhir_resolve(
    system = "http://snomed.info/sct",
    code = "44054006",
    resource_type = "Condition"
  )
cat("  Pipe form:   ", result_piped$resolution$standard_concept$concept_name, "\n")

# Batch wrapper
tbl2 <- client |>
  fhir_resolve_batch(
    codings = list(
      list(system = "http://snomed.info/sct", code = "44054006"),
      list(system = "http://loinc.org", code = "2339-0")
    ),
    as_tibble = TRUE
  )
cat("  fhir_resolve_batch: ", nrow(tbl2), "rows\n")

# CodeableConcept wrapper
cc_result <- client |>
  fhir_resolve_codeable_concept(
    coding = list(
      list(system = "http://snomed.info/sct", code = "44054006"),
      list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
    ),
    resource_type = "Condition"
  )
cat(sprintf("  fhir_resolve_codeable_concept: best = [%s]\n",
            cc_result$best_match$resolution$source_concept$vocabulary_id))
cat("\n")

# ============================================================================
# 3. omophub_fhir_url() for external FHIR client interop
# ============================================================================

cat("3. omophub_fhir_url() helper\n")
cat("----------------------------\n")

# Default R4 base URL
cat("  R4:  ", omophub_fhir_url(), "\n")
cat("  R4B: ", omophub_fhir_url("r4b"), "\n")
cat("  R5:  ", omophub_fhir_url("r5"), "\n")
cat("  R6:  ", omophub_fhir_url("r6"), "\n\n")

# ============================================================================
# 4. Direct httr2 call against OMOPHub's FHIR Terminology Service
# ============================================================================

cat("4. Direct httr2 call to CodeSystem/$lookup\n")
cat("------------------------------------------\n")

# Use the Concept Resolver (fhir_resolve) when you want OMOP-enriched
# answers (standard concept, CDM target table, mapping quality).
# Use omophub_fhir_url() + httr2 when you need raw FHIR Parameters /
# Bundle responses for FHIR-native tooling.

api_key <- Sys.getenv("OMOPHUB_API_KEY")
if (nzchar(api_key)) {
  resp <- httr2::request(omophub_fhir_url()) |>
    httr2::req_url_path_append("CodeSystem/$lookup") |>
    httr2::req_url_query(
      system = "http://snomed.info/sct",
      code = "44054006"
    ) |>
    httr2::req_headers(Authorization = paste("Bearer", api_key)) |>
    httr2::req_perform()

  params <- httr2::resp_body_json(resp)

  # Extract the display from the Parameters resource
  display <- NULL
  for (p in params$parameter %||% list()) {
    if (!is.null(p$name) && p$name == "display") {
      display <- p$valueString
      break
    }
  }
  cat("  $lookup display:", display %||% "(not found)", "\n")
} else {
  cat("  Skipped: OMOPHUB_API_KEY not set\n")
}
cat("\n")

cat("Done!\n")
