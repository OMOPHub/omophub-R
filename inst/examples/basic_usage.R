#!/usr/bin/env Rscript
#' Example: Basic Usage
#'
#' Demonstrates basic OMOPHub client usage including:
#' - Client initialization
#' - Getting a single concept
#' - Basic search
#' - Listing vocabularies
#'
#' Run with: Rscript inst/examples/basic_usage.R

library(omophub)

# ============================================================================
# Setup
# ============================================================================

# Initialize client (uses OMOPHUB_API_KEY environment variable)
# You can also pass the API key directly:
#   client <- omophub(api_key = "oh_your_api_key")
client <- omophub()

cat("OMOPHub R Client - Basic Usage Example\n")
cat("======================================\n\n")

# ============================================================================
# Get a Single Concept
# ============================================================================

cat("1. Getting a single concept by ID\n")
cat("---------------------------------\n")

# Get Type 2 diabetes mellitus (SNOMED concept)
concept <- client$concepts$get(201826)

cat("Concept ID:", concept$concept_id, "\n")
cat("Name:", concept$concept_name, "\n")
cat("Vocabulary:", concept$vocabulary_id, "\n")
cat("Domain:", concept$domain_id, "\n")
cat("Concept Class:", concept$concept_class_id, "\n")
cat("Concept Code:", concept$concept_code, "\n")
cat("Standard Concept:", concept$standard_concept, "\n\n")

# ============================================================================
# Basic Search
# ============================================================================

cat("2. Searching for concepts\n")
cat("-------------------------\n")

# Search for diabetes-related concepts
results <- client$search$basic("diabetes", page_size = 5)

cat("Found concepts matching 'diabetes':\n")
concepts <- results$data %||% results$concepts %||% results
for (c in concepts) {
  cat(sprintf("  [%s] %s (%s)\n",
              c$concept_id,
              c$concept_name,
              c$vocabulary_id))
}
cat("\n")

# ============================================================================
# List Vocabularies
# ============================================================================

cat("3. Listing available vocabularies\n")
cat("---------------------------------\n")

# Get first 10 vocabularies
vocabs <- client$vocabularies$list(page_size = 10)

cat("Available vocabularies:\n")
vocab_list <- vocabs$data %||% vocabs$vocabularies %||% vocabs
for (v in vocab_list) {
  cat(sprintf("  %s - %s\n",
              v$vocabulary_id,
              v$vocabulary_name))
}
cat("\n")

# ============================================================================
# Get Concept with Additional Information
# ============================================================================

cat("4. Getting a concept with relationships\n")
cat("---------------------------------------\n")

# Get concept with relationships included
concept_full <- client$concepts$get(201826, include_relationships = TRUE)

cat("Concept:", concept_full$concept_name, "\n")
if (!is.null(concept_full$relationships)) {
  cat("Number of relationships:", length(concept_full$relationships), "\n")
}
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
