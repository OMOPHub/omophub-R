#' Concepts Resource
#'
#' @description
#' R6 class providing access to concept operations.
#'
#' @keywords internal
ConceptsResource <- R6::R6Class(
  "ConceptsResource",
  public = list(
    #' @description
    #' Create a new ConceptsResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' Get a concept by ID.
    #'
    #' @param concept_id The OMOP concept ID.
    #' @param include_relationships Include related concepts. Default `FALSE`.
    #' @param include_synonyms Include concept synonyms. Default `FALSE`.
    #'
    #' @returns A list containing the concept data.
    get = function(concept_id,
                   include_relationships = FALSE,
                   include_synonyms = FALSE) {
      concept_id <- validate_concept_id(concept_id)

      query <- list()
      if (isTRUE(include_relationships)) {
        query$include_relationships <- "true"
      }
      if (isTRUE(include_synonyms)) {
        query$include_synonyms <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id),
        query = if (length(query) > 0) query else NULL
      )
    },

    #' @description
    #' Get a concept by vocabulary and code.
    #'
    #' @param vocabulary_id The vocabulary ID (e.g., "SNOMED", "ICD10CM").
    #' @param concept_code The concept code within the vocabulary.
    #' @param include_relationships Include related concepts. Default `FALSE`.
    #' @param include_synonyms Include concept synonyms. Default `FALSE`.
    #'
    #' @returns A list containing the concept data with optional relationships and synonyms.
    get_by_code = function(vocabulary_id,
                           concept_code,
                           include_relationships = FALSE,
                           include_synonyms = FALSE) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)
      checkmate::assert_string(concept_code, min.chars = 1)

      query <- list()
      if (isTRUE(include_relationships)) {
        query$include_relationships <- "true"
      }
      if (isTRUE(include_synonyms)) {
        query$include_synonyms <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("concepts/by-code/", vocabulary_id, "/", concept_code),
        query = if (length(query) > 0) query else NULL
      )
    },

    #' @description
    #' Get multiple concepts by IDs.
    #'
    #' @param concept_ids Vector of concept IDs (max 1000).
    #' @param include_relationships Include related concepts. Default `FALSE`.
    #' @param include_synonyms Include concept synonyms. Default `FALSE`.
    #' @param include_mappings Include concept mappings. Default `FALSE`.
    #' @param vocabulary_filter Filter results to specific vocabularies.
    #' @param standard_only Only return standard concepts. Default `FALSE`.
    #'
    #' @returns A list with `concepts` and any `failures`.
    batch = function(concept_ids,
                     include_relationships = FALSE,
                     include_synonyms = FALSE,
                     include_mappings = FALSE,
                     vocabulary_filter = NULL,
                     standard_only = FALSE) {
      checkmate::assert_integerish(concept_ids, min.len = 1, max.len = 1000)

      body <- list(concept_ids = as.integer(concept_ids))

      if (isTRUE(include_relationships)) {
        body$include_relationships <- TRUE
      }
      if (isTRUE(include_synonyms)) {
        body$include_synonyms <- TRUE
      }
      if (isTRUE(include_mappings)) {
        body$include_mappings <- TRUE
      }
      if (!is.null(vocabulary_filter)) {
        body$vocabulary_filter <- as.character(vocabulary_filter)
      }
      if (isTRUE(standard_only)) {
        body$standard_only <- TRUE
      }

      perform_post(private$.base_req, "concepts/batch", body = body)
    },

    #' @description
    #' Get concept suggestions (autocomplete).
    #'
    #' @param query Search query (min 2 characters).
    #' @param vocabulary Filter to specific vocabulary.
    #' @param domain Filter to specific domain.
    #' @param limit Maximum suggestions (default 10, max 50).
    #'
    #' @returns A list of suggestions.
    suggest = function(query,
                       vocabulary = NULL,
                       domain = NULL,
                       limit = 10) {
      checkmate::assert_string(query, min.chars = 2)
      checkmate::assert_integerish(limit, len = 1, lower = 1, upper = 50)

      params <- list(
        query = query,
        limit = as.integer(limit)
      )
      if (!is.null(vocabulary)) {
        params$vocabulary <- vocabulary
      }
      if (!is.null(domain)) {
        params$domain <- domain
      }

      perform_get(private$.base_req, "concepts/suggest", query = params)
    },

    #' @description
    #' Get related concepts.
    #'
    #' @param concept_id The source concept ID.
    #' @param relatedness_types Types of relatedness (hierarchical, semantic, etc.).
    #' @param vocabulary_ids Filter to specific vocabularies.
    #' @param domain_ids Filter to specific domains.
    #' @param min_relatedness_score Minimum relatedness score.
    #' @param max_results Maximum results (default 50, max 200).
    #' @param include_scores Include score breakdown. Default `TRUE`.
    #' @param standard_concepts_only Only return standard concepts. Default `FALSE`.
    #'
    #' @returns Related concepts with scores and analysis.
    related = function(concept_id,
                       relatedness_types = NULL,
                       vocabulary_ids = NULL,
                       domain_ids = NULL,
                       min_relatedness_score = NULL,
                       max_results = 50,
                       include_scores = TRUE,
                       standard_concepts_only = FALSE) {
      concept_id <- validate_concept_id(concept_id)

      params <- list(
        max_results = as.integer(max_results),
        include_scores = bool_to_str(include_scores)
      )

      if (!is.null(relatedness_types)) {
        params$relatedness_types <- join_params(relatedness_types)
      }
      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(domain_ids)) {
        params$domain_ids <- join_params(domain_ids)
      }
      if (!is.null(min_relatedness_score)) {
        params$min_relatedness_score <- min_relatedness_score
      }
      if (isTRUE(standard_concepts_only)) {
        params$standard_concepts_only <- "true"
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/related"),
        query = params
      )
    },

    #' @description
    #' Get concept relationships.
    #'
    #' @param concept_id The concept ID.
    #' @param relationship_type Filter by relationship type.
    #' @param target_vocabulary Filter by target vocabulary.
    #' @param include_invalid Include invalid relationships. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Items per page. Default 20.
    #'
    #' @returns Relationships with summary.
    relationships = function(concept_id,
                             relationship_type = NULL,
                             target_vocabulary = NULL,
                             include_invalid = FALSE,
                             page = 1,
                             page_size = 20) {
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
    #' Print resource information.
    print = function() {
      cat("<OMOPHub ConceptsResource>\n")
      cat("  Methods: get, get_by_code, batch, suggest, related, relationships\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
