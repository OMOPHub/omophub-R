#' Hierarchy Resource
#'
#' @description
#' R6 class providing access to hierarchy operations (ancestors and descendants).
#'
#' @keywords internal
HierarchyResource <- R6::R6Class(
  "HierarchyResource",
  public = list(
    #' @description
    #' Create a new HierarchyResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' Get complete concept hierarchy (ancestors and descendants).
    #'
    #' @param concept_id The concept ID.
    #' @param format Response format - "flat" (default) or "graph" for visualization.
    #' @param vocabulary_ids Filter to specific vocabularies (character vector).
    #' @param domain_ids Filter to specific domains (character vector).
    #' @param max_levels Maximum hierarchy levels to traverse in both directions (default 10).
    #' @param max_results Maximum results per direction for performance optimization.
    #' @param relationship_types Relationship types to follow (default: "Is a").
    #' @param include_invalid Include deprecated/invalid concepts. Default `FALSE`.
    #'
    #' @returns For flat format: ancestors, descendants arrays with level/total counts.
    #'          For graph format: nodes and edges arrays for visualization.
    get = function(concept_id,
                   format = "flat",
                   vocabulary_ids = NULL,
                   domain_ids = NULL,
                   max_levels = 10,
                   max_results = NULL,
                   relationship_types = NULL,
                   include_invalid = FALSE) {
      concept_id <- validate_concept_id(concept_id)

      params <- list(
        format = format,
        max_levels = min(as.integer(max_levels), 20L)
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(domain_ids)) {
        params$domain_ids <- join_params(domain_ids)
      }
      if (!is.null(max_results)) {
        params$max_results <- as.integer(max_results)
      }
      if (!is.null(relationship_types)) {
        params$relationship_types <- join_params(relationship_types)
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/hierarchy"),
        query = params
      )
    },

    #' @description
    #' Get concept ancestors.
    #'
    #' @param concept_id The concept ID.
    #' @param vocabulary_ids Filter to specific vocabularies (character vector).
    #' @param max_levels Maximum hierarchy levels to traverse.
    #' @param relationship_types Relationship types to follow (default: "Is a").
    #' @param include_paths Include path information. Default `FALSE`.
    #' @param include_distance Include distance from source. Default `TRUE`.
    #' @param include_invalid Include deprecated/invalid concepts. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 100.
    #'
    #' @returns Ancestors with hierarchy summary.
    ancestors = function(concept_id,
                         vocabulary_ids = NULL,
                         max_levels = NULL,
                         relationship_types = NULL,
                         include_paths = FALSE,
                         include_distance = TRUE,
                         include_invalid = FALSE,
                         page = 1,
                         page_size = 100) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(max_levels)) {
        params$max_levels <- as.integer(max_levels)
      }
      if (!is.null(relationship_types)) {
        params$relationship_types <- join_params(relationship_types)
      }
      if (isTRUE(include_paths)) {
        params$include_paths <- "true"
      }
      if (isTRUE(include_distance)) {
        params$include_distance <- "true"
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/ancestors"),
        query = params
      )
    },

    #' @description
    #' Get concept descendants.
    #'
    #' @param concept_id The concept ID.
    #' @param vocabulary_ids Filter to specific vocabularies (character vector).
    #' @param max_levels Maximum hierarchy levels (default 10, max 20).
    #' @param relationship_types Relationship types to follow.
    #' @param include_distance Include distance from source. Default `TRUE`.
    #' @param include_paths Include path information. Default `FALSE`.
    #' @param include_invalid Include deprecated/invalid concepts. Default `FALSE`.
    #' @param domain_ids Filter by domains.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 100.
    #'
    #' @returns Descendants with hierarchy summary.
    descendants = function(concept_id,
                           vocabulary_ids = NULL,
                           max_levels = 10,
                           relationship_types = NULL,
                           include_distance = TRUE,
                           include_paths = FALSE,
                           include_invalid = FALSE,
                           domain_ids = NULL,
                           page = 1,
                           page_size = 100) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size)

      params <- list(
        max_levels = min(as.integer(max_levels), 20L),
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(relationship_types)) {
        params$relationship_types <- join_params(relationship_types)
      }
      if (isTRUE(include_distance)) {
        params$include_distance <- "true"
      }
      if (isTRUE(include_paths)) {
        params$include_paths <- "true"
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }
      if (!is.null(domain_ids)) {
        params$domain_ids <- join_params(domain_ids)
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/descendants"),
        query = params
      )
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub HierarchyResource>\n")
      cat("  Methods: get, ancestors, descendants\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
