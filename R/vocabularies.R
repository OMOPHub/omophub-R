#' Vocabularies Resource
#'
#' @description
#' R6 class providing access to vocabulary operations.
#'
#' @keywords internal
VocabulariesResource <- R6::R6Class(
  "VocabulariesResource",
  public = list(
    #' @description
    #' Create a new VocabulariesResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' List all vocabularies.
    #'
    #' @param include_stats Include vocabulary statistics. Default `FALSE`.
    #' @param include_inactive Include inactive vocabularies. Default `FALSE`.
    #' @param sort_by Sort field ("name", "priority", "updated"). Default "name".
    #' @param sort_order Sort order ("asc" or "desc"). Default "asc".
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 100.
    #'
    #' @returns Paginated vocabulary list.
    list = function(include_stats = FALSE,
                    include_inactive = FALSE,
                    sort_by = "name",
                    sort_order = "asc",
                    page = 1,
                    page_size = 100) {
      pag <- validate_pagination(page, page_size)

      params <- list(
        sort_by = sort_by,
        sort_order = sort_order,
        page = pag$page,
        page_size = pag$page_size
      )

      if (isTRUE(include_stats)) {
        params$include_stats <- "true"
      }
      if (isTRUE(include_inactive)) {
        params$include_inactive <- "true"
      }

      perform_get(private$.base_req, "vocabularies", query = params)
    },

    #' @description
    #' Get vocabulary details.
    #'
    #' @param vocabulary_id The vocabulary ID.
    #' @param include_stats Include statistics. Default `FALSE`.
    #' @param include_domains Include domain breakdown. Default `FALSE`.
    #'
    #' @returns Vocabulary details.
    get = function(vocabulary_id,
                   include_stats = FALSE,
                   include_domains = FALSE) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)

      params <- list()
      if (isTRUE(include_stats)) {
        params$include_stats <- "true"
      }
      if (isTRUE(include_domains)) {
        params$include_domains <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("vocabularies/", vocabulary_id),
        query = if (length(params) > 0) params else NULL
      )
    },

    #' @description
    #' Get vocabulary statistics.
    #'
    #' @param vocabulary_id The vocabulary ID.
    #'
    #' @returns Vocabulary statistics.
    stats = function(vocabulary_id) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)

      perform_get(
        private$.base_req,
        paste0("vocabularies/", vocabulary_id, "/stats")
      )
    },

    #' @description
    #' Get vocabulary domains.
    #'
    #' @param vocabulary_ids Filter by vocabulary IDs (optional).
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 50.
    #'
    #' @returns Domain statistics for vocabularies.
    domains = function(vocabulary_ids = NULL,
                       page = 1,
                       page_size = 50) {
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }

      perform_get(private$.base_req, "vocabularies/domains", query = params)
    },

    #' @description
    #' Get concepts in a vocabulary.
    #'
    #' @param vocabulary_id The vocabulary ID.
    #' @param domain_id Filter by domain.
    #' @param concept_class_id Filter by concept class.
    #' @param standard_only Only standard concepts. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 50.
    #'
    #' @returns Paginated concepts.
    concepts = function(vocabulary_id,
                        domain_id = NULL,
                        concept_class_id = NULL,
                        standard_only = FALSE,
                        page = 1,
                        page_size = 50) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(domain_id)) {
        params$domain_id <- domain_id
      }
      if (!is.null(concept_class_id)) {
        params$concept_class_id <- concept_class_id
      }
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("vocabularies/", vocabulary_id, "/concepts"),
        query = params
      )
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub VocabulariesResource>\n")
      cat("  Methods: list, get, stats, domains, concepts\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
