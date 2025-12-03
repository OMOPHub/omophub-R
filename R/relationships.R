#' Relationships Resource
#'
#' @description
#' R6 class providing access to relationship operations.
#'
#' @keywords internal
RelationshipsResource <- R6::R6Class(
  "RelationshipsResource",
  public = list(
    #' @description
    #' Create a new RelationshipsResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' Get relationships for a concept.
    #'
    #' @param concept_id The concept ID.
    #' @param relationship_type Filter by relationship type.
    #' @param target_vocabulary Filter by target vocabulary.
    #' @param include_invalid Include invalid relationships. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 50.
    #'
    #' @returns Relationships with summary.
    get = function(concept_id,
                   relationship_type = NULL,
                   target_vocabulary = NULL,
                   include_invalid = FALSE,
                   page = 1,
                   page_size = 50) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(relationship_type)) {
        params$relationship_type <- relationship_type
      }
      if (!is.null(target_vocabulary)) {
        params$target_vocabulary <- target_vocabulary
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/relationships"),
        query = params
      )
    },

    #' @description
    #' Get available relationship types.
    #'
    #' @param vocabulary_ids Filter by vocabularies.
    #' @param include_reverse Include reverse relationships. Default `FALSE`.
    #' @param include_usage_stats Include usage statistics. Default `FALSE`.
    #' @param include_examples Include example concepts. Default `FALSE`.
    #' @param category Filter by category.
    #' @param is_defining Filter by defining status.
    #' @param standard_only Only standard relationships. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 100.
    #'
    #' @returns Relationship types with metadata.
    types = function(vocabulary_ids = NULL,
                     include_reverse = FALSE,
                     include_usage_stats = FALSE,
                     include_examples = FALSE,
                     category = NULL,
                     is_defining = NULL,
                     standard_only = FALSE,
                     page = 1,
                     page_size = 100) {
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (isTRUE(include_reverse)) {
        params$include_reverse <- "true"
      }
      if (isTRUE(include_usage_stats)) {
        params$include_usage_stats <- "true"
      }
      if (isTRUE(include_examples)) {
        params$include_examples <- "true"
      }
      if (!is.null(category)) {
        params$category <- category
      }
      if (!is.null(is_defining)) {
        params$is_defining <- bool_to_str(is_defining)
      }
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }

      perform_get(private$.base_req, "relationships/types", query = params)
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub RelationshipsResource>\n")
      cat("  Methods: get, types\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
