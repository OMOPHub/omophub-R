#!/usr/bin/env Rscript
#' Example: Map Between Vocabularies
#'
#' Demonstrates vocabulary mapping operations:
#' - Getting mappings for a single concept
#' - Batch mapping multiple concepts
#' - Looking up concepts by vocabulary code
#' - Understanding mapping quality scores
#'
#' Run with: Rscript inst/examples/map_between_vocabularies.R

library(omophub)

# Null-coalescing operator (available in base R 4.4+; define locally for
# compatibility with the R >= 4.1 package requirement).
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================================
# Setup
# ============================================================================

client <- OMOPHubClient$new()

cat("OMOPHub R Client - Vocabulary Mapping Examples\n")
cat("===============================================\n\n")

# Type 2 diabetes mellitus (SNOMED)
DIABETES_CONCEPT_ID <- 201826

# ============================================================================
# Get Mappings for a Single Concept
# ============================================================================

cat("1. Getting mappings for a SNOMED concept\n")
cat("-----------------------------------------\n")

# One page of mappings for Type 2 diabetes. `get()` is NOT the whole set --
# read attr(mappings, "pagination") or use get_all(), shown in section 3.
mappings <- client$mappings$get(DIABETES_CONCEPT_ID)
pag <- attr(mappings, "pagination")

cat(sprintf("Mappings for concept %d (Type 2 diabetes mellitus):\n", DIABETES_CONCEPT_ID))
if (!is.null(pag)) {
  cat(sprintf("  page %s of %s, %s in total\n",
              pag$page, pag$total_pages, pag$total_items))
}
for (m in mappings$mappings) {
  # This endpoint projects each row down to source/target id + name,
  # relationship_id and confidence. Vocabulary id and concept code are not
  # included -- resolve them with client$concepts$get(target_concept_id),
  # as section 2 does. (client$mappings$map() does return them.)
  cat(sprintf("  %s: %s %s\n",
              m$relationship_id, m$target_concept_id, m$target_concept_name))
}
cat("\n")

# ============================================================================
# Mapping to a Specific Vocabulary -- Mind the Direction
# ============================================================================

cat("2. Which ICD-10-CM codes correspond to this concept\n")
cat("---------------------------------------------------\n")

# `Maps to` always points at a *standard* concept, and ICD-10-CM is
# non-standard, so filtering the default relationship to ICD10CM matches
# nothing -- an empty list, not an error. The codes that roll up INTO a
# standard concept are reached with `Mapped from`.
empty <- client$mappings$get(
  DIABETES_CONCEPT_ID,
  target_vocabulary = "ICD10CM"
)
cat(sprintf("  'Maps to' + ICD10CM:     %d rows (as expected)\n",
            length(empty$mappings)))

icd_mappings <- client$mappings$get_all(
  DIABETES_CONCEPT_ID,
  relationship_ids = "Mapped from",
  target_vocabulary = "ICD10CM",
  progress = FALSE
)
cat(sprintf("  'Mapped from' + ICD10CM: %d rows\n", nrow(icd_mappings)))

# The mapping row has the target's id and name but not its code, so resolve
# the first few. One request each -- fine for five rows, not for all 74.
for (i in seq_len(min(5, nrow(icd_mappings)))) {
  target <- client$concepts$get(icd_mappings$target_concept_id[i])
  cat(sprintf("    <- [%s] %s %s\n",
              target$vocabulary_id, target$concept_code, target$concept_name))
}
cat("\n")

# ============================================================================
# Get Every Mapping, Across All Pages
# ============================================================================

cat("3. Every mapping, not just the first page\n")
cat("------------------------------------------\n")

# Copy this one when building a code list: a partial code list is wrong in a
# way nothing in the result reveals.
all_mappings <- client$mappings$get_all(DIABETES_CONCEPT_ID, progress = FALSE)
cat(sprintf("Retrieved %d mappings in total\n\n", nrow(all_mappings)))

# ============================================================================
# Value-as-Concept: Composite Concepts Decompose Across Two Relationships
# ============================================================================

cat("4. Value-as-Concept\n")
cat("-------------------\n")

# The default returns "Maps to" only, so you learn the patient is allergic to
# *a drug* but not *which* drug.
PENICILLIN_ALLERGY_ID <- 4167462
decomposed <- client$mappings$get(
  PENICILLIN_ALLERGY_ID,
  relationship_ids = c("Maps to", "Maps to value")
)

for (m in decomposed$mappings) {
  # "Maps to" -> the OMOP concept column; "Maps to value" -> value_as_concept_id
  column <- if (identical(m$relationship_id, "Maps to value")) {
    "value_as_concept_id"
  } else {
    "concept_id"
  }
  cat(sprintf("  %s: %s -> %s\n",
              m$relationship_id, m$target_concept_name, column))
}
cat("\n")

# ============================================================================
# Excluding Invalid/Deprecated Mappings
# ============================================================================

cat("5. Dropping deprecated mappings\n")
cat("-------------------------------\n")

# Deprecated mappings are returned BY DEFAULT on this endpoint. FALSE is the
# meaningful direction; omitting the argument keeps them.
valid_only <- client$mappings$get_all(
  DIABETES_CONCEPT_ID,
  include_invalid = FALSE,
  progress = FALSE
)
cat(sprintf("  default (includes deprecated): %d\n", nrow(all_mappings)))
cat(sprintf("  include_invalid = FALSE:       %d\n\n", nrow(valid_only)))

# ============================================================================
# Batch Mapping Multiple Concepts
# ============================================================================

cat("6. Batch mapping multiple concepts\n")
cat("----------------------------------\n")

# Map multiple SNOMED concepts to ICD-10-CM
concept_ids <- c(
  201826,   # Type 2 diabetes mellitus
  320128,   # Essential hypertension
  4329847   # Myocardial infarction
)

batch_result <- client$mappings$map(
  target_vocabulary = "ICD10CM",
  source_concepts = concept_ids
)

cat("Batch mapping results:\n")
mapping_list <- batch_result$mappings %||% batch_result$data %||% batch_result
for (m in mapping_list) {
  source <- m$source_concept %||% m
  source_name <- source$concept_name %||% m$source_concept_name %||% "Unknown"

  targets <- m$target_concepts %||% m$targets %||% list(m$target_concept %||% m)

  cat(sprintf("\n  %s:\n", source_name))
  for (t in targets) {
    cat(sprintf("    -> %s (%s)\n",
                t$concept_name %||% "Unknown",
                t$concept_code %||% "?"))
  }
}

# Print coverage summary if available
if (!is.null(batch_result$summary)) {
  cat(sprintf("\nCoverage: %d/%d concepts mapped\n",
              batch_result$summary$mapped_count %||% 0,
              batch_result$summary$total_count %||% length(concept_ids)))
}
cat("\n")

# ============================================================================
# Lookup Concept by Vocabulary Code
# ============================================================================

cat("7. Looking up concepts by code\n")
cat("------------------------------\n")

# Look up ICD-10-CM code E11 (Type 2 diabetes mellitus)
icd_concept <- client$concepts$get_by_code("ICD10CM", "E11")

cat("ICD-10-CM E11:\n")
cat(sprintf("  Concept ID: %d\n", icd_concept$concept_id))
cat(sprintf("  Name: %s\n", icd_concept$concept_name))
cat(sprintf("  Domain: %s\n", icd_concept$domain_id))
cat(sprintf("  Standard: %s\n", icd_concept$standard_concept))
cat("\n")

# Look up SNOMED code
snomed_concept <- client$concepts$get_by_code("SNOMED", "44054006")

cat("SNOMED 44054006:\n")
cat(sprintf("  Concept ID: %d\n", snomed_concept$concept_id))
cat(sprintf("  Name: %s\n", snomed_concept$concept_name))
cat(sprintf("  Domain: %s\n", snomed_concept$domain_id))
cat("\n")

# ============================================================================
# Mapping with Specific Vocabulary Release
# ============================================================================

cat("8. Mapping with specific vocabulary release\n")
cat("-------------------------------------------\n")

# Get mappings from a specific vocabulary release version
# This is useful for reproducibility and working with specific data versions
versioned_mappings <- client$mappings$get(
  DIABETES_CONCEPT_ID,
  vocab_release = "2025.1"
)

cat("Mappings from vocabulary release 2025.1:\n")
cat(sprintf("  Found %d mappings\n", length(versioned_mappings$mappings)))
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
