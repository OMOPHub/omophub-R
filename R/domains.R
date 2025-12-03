#' Domains Resource
#'
#' @description
#' R6 class providing access to domain operations.
#'
#' @keywords internal
DomainsResource <- R6::R6Class(
  "DomainsResource",
  public = list(
    #' @description
    #' Create a new DomainsResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' List all domains.
    #'
    #' @param vocabulary_ids Filter by vocabularies.
    #' @param include_concept_counts Include concept counts. Default `TRUE`.
    #' @param include_statistics Include detailed statistics. Default `FALSE`.
    #' @param include_examples Include example concepts. Default `FALSE`.
    #' @param standard_only Only standard concepts. Default `FALSE`.
    #' @param active_only Only active domains. Default `TRUE`.
    #' @param sort_by Sort field. Default "domain_id".
    #' @param sort_order Sort order. Default "asc".
    #'
    #' @returns Domain list with summary.
    list = function(vocabulary_ids = NULL,
                    include_concept_counts = TRUE,
                    include_statistics = FALSE,
                    include_examples = FALSE,
                    standard_only = FALSE,
                    active_only = TRUE,
                    sort_by = "domain_id",
                    sort_order = "asc") {
      params <- list(
        sort_by = sort_by,
        sort_order = sort_order
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (isTRUE(include_concept_counts)) {
        params$include_concept_counts <- "true"
      }
      if (isTRUE(include_statistics)) {
        params$include_statistics <- "true"
      }
      if (isTRUE(include_examples)) {
        params$include_examples <- "true"
      }
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }
      if (!isTRUE(active_only)) {
        params$active_only <- "false"
      }

      perform_get(private$.base_req, "domains", query = params)
    },

    #' @description
    #' Get concepts in a domain.
    #'
    #' @param domain_id The domain ID.
    #' @param vocabulary_ids Filter by vocabularies.
    #' @param concept_class_ids Filter by concept classes.
    #' @param standard_only Only standard concepts. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 50.
    #'
    #' @returns Paginated concepts.
    concepts = function(domain_id,
                        vocabulary_ids = NULL,
                        concept_class_ids = NULL,
                        standard_only = FALSE,
                        page = 1,
                        page_size = 50) {
      checkmate::assert_string(domain_id, min.chars = 1)
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(concept_class_ids)) {
        params$concept_class_ids <- join_params(concept_class_ids)
      }
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("domains/", domain_id, "/concepts"),
        query = params
      )
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub DomainsResource>\n")
      cat("  Methods: list, concepts\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
