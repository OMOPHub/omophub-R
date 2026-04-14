#!/usr/bin/env Rscript
#' Example: FHIR-to-OMOP Concept Resolver
#'
#' Demonstrates the FHIR Concept Resolver, which translates FHIR coded
#' values (system URI + code) into OMOP standard concepts, CDM target
#' tables, and optional Phoebe recommendations - all in a single API call.
#'
#' Covers:
#'   - Direct standard lookups (SNOMED, LOINC, RxNorm)
#'   - Non-standard code mapping (ICD-10-CM -> SNOMED via "Maps to")
#'   - Text-only semantic search fallback
#'   - Vocabulary ID bypass (skip URI resolution)
#'   - Phoebe recommendations
#'   - Mapping quality signal
#'   - Batch resolution
#'   - CodeableConcept resolution with OHDSI vocabulary preference
#'   - Error handling
#'
#' For tibble-shaped batch output, standalone wrapper functions, and the
#' omophub_fhir_url() helper, see inst/examples/fhir_interop.R.
#'
#' Run with: Rscript inst/examples/fhir_resolver.R

library(omophub)

# Null-coalescing operator (available in base R 4.4+; define locally for
# compatibility with the R >= 4.1 package requirement).
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================================
# Setup
# ============================================================================

client <- OMOPHubClient$new()

cat("OMOPHub R Client - FHIR Resolver Examples\n")
cat("==========================================\n\n")

# ============================================================================
# 1. Direct SNOMED Resolution
# ============================================================================

cat("1. SNOMED direct resolution\n")
cat("---------------------------\n")

result <- client$fhir$resolve(
  system = "http://snomed.info/sct",
  code = "44054006",
  resource_type = "Condition"
)
res <- result$resolution
cat("  Source:      ", res$source_concept$concept_name, "\n")
cat("  Standard:    ", res$standard_concept$concept_name, "\n")
cat("  Mapping type:", res$mapping_type, "\n")
cat("  Target table:", res$target_table, "\n")
cat("  Alignment:   ", res$domain_resource_alignment, "\n\n")

# ============================================================================
# 2. ICD-10-CM -> SNOMED via Maps to
# ============================================================================

cat("2. Non-standard code with Maps-to traversal\n")
cat("-------------------------------------------\n")

result <- client$fhir$resolve(
  system = "http://hl7.org/fhir/sid/icd-10-cm",
  code = "E11.9",
  resource_type = "Condition"
)
res <- result$resolution
cat("  Source:      [", res$source_concept$vocabulary_id, "] ",
    res$source_concept$concept_name, "\n", sep = "")
cat("  Standard:    [", res$standard_concept$vocabulary_id, "] ",
    res$standard_concept$concept_name, "\n", sep = "")
cat("  Mapping type:", res$mapping_type, "\n")
cat("  Relationship:", res$relationship_id %||% "N/A", "\n")
cat("  Target table:", res$target_table, "\n\n")

# ============================================================================
# 3. LOINC -> measurement table
# ============================================================================

cat("3. LOINC lab code -> measurement table\n")
cat("--------------------------------------\n")

result <- client$fhir$resolve(
  system = "http://loinc.org",
  code = "2339-0",  # Glucose [Mass/volume] in Blood
  resource_type = "Observation"
)
res <- result$resolution
cat("  Concept:     ", res$standard_concept$concept_name, "\n")
cat("  Domain:      ", res$standard_concept$domain_id, "\n")
cat("  Target table:", res$target_table, "\n\n")

# ============================================================================
# 4. RxNorm -> drug_exposure table
# ============================================================================

cat("4. RxNorm drug code -> drug_exposure table\n")
cat("------------------------------------------\n")

result <- client$fhir$resolve(
  system = "http://www.nlm.nih.gov/research/umls/rxnorm",
  code = "197696",  # Acetaminophen 325 MG Oral Tablet
  resource_type = "MedicationRequest"
)
res <- result$resolution
cat("  Concept:     ", res$standard_concept$concept_name, "\n")
cat("  Target table:", res$target_table, "\n\n")

# ============================================================================
# 5. Text-only resolution (semantic search fallback)
# ============================================================================

cat("5. Text-only semantic search fallback\n")
cat("-------------------------------------\n")

result <- client$fhir$resolve(
  display = "Blood Sugar",
  resource_type = "Observation"
)
res <- result$resolution
cat("  Matched:     ", res$standard_concept$concept_name, "\n")
cat("  Mapping type:", res$mapping_type, "\n")
if (!is.null(res$similarity_score)) {
  cat("  Similarity:  ", sprintf("%.2f", res$similarity_score), "\n")
}
cat("  Target table:", res$target_table, "\n\n")

# ============================================================================
# 6. Vocabulary ID bypass (skip URI resolution)
# ============================================================================

cat("6. Vocabulary ID bypass\n")
cat("-----------------------\n")

result <- client$fhir$resolve(
  vocabulary_id = "ICD10CM",
  code = "E11.9"
)
res <- result$resolution
cat("  Vocabulary:  ", res$vocabulary_id, "\n")
cat("  Standard:    ", res$standard_concept$concept_name, "\n\n")

# ============================================================================
# 7. Include Phoebe recommendations
# ============================================================================

cat("7. With Phoebe recommendations\n")
cat("------------------------------\n")

result <- client$fhir$resolve(
  system = "http://snomed.info/sct",
  code = "44054006",
  include_recommendations = TRUE,
  recommendations_limit = 5L
)
res <- result$resolution
cat("  Resolved:    ", res$standard_concept$concept_name, "\n")
recs <- res$recommendations %||% list()
cat("  Recommendations (", length(recs), "):\n", sep = "")
for (rec in recs) {
  cat(sprintf("    - %s (%s) via %s\n",
              rec$concept_name, rec$domain_id, rec$relationship_id))
}
cat("\n")

# ============================================================================
# 8. Mapping quality signal
# ============================================================================

cat("8. With mapping quality signal\n")
cat("------------------------------\n")

result <- client$fhir$resolve(
  system = "http://snomed.info/sct",
  code = "44054006",
  include_quality = TRUE
)
cat("  SNOMED direct -> quality:",
    result$resolution$mapping_quality %||% "N/A", "\n")

result <- client$fhir$resolve(
  display = "heart attack",
  resource_type = "Condition",
  include_quality = TRUE
)
cat("  Text semantic -> quality:",
    result$resolution$mapping_quality %||% "N/A", "\n\n")

# ============================================================================
# 9. Batch resolution
# ============================================================================

cat("9. Batch resolution\n")
cat("-------------------\n")

batch <- client$fhir$resolve_batch(
  list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://loinc.org", code = "2339-0"),
    list(system = "http://www.nlm.nih.gov/research/umls/rxnorm", code = "197696"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
  ),
  resource_type = "Condition",
  include_quality = TRUE
)

cat(sprintf("  Total: %d, Resolved: %d, Failed: %d\n",
            batch$summary$total, batch$summary$resolved, batch$summary$failed))

for (i in seq_along(batch$results)) {
  item <- batch$results[[i]]
  if (!is.null(item$resolution)) {
    res <- item$resolution
    cat(sprintf("  [%d] %s -> %s (quality: %s)\n",
                i, res$standard_concept$concept_name, res$target_table,
                res$mapping_quality %||% "N/A"))
  } else {
    cat(sprintf("  [%d] FAILED: %s\n", i, item$error$code %||% "unknown"))
  }
}
cat("\n")

# ============================================================================
# 10. CodeableConcept with vocabulary preference
# ============================================================================

cat("10. CodeableConcept resolution (OHDSI preference)\n")
cat("-------------------------------------------------\n")

result <- client$fhir$resolve_codeable_concept(
  coding = list(
    list(
      system = "http://hl7.org/fhir/sid/icd-10-cm",
      code = "E11.9",
      display = "Type 2 diabetes mellitus without complications"
    ),
    list(
      system = "http://snomed.info/sct",
      code = "44054006",
      display = "Type 2 diabetes mellitus"
    )
  ),
  resource_type = "Condition",
  include_recommendations = TRUE,
  recommendations_limit = 3L
)

best <- result$best_match
if (!is.null(best)) {
  res <- best$resolution
  cat(sprintf("  Best match: [%s] %s\n",
              res$source_concept$vocabulary_id,
              res$standard_concept$concept_name))
  cat("  Target table:", res$target_table, "\n")
}
cat("  Alternatives:", length(result$alternatives), "\n")
cat("  Unresolved:  ", length(result$unresolved), "\n\n")

# ============================================================================
# 11. CodeableConcept text fallback
# ============================================================================

cat("11. CodeableConcept text fallback\n")
cat("---------------------------------\n")

result <- client$fhir$resolve_codeable_concept(
  coding = list(
    # Bogus code - will fail; text fallback should pick it up
    list(system = "http://loinc.org", code = "99999-9")
  ),
  text = "Type 2 diabetes mellitus",
  resource_type = "Condition"
)

best <- result$best_match
if (!is.null(best)) {
  res <- best$resolution
  cat("  Resolved via:", res$mapping_type, "\n")
  cat("  Concept:    ", res$standard_concept$concept_name, "\n")
}
cat("  Failed codings:", length(result$unresolved), "\n\n")

# ============================================================================
# 12. Error handling
# ============================================================================

cat("12. Error handling\n")
cat("------------------\n")

# Restricted vocabulary (CPT4) -> 403
tryCatch(
  client$fhir$resolve(
    system = "http://www.ama-assn.org/go/cpt",
    code = "99213"
  ),
  omophub_api_error = function(e) {
    cat(sprintf("  CPT4 restricted -> %s: %s\n",
                e$status_code %||% "?", e$message %||% e$parent$message))
  },
  error = function(e) {
    cat("  CPT4 restricted -> error:", conditionMessage(e), "\n")
  }
)

# Non-existent code -> 404
tryCatch(
  client$fhir$resolve(
    system = "http://snomed.info/sct",
    code = "00000000"
  ),
  omophub_not_found = function(e) {
    cat("  Non-existent code -> not found:", e$message, "\n")
  },
  omophub_api_error = function(e) {
    cat(sprintf("  Non-existent code -> %s: %s\n",
                e$status_code %||% "?", e$message %||% e$parent$message))
  },
  error = function(e) {
    cat("  Non-existent code -> error:", conditionMessage(e), "\n")
  }
)
cat("\n")

cat("Done!\n")
