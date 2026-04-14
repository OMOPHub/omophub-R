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

# Null-coalescing operator (available in base R 4.4+; define locally for
# compatibility with the R >= 4.1 package requirement).
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================================
# Setup
# ============================================================================

client <- OMOPHubClient$new()

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
suggestions <- client$concepts$suggest("diab", page_size = 5)

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
# Semantic Search
# ============================================================================

cat("7. Semantic search (natural language)\n")
cat("-------------------------------------\n")

# Search using natural language - understands clinical intent
results <- client$search$semantic("high blood sugar levels", page_size = 5)

cat("Semantic results for 'high blood sugar levels':\n")
for (r in results$data$results) {
  cat(sprintf("  [%d] %s (similarity: %.2f)\n",
              r$concept_id, r$concept_name, r$similarity_score))
}
cat("\n")

# ============================================================================
# Semantic Search with Filters
# ============================================================================

cat("8. Semantic search with filters\n")
cat("-------------------------------\n")

results <- client$search$semantic(
  "heart attack",
  vocabulary_ids = "SNOMED",
  domain_ids = "Condition",
  threshold = 0.5,
  page_size = 5
)

cat("Filtered semantic results for 'heart attack':\n")
for (r in results$data$results) {
  cat(sprintf("  [%d] %s (similarity: %.2f)\n",
              r$concept_id, r$concept_name, r$similarity_score))
}
cat("\n")

# ============================================================================
# Auto-Paginated Semantic Search
# ============================================================================

cat("9. Auto-paginated semantic search\n")
cat("----------------------------------\n")

all_results <- client$search$semantic_all(
  "chronic kidney disease",
  page_size = 10,
  max_pages = 3,
  progress = FALSE
)

cat(sprintf("Fetched %d concepts for 'chronic kidney disease':\n", nrow(all_results)))
if (nrow(all_results) > 0) {
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
# Similarity Search
# ============================================================================

cat("10. Similarity search\n")
cat("---------------------\n")

# Find concepts similar to Type 2 diabetes mellitus
similar <- client$search$similar(
  concept_id = 201826,
  algorithm = "hybrid",
  similarity_threshold = 0.6,
  page_size = 5
)

cat("Concepts similar to 'Type 2 diabetes mellitus':\n")
for (s in similar$similar_concepts) {
  cat(sprintf("  [%d] %s (score: %.2f)\n",
              s$concept_id, s$concept_name, s$similarity_score))
}
cat("\n")

# Similarity by natural language query
similar <- client$search$similar(
  query = "high blood pressure",
  algorithm = "semantic",
  page_size = 5
)

cat("Concepts similar to 'high blood pressure' (semantic):\n")
for (s in similar$similar_concepts) {
  cat(sprintf("  [%d] %s (score: %.2f)\n",
              s$concept_id, s$concept_name, s$similarity_score))
}
cat("\n")

# ============================================================================
# Bulk Lexical Search
# ============================================================================

cat("11. Bulk lexical search (multiple queries in one call)\n")
cat("------------------------------------------------------\n")

# Search for multiple terms at once (up to 50)
results <- client$search$bulk_basic(list(
  list(search_id = "q1", query = "diabetes mellitus"),
  list(search_id = "q2", query = "hypertension"),
  list(search_id = "q3", query = "aspirin")
), defaults = list(vocabulary_ids = list("SNOMED"), page_size = 3))

cat("Bulk search results:\n")
for (item in results$results) {
  cat(sprintf("  %s: %d results (%s)\n",
              item$search_id, length(item$results), item$status))
}
cat("\n")

# ============================================================================
# Bulk Semantic Search
# ============================================================================

cat("12. Bulk semantic search (multiple NLP queries)\n")
cat("------------------------------------------------\n")

# Search for multiple natural-language queries at once (up to 25)
results <- client$search$bulk_semantic(list(
  list(search_id = "s1", query = "heart failure treatment options"),
  list(search_id = "s2", query = "type 2 diabetes medication"),
  list(search_id = "s3", query = "elevated blood pressure")
), defaults = list(threshold = 0.5, page_size = 5))

cat("Bulk semantic results:\n")
for (item in results$results) {
  n_results <- item$result_count %||% length(item$results)
  cat(sprintf("  %s: %d results (%s)\n",
              item$search_id, n_results, item$status))

  # Show top result for each query
  if (length(item$results) > 0) {
    top <- item$results[[1]]
    cat(sprintf("    Top: %s (score: %.2f)\n",
                top$concept_name, top$similarity_score))
  }
}
cat("\n")

# ============================================================================
# Bulk Search with Per-Query Overrides
# ============================================================================

cat("13. Bulk search with per-query filters\n")
cat("--------------------------------------\n")

# Defaults apply to all, but individual searches can override
results <- client$search$bulk_basic(list(
  list(search_id = "conditions", query = "diabetes", domain_ids = list("Condition")),
  list(search_id = "drugs", query = "metformin", domain_ids = list("Drug"))
), defaults = list(vocabulary_ids = list("SNOMED", "RxNorm"), page_size = 3))

for (item in results$results) {
  cat(sprintf("  %s:\n", item$search_id))
  for (c in item$results) {
    cat(sprintf("    [%d] %s (%s/%s)\n",
                c$concept_id, c$concept_name,
                c$vocabulary_id, c$domain_id))
  }
}
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
