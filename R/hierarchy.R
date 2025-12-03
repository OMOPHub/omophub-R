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
    #' Get concept ancestors.
    #'
    #' @param concept_id The concept ID.
    #' @param vocabulary_id Filter to specific vocabulary.
    #' @param max_levels Maximum hierarchy levels to traverse.
    #' @param relationship_types Relationship types to follow (default: "Is a").
    #' @param include_paths Include path information. Default `FALSE`.
    #' @param include_distance Include distance from source. Default `TRUE`.
    #' @param standard_only Only return standard concepts. Default `FALSE`.
    #' @param include_deprecated Include deprecated concepts. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 100.
    #'
    #' @returns Ancestors with hierarchy summary.
    ancestors = function(concept_id,
                         vocabulary_id = NULL,
                         max_levels = NULL,
                         relationship_types = NULL,
                         include_paths = FALSE,
                         include_distance = TRUE,
                         standard_only = FALSE,
                         include_deprecated = FALSE,
                         page = 1,
                         page_size = 100) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_id)) {
        params$vocabulary_id <- vocabulary_id
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
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }
      if (isTRUE(include_deprecated)) {
        params$include_deprecated <- "true"
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
    #' @param vocabulary_id Filter to specific vocabulary.
    #' @param max_levels Maximum hierarchy levels (default 10, max 10).
    #' @param relationship_types Relationship types to follow.
    #' @param include_distance Include distance from source. Default `TRUE`.
    #' @param standard_only Only return standard concepts. Default `FALSE`.
    #' @param include_deprecated Include deprecated concepts. Default `FALSE`.
    #' @param domain_ids Filter by domains.
    #' @param concept_class_ids Filter by concept classes.
    #' @param include_synonyms Include synonyms. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 100.
    #'
    #' @returns Descendants with hierarchy summary.
    descendants = function(concept_id,
                           vocabulary_id = NULL,
                           max_levels = 10,
                           relationship_types = NULL,
                           include_distance = TRUE,
                           standard_only = FALSE,
                           include_deprecated = FALSE,
                           domain_ids = NULL,
                           concept_class_ids = NULL,
                           include_synonyms = FALSE,
                           page = 1,
                           page_size = 100) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size)

      params <- list(
        max_levels = min(as.integer(max_levels), 10L),
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_id)) {
        params$vocabulary_id <- vocabulary_id
      }
      if (!is.null(relationship_types)) {
        params$relationship_types <- join_params(relationship_types)
      }
      if (isTRUE(include_distance)) {
        params$include_distance <- "true"
      }
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }
      if (isTRUE(include_deprecated)) {
        params$include_deprecated <- "true"
      }
      if (!is.null(domain_ids)) {
        params$domain_ids <- join_params(domain_ids)
      }
      if (!is.null(concept_class_ids)) {
        params$concept_class_ids <- join_params(concept_class_ids)
      }
      if (isTRUE(include_synonyms)) {
        params$include_synonyms <- "true"
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
      cat("  Methods: ancestors, descendants\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
