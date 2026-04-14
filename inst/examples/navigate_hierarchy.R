#!/usr/bin/env Rscript
#' Example: Navigate Hierarchy
#'
#' Demonstrates concept hierarchy exploration:
#' - Getting ancestors (parent concepts)
#' - Getting descendants (child concepts)
#' - Exploring concept relationships
#' - Finding related concepts
#'
#' Run with: Rscript inst/examples/navigate_hierarchy.R

library(omophub)

# Null-coalescing operator (available in base R 4.4+; define locally for
# compatibility with the R >= 4.1 package requirement).
`%||%` <- function(a, b) if (is.null(a)) b else a

# ============================================================================
# Setup
# ============================================================================

client <- OMOPHubClient$new()

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

cat(sprintf("Ancestors of concept %d (%s):\n",
            DIABETES_CONCEPT_ID,
            ancestors$data$concept_name))

# Actual ancestor list lives at $data$ancestors
ancestor_list <- ancestors$data$ancestors %||% list()
for (a in ancestor_list) {
  level <- a$min_levels_of_separation %||% a$level %||% "?"
  cat(sprintf("  Level %s: [%d] %s\n",
              level,
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
descendant_list <- descendants$data$descendants %||% list()
for (d in descendant_list) {
  level <- d$min_levels_of_separation %||% d$level %||% "?"
  cat(sprintf("  Level %s: [%d] %s\n",
              level,
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
ancestor_list <- ancestors_snomed$data$ancestors %||% list()
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

rel_list <- relationships$data$relationships %||% list()
cat(sprintf("Relationships for concept %d (%d total):\n",
            DIABETES_CONCEPT_ID, length(rel_list)))

# Group by relationship type (first 3 per type)
by_type <- list()
for (r in rel_list) {
  rel_type <- r$relationship_id %||% "Unknown"
  if (is.null(by_type[[rel_type]])) {
    by_type[[rel_type]] <- list()
  }
  by_type[[rel_type]] <- c(by_type[[rel_type]], list(r))
}

for (type_name in names(by_type)) {
  items <- by_type[[type_name]]
  cat(sprintf("\n  %s (%d):\n", type_name, length(items)))
  for (r in head(items, 3)) {
    # Prefer the nested ``concept_2`` object (full concept details) but
    # fall back to the flat ``concept_id_2`` field so deprecated or
    # invalid target concepts without a populated nested object still
    # surface an ID instead of rendering as unknown.
    target <- r$concept_2 %||% list()
    target_id <- target$concept_id %||% r$concept_id_2 %||% "?"
    target_name <- target$concept_name %||% "Unknown"
    cat(sprintf("    -> [%s] %s\n", target_id, target_name))
  }
  if (length(items) > 3) {
    cat(sprintf("    ... and %d more\n", length(items) - 3))
  }
}
cat("\n")

# ============================================================================
# Get Related Concepts (Semantic Similarity)
# ============================================================================

cat("5. Finding semantically related concepts\n")
cat("----------------------------------------\n")

# Get concepts related by semantic similarity. `related()` returns a flat
# unnamed list of concept objects (not wrapped in $data / $meta).
related_list <- client$concepts$related(
  DIABETES_CONCEPT_ID,
  page_size = 5
)

cat("Top 5 semantically related concepts:\n")
for (r in related_list) {
  score <- r$relationship_score %||% r$score %||% NA_real_
  score_str <- if (is.na(score)) "?" else sprintf("%.2f", score)
  cat(sprintf("  [%d] %s (score: %s, distance: %s)\n",
              r$concept_id,
              r$concept_name,
              score_str,
              r$relationship_distance %||% "?"))
}
cat("\n")

# ============================================================================
# Build a Concept Path
# ============================================================================

cat("6. Building concept path to root\n")
cat("---------------------------------\n")

# Get ancestors sorted by distance to show the path from the starting
# concept up through increasingly general parents.
path_result <- client$hierarchy$ancestors(
  DIABETES_CONCEPT_ID,
  max_levels = 10
)

ancestor_list <- path_result$data$ancestors %||% list()

# Sort by min_levels_of_separation (closest first)
if (length(ancestor_list) > 0) {
  distances <- sapply(
    ancestor_list,
    function(x) x$min_levels_of_separation %||% 999L
  )
  ancestor_list <- ancestor_list[order(distances)]
}

cat(sprintf("Path from '%s' to root:\n",
            path_result$data$concept_name %||% "Type 2 diabetes mellitus"))
for (i in seq_along(ancestor_list)) {
  a <- ancestor_list[[i]]
  indent <- paste(rep("  ", i), collapse = "")
  cat(sprintf("%s-> [%d] %s\n", indent, a$concept_id, a$concept_name))
}
cat("\n")

# ============================================================================
# Done
# ============================================================================

cat("Done!\n")
