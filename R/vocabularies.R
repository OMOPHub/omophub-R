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
    #'
    #' @returns Vocabulary details including vocabulary_id, vocabulary_name,
    #'   vocabulary_reference, vocabulary_version, vocabulary_concept_id.
    get = function(vocabulary_id) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)

      perform_get(
        private$.base_req,
        paste0("vocabularies/", vocabulary_id)
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
    #' Get statistics for a specific domain within a vocabulary.
    #'
    #' @param vocabulary_id The vocabulary ID (e.g., "SNOMED", "ICD10CM").
    #' @param domain_id The domain ID (e.g., "Condition", "Drug", "Procedure").
    #'
    #' @returns Domain statistics including concept counts and class breakdown.
    domain_stats = function(vocabulary_id, domain_id) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)
      checkmate::assert_string(domain_id, min.chars = 1)

      perform_get(
        private$.base_req,
        paste0("vocabularies/", vocabulary_id, "/stats/domains/", domain_id)
      )
    },

    #' @description
    #' Get all standard OHDSI domains.
    #'
    #' @returns List of all available domains with domain_id, domain_name, and description.
    domains = function() {
      perform_get(private$.base_req, "vocabularies/domains")
    },

    #' @description
    #' Get all concept classes.
    #'
    #' @returns List of all available concept classes with concept_class_id,
    #'   concept_class_name, and concept_class_concept_id.
    concept_classes = function() {
      perform_get(private$.base_req, "vocabularies/concept-classes")
    },

    #' @description
    #' Get concepts in a vocabulary.
    #'
    #' @param vocabulary_id The vocabulary ID.
    #' @param search Search term to filter concepts by name or code.
    #' @param standard_concept Filter by standard concept status ('S', 'C', 'all'). Default "all".
    #' @param include_invalid Include invalid or deprecated concepts. Default `FALSE`.
    #' @param include_relationships Include concept relationships. Default `FALSE`.
    #' @param include_synonyms Include concept synonyms. Default `FALSE`.
    #' @param sort_by Sort field ('name', 'concept_id', 'concept_code'). Default "name".
    #' @param sort_order Sort order ('asc' or 'desc'). Default "asc".
    #' @param page Page number. Default 1.
    #' @param page_size Results per page (max 1000). Default 20.
    #'
    #' @returns Paginated concepts.
    concepts = function(vocabulary_id,
                        search = NULL,
                        standard_concept = "all",
                        include_invalid = FALSE,
                        include_relationships = FALSE,
                        include_synonyms = FALSE,
                        sort_by = "name",
                        sort_order = "asc",
                        page = 1,
                        page_size = 20) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)
      pag <- validate_pagination(page, page_size)

      params <- list(
        page = pag$page,
        page_size = pag$page_size,
        standard_concept = standard_concept,
        sort_by = sort_by,
        sort_order = sort_order
      )

      if (!is.null(search)) {
        params$search <- search
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }
      if (isTRUE(include_relationships)) {
        params$include_relationships <- "true"
      }
      if (isTRUE(include_synonyms)) {
        params$include_synonyms <- "true"
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
      cat("  Methods: list, get, stats, domain_stats, domains, concept_classes, concepts\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
