#!/usr/bin/env Rscript
#' Example: Navigate Hierarchy
#'
#' Demonstrates concept hierarchy exploration:
#' - Getting ancestors (parent concepts)
#' - Getting descendants (child concepts)
#' - Exploring concept relationships
#'
#' Run with: Rscript inst/examples/navigate_hierarchy.R

library(omophub)

# ============================================================================
# Setup
# ============================================================================

client <- omophub()

cat("OMOPHub R Client - Hierarchy Navigation Examples\n")
cat("=================================================\n\n")

# We'll use "Type 2 diabetes mellitus" as our starting concept
DIABETES_CONCEPT_ID <- 201826

# ============================================================================
# Get Ancestors (Parent Concepts)
# ============================================================================

cat("1. Getting ancestors (parent concepts)\n")
cat("--------------------------------------\n")

# Get ancestors up to 3 levels, including distance information
ancestors <- client$hierarchy$ancestors(
  DIABETES_CONCEPT_ID,
  max_levels = 3,
  include_distance = TRUE
)

cat(sprintf("Ancestors of concept %d:\n", DIABETES_CONCEPT_ID))
ancestor_list <- ancestors$ancestors %||% ancestors$data %||% ancestors
for (a in ancestor_list) {
  distance <- a$distance %||% a$min_levels_of_separation %||% "?"
  cat(sprintf("  Level %s: [%d] %s\n",
              distance,
              a$concept_id,
              a$concept_name))
}
cat("\n")

# ============================================================================
# Get Descendants (Child Concepts)
# ============================================================================

cat("2. Getting descendants (child concepts)\n")
cat("---------------------------------------\n")

# Get descendants up to 2 levels
descendants <- client$hierarchy$descendants(
  DIABETES_CONCEPT_ID,
  max_levels = 2,
  page_size = 10
)

cat(sprintf("Descendants of concept %d (first 10):\n", DIABETES_CONCEPT_ID))
descendant_list <- descendants$descendants %||% descendants$data %||% descendants
for (d in descendant_list) {
  distance <- d$distance %||% d$min_levels_of_separation %||% "?"
  cat(sprintf("  Level %s: [%d] %s\n",
              distance,
              d$concept_id,
              d$concept_name))
}
cat("\n")

# ============================================================================
# Get Ancestors with Filters
# ============================================================================

cat("3. Filtered ancestors (SNOMED only)\n")
cat("------------------------------------\n")

# Get only SNOMED ancestors
ancestors_snomed <- client$hierarchy$ancestors(
  DIABETES_CONCEPT_ID,
  vocabulary_ids = c("SNOMED"),
  max_levels = 5,
  include_invalid = FALSE
)

cat("SNOMED ancestors only:\n")
ancestor_list <- ancestors_snomed$ancestors %||% ancestors_snomed$data %||% ancestors_snomed
for (a in ancestor_list) {
  cat(sprintf("  [%d] %s (%s)\n",
              a$concept_id,
              a$concept_name,
              a$concept_class_id %||% ""))
}
cat("\n")

# ============================================================================
# Explore Concept Relationships
# ============================================================================

cat("4. Exploring concept relationships\n")
cat("----------------------------------\n")

# Get all relationships for a concept
relationships <- client$concepts$relationships(DIABETES_CONCEPT_ID)

cat(sprintf("Relationships for concept %d:\n", DIABETES_CONCEPT_ID))

# Group by relationship type
rel_list <- relationships$relationships %||% relationships$data %||% relationships
by_type <- list()
for (r in rel_list) {
  rel_type <- r$relationship_id %||% "Unknown"
  if (is.null(by_type[[rel_type]])) {
    by_type[[rel_type]] <- list()
  }
  by_type[[rel_type]] <- c(by_type[[rel_type]], list(r))
}

for (type_name in names(by_type)) {
  cat(sprintf("\n  %s:\n", type_name))
  for (r in by_type[[type_name]]) {
    target <- r$concept_2 %||% r$target_concept %||% r
    target_id <- target$concept_id %||% r$concept_id_2 %||% "?"
    target_name <- target$concept_name %||% r$concept_name_2 %||% "Unknown"
    cat(sprintf("    -> [%s] %s\n", target_id, target_name))
  }
}
cat("\n")

# ============================================================================
# Get Related Concepts (Semantic Similarity)
# ============================================================================

cat("5. Finding semantically related concepts\n")
cat("----------------------------------------\n")

# Get concepts related by semantic similarity
related <- client$concepts$related(
  DIABETES_CONCEPT_ID,
  page_size = 5
)

cat("Semantically related concepts:\n")
related_list <- related$related_concepts %||% related$data %||% related
for (r in related_list) {
  score <- r$relatedness_score %||% r$score %||% "?"
  cat(sprintf("  [%d] %s (score: %s)\n",
              r$concept_id,
              r$concept_name,
              score))
}
cat("\n")

# ============================================================================
# Build a Concept Path
# ============================================================================

cat("6. Building concept path to root\n")
cat("---------------------------------\n")

# Get ancestors with path information
path_result <- client$hierarchy$ancestors(
  DIABETES_CONCEPT_ID,
  include_paths = TRUE,
  max_levels = 10
)

cat("Path from 'Type 2 diabetes mellitus' to root:\n")
ancestor_list <- path_result$ancestors %||% path_result$data %||% path_result

# Sort by distance if available
if (length(ancestor_list) > 0 && !is.null(ancestor_list[[1]]$distance)) {
  distances <- sapply(ancestor_list, function(x) x$distance %||% 999)
  ancestor_list <- ancestor_list[order(distances)]
}

for (i in seq_along(ancestor_list)) {
  a <- ancestor_list[[i]]
  indent <- paste(rep("  ", i), collapse = "")
  cat(sprintf("%s-> %s\n", indent, a$concept_name))
}
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
