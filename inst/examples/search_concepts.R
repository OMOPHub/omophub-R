#!/usr/bin/env Rscript
#' Example: Search Concepts
#'
#' Demonstrates comprehensive search capabilities:
#' - Basic text search
#' - Filtered search (vocabulary, domain, standard_concept)
#' - Autocomplete/suggestions
#' - Pagination with basic_all()
#'
#' Run with: Rscript inst/examples/search_concepts.R

library(omophub)

# ============================================================================
# Setup
# ============================================================================

client <- omophub()

cat("OMOPHub R Client - Search Examples\n")
cat("===================================\n\n")

# ============================================================================
# Basic Search
# ============================================================================

cat("1. Basic text search\n")
cat("--------------------\n")

# Simple search for "diabetes"
results <- client$search$basic("diabetes", page_size = 5)

cat("Top 5 results for 'diabetes':\n")
concepts <- results$data %||% results$concepts %||% results
for (c in concepts) {
  cat(sprintf("  [%d] %s\n", c$concept_id, c$concept_name))
}
cat("\n")

# ============================================================================
# Filtered Search
# ============================================================================

cat("2. Filtered search\n")
cat("------------------\n")

# Search for diabetes in SNOMED vocabulary only
results <- client$search$basic(
  "diabetes",
  vocabulary_ids = c("SNOMED"),
  page_size = 5
)

cat("SNOMED diabetes concepts:\n")
concepts <- results$data %||% results$concepts %||% results
for (c in concepts) {
  cat(sprintf("  [%d] %s (%s)\n",
              c$concept_id,
              c$concept_name,
              c$concept_class_id))
}
cat("\n")

# Search for conditions only (by domain)
results <- client$search$basic(
  "hypertension",
  domain_ids = c("Condition"),
  standard_concept = "S",  # Standard concepts only
  page_size = 5
)

cat("Standard condition concepts for 'hypertension':\n")
concepts <- results$data %||% results$concepts %||% results
for (c in concepts) {
  cat(sprintf("  [%d] %s\n", c$concept_id, c$concept_name))
}
cat("\n")

# ============================================================================
# Search with Multiple Filters
# ============================================================================

cat("3. Multi-vocabulary search\n")
cat("--------------------------\n")

# Search across multiple vocabularies
results <- client$search$basic(
  "aspirin",
  vocabulary_ids = c("RxNorm", "SNOMED"),
  domain_ids = c("Drug"),
  page_size = 10
)

cat("Aspirin concepts from RxNorm and SNOMED:\n")
concepts <- results$data %||% results$concepts %||% results
for (c in concepts) {
  cat(sprintf("  [%d] %s (%s - %s)\n",
              c$concept_id,
              c$concept_name,
              c$vocabulary_id,
              c$concept_class_id))
}
cat("\n")

# ============================================================================
# Autocomplete / Suggestions
# ============================================================================

cat("4. Autocomplete suggestions\n")
cat("---------------------------\n")

# Get suggestions for partial text
suggestions <- client$concepts$suggest("diab", limit = 5)

cat("Suggestions for 'diab':\n")
suggestion_list <- suggestions$suggestions %||% suggestions
for (s in suggestion_list) {
  cat(sprintf("  %s\n", s$suggestion %||% s$concept_name %||% s))
}
cat("\n")

# ============================================================================
# Paginated Search (Fetch All Results)
# ============================================================================

cat("5. Fetching multiple pages of results\n")
cat("-------------------------------------\n")

# Use basic_all() to automatically paginate through results
# Note: max_pages limits total pages fetched
all_results <- client$search$basic_all(
  "metformin",
  vocabulary_ids = c("RxNorm"),
  page_size = 10,
  max_pages = 3,  # Limit to 3 pages for this example
  progress = FALSE
)

cat(sprintf("Fetched %d metformin concepts from RxNorm:\n", nrow(all_results)))
if (nrow(all_results) > 0) {
  # Show first 5
  for (i in seq_len(min(5, nrow(all_results)))) {
    cat(sprintf("  [%d] %s\n",
                all_results$concept_id[i],
                all_results$concept_name[i]))
  }
  if (nrow(all_results) > 5) {
    cat(sprintf("  ... and %d more\n", nrow(all_results) - 5))
  }
}
cat("\n")

# ============================================================================
# Search with Synonyms
# ============================================================================

cat("6. Search including synonyms\n")
cat("----------------------------\n")

# Include synonyms in search
results <- client$search$basic(
  "heart attack",
  include_synonyms = TRUE,
  page_size = 5
)

cat("Results for 'heart attack' (including synonyms):\n")
concepts <- results$data %||% results$concepts %||% results
for (c in concepts) {
  cat(sprintf("  [%d] %s (%s)\n",
              c$concept_id,
              c$concept_name,
              c$vocabulary_id))
}
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
