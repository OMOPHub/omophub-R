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

# ============================================================================
# Setup
# ============================================================================

client <- omophub()

cat("OMOPHub R Client - Vocabulary Mapping Examples\n")
cat("===============================================\n\n")

# Type 2 diabetes mellitus (SNOMED)
DIABETES_CONCEPT_ID <- 201826

# ============================================================================
# Get Mappings for a Single Concept
# ============================================================================

cat("1. Getting mappings for a SNOMED concept\n")
cat("-----------------------------------------\n")

# Get all mappings for Type 2 diabetes
mappings <- client$mappings$get(DIABETES_CONCEPT_ID)

cat(sprintf("Mappings for concept %d (Type 2 diabetes mellitus):\n", DIABETES_CONCEPT_ID))
mapping_list <- mappings$mappings %||% mappings$data %||% mappings
for (m in mapping_list) {
  target <- m$target_concept %||% m
  cat(sprintf("  -> [%s] %s (%s)\n",
              target$concept_code %||% m$target_concept_code %||% "?",
              target$concept_name %||% m$target_concept_name %||% "Unknown",
              target$vocabulary_id %||% m$target_vocabulary_id %||% "?"))
}
cat("\n")

# ============================================================================
# Get Mappings to Specific Vocabulary
# ============================================================================

cat("2. Mapping to ICD-10-CM only\n")
cat("----------------------------\n")

# Get only ICD-10-CM mappings
icd_mappings <- client$mappings$get(
  DIABETES_CONCEPT_ID,
  target_vocabularies = c("ICD10CM")
)

cat("ICD-10-CM mappings for Type 2 diabetes:\n")
mapping_list <- icd_mappings$mappings %||% icd_mappings$data %||% icd_mappings
for (m in mapping_list) {
  target <- m$target_concept %||% m
  cat(sprintf("  %s - %s\n",
              target$concept_code %||% m$target_concept_code %||% "?",
              target$concept_name %||% m$target_concept_name %||% "Unknown"))
}
cat("\n")

# ============================================================================
# Get Mappings with Quality Information
# ============================================================================

cat("3. Mappings with quality scores\n")
cat("--------------------------------\n")

# Include mapping quality information
quality_mappings <- client$mappings$get(
  DIABETES_CONCEPT_ID,
  include_mapping_quality = TRUE
)

cat("Mappings with quality information:\n")
mapping_list <- quality_mappings$mappings %||% quality_mappings$data %||% quality_mappings
for (m in mapping_list) {
  target <- m$target_concept %||% m
  quality <- m$mapping_quality %||% m$quality %||% list()
  confidence <- quality$confidence_score %||% quality$score %||% "N/A"

  cat(sprintf("  [%s] %s\n",
              target$vocabulary_id %||% m$target_vocabulary_id %||% "?",
              target$concept_name %||% m$target_concept_name %||% "Unknown"))
  cat(sprintf("    Confidence: %s\n", confidence))
}
cat("\n")

# ============================================================================
# Batch Mapping Multiple Concepts
# ============================================================================

cat("4. Batch mapping multiple concepts\n")
cat("----------------------------------\n")

# Map multiple SNOMED concepts to ICD-10-CM
concept_ids <- c(
  201826,   # Type 2 diabetes mellitus
  320128,   # Essential hypertension
  4329847   # Myocardial infarction
)

batch_result <- client$mappings$map(
  source_concepts = concept_ids,
  target_vocabulary = "ICD10CM"
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

cat("5. Looking up concepts by code\n")
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
# Bidirectional Mapping Check
# ============================================================================

cat("6. Checking bidirectional mappings\n")
cat("-----------------------------------\n")

# Get outgoing mappings (from SNOMED to others)
outgoing <- client$mappings$get(
  DIABETES_CONCEPT_ID,
  direction = "outgoing"
)

cat("Outgoing mappings (SNOMED -> other):\n")
mapping_list <- outgoing$mappings %||% outgoing$data %||% outgoing
cat(sprintf("  Found %d outgoing mappings\n", length(mapping_list)))

# Get incoming mappings (from others to SNOMED)
incoming <- client$mappings$get(
  DIABETES_CONCEPT_ID,
  direction = "incoming"
)

cat("Incoming mappings (other -> SNOMED):\n")
mapping_list <- incoming$mappings %||% incoming$data %||% incoming
cat(sprintf("  Found %d incoming mappings\n", length(mapping_list)))
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
