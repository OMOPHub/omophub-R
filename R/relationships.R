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
    #' @param relationship_ids Filter by relationship type IDs (character vector or comma-separated string).
    #' @param vocabulary_ids Filter by target vocabulary IDs (character vector or comma-separated string).
    #' @param domain_ids Filter by target domain IDs (character vector or comma-separated string).
    #' @param include_invalid Include relationships to invalid concepts. Default `FALSE`.
    #' @param standard_only Only include relationships to standard concepts. Default `FALSE`.
    #' @param include_reverse Include reverse relationships. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page (max 1000). Default 100.
    #' @param vocab_release Specific vocabulary release version. Default `NULL`.
    #'
    #' @returns Relationships data with pagination metadata.
    get = function(concept_id,
                   relationship_ids = NULL,
                   vocabulary_ids = NULL,
                   domain_ids = NULL,
                   include_invalid = FALSE,
                   standard_only = FALSE,
                   include_reverse = FALSE,
                   page = 1,
                   page_size = 100,
                   vocab_release = NULL) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(relationship_ids)) {
        params$relationship_ids <- if (length(relationship_ids) > 1) {
          paste(relationship_ids, collapse = ",")
        } else {
          relationship_ids
        }
      }
      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- if (length(vocabulary_ids) > 1) {
          paste(vocabulary_ids, collapse = ",")
        } else {
          vocabulary_ids
        }
      }
      if (!is.null(domain_ids)) {
        params$domain_ids <- if (length(domain_ids) > 1) {
          paste(domain_ids, collapse = ",")
        } else {
          domain_ids
        }
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }
      if (isTRUE(include_reverse)) {
        params$include_reverse <- "true"
      }
      if (!is.null(vocab_release)) {
        params$vocab_release <- vocab_release
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/relationships"),
        query = params
      )
    },

    #' @description
    #' Get available relationship types from the OMOP CDM.
    #'
    #' @param page Page number. Default 1.
    #' @param page_size Results per page (max 500). Default 100.
    #'
    #' @returns Relationship types with pagination metadata.
    types = function(page = 1,
                     page_size = 100) {
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

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
