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
    #' @param include_relationships Include related concepts (parents/children). Default `FALSE`.
    #' @param include_synonyms Include concept synonyms. Default `FALSE`.
    #' @param include_hierarchy Include hierarchy information. Default `FALSE`.
    #' @param vocab_release Specific vocabulary release (e.g., "2025.2"). Default `NULL`.
    #'
    #' @returns A list containing the concept data.
    get = function(concept_id,
                   include_relationships = FALSE,
                   include_synonyms = FALSE,
                   include_hierarchy = FALSE,
                   vocab_release = NULL) {
      concept_id <- validate_concept_id(concept_id)

      query <- list()
      if (isTRUE(include_relationships)) {
        query$include_relationships <- "true"
      }
      if (isTRUE(include_synonyms)) {
        query$include_synonyms <- "true"
      }
      if (isTRUE(include_hierarchy)) {
        query$include_hierarchy <- "true"
      }
      if (!is.null(vocab_release)) {
        query$vocab_release <- vocab_release
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
    #' @param include_relationships Include related concepts (parents/children). Default `FALSE`.
    #' @param include_synonyms Include concept synonyms. Default `FALSE`.
    #' @param include_hierarchy Include hierarchy information. Default `FALSE`.
    #' @param vocab_release Specific vocabulary release (e.g., "2025.2"). Default `NULL`.
    #'
    #' @returns A list containing the concept data with optional relationships and synonyms.
    get_by_code = function(vocabulary_id,
                           concept_code,
                           include_relationships = FALSE,
                           include_synonyms = FALSE,
                           include_hierarchy = FALSE,
                           vocab_release = NULL) {
      checkmate::assert_string(vocabulary_id, min.chars = 1)
      checkmate::assert_string(concept_code, min.chars = 1)

      query <- list()
      if (isTRUE(include_relationships)) {
        query$include_relationships <- "true"
      }
      if (isTRUE(include_synonyms)) {
        query$include_synonyms <- "true"
      }
      if (isTRUE(include_hierarchy)) {
        query$include_hierarchy <- "true"
      }
      if (!is.null(vocab_release)) {
        query$vocab_release <- vocab_release
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
    #' @param concept_ids Vector of concept IDs (max 100).
    #' @param include_relationships Include related concepts. Default `FALSE`.
    #' @param include_synonyms Include concept synonyms. Default `FALSE`.
    #' @param include_mappings Include concept mappings. Default `FALSE`.
    #' @param vocabulary_filter Filter results to specific vocabularies.
    #' @param standard_only Only return standard concepts. Default `TRUE`.
    #'
    #' @returns A list with `concepts` and any `failures`.
    batch = function(concept_ids,
                     include_relationships = FALSE,
                     include_synonyms = FALSE,
                     include_mappings = FALSE,
                     vocabulary_filter = NULL,
                     standard_only = TRUE) {
      checkmate::assert_integerish(concept_ids, min.len = 1, max.len = 100)

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
    #' @param query Search query (min 2 characters, max 100 characters).
    #' @param page Page number (default 1).
    #' @param page_size Number of suggestions per page (default 10, max 100).
    #' @param vocabulary_ids Filter to specific vocabularies (character vector).
    #' @param domain_ids Filter to specific domains (character vector).
    #' @param vocab_release Specific vocabulary release (e.g., "2025.2").
    #'
    #' @returns A list with suggestions and pagination metadata.
    suggest = function(query,
                       page = 1,
                       page_size = 10,
                       vocabulary_ids = NULL,
                       domain_ids = NULL,
                       vocab_release = NULL) {
      checkmate::assert_string(query, min.chars = 2, max.chars = 100)
      checkmate::assert_integerish(page, len = 1, lower = 1)
      checkmate::assert_integerish(page_size, len = 1, lower = 1, upper = 100)

      params <- list(
        query = query,
        page = as.integer(page),
        page_size = as.integer(page_size)
      )
      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(domain_ids)) {
        params$domain_ids <- join_params(domain_ids)
      }
      if (!is.null(vocab_release)) {
        params$vocab_release <- vocab_release
      }

      perform_get(private$.base_req, "concepts/suggest", query = params)
    },

    #' @description
    #' Get related concepts.
    #'
    #' @param concept_id The source concept ID.
    #' @param relationship_types Filter by relationship types (e.g., c("Is a", "Maps to")).
    #' @param min_score Minimum relationship score (0.0-1.0).
    #' @param page_size Maximum number of results (default 20, max 100).
    #' @param vocab_release Specific vocabulary release (e.g., "2025.1").
    #'
    #' @returns Related concepts with relationship scores.
    related = function(concept_id,
                       relationship_types = NULL,
                       min_score = NULL,
                       page_size = 20,
                       vocab_release = NULL) {
      concept_id <- validate_concept_id(concept_id)
      checkmate::assert_integerish(page_size, len = 1, lower = 1, upper = 100)

      params <- list(page_size = as.integer(page_size))

      if (!is.null(relationship_types)) {
        params$relationship_types <- join_params(relationship_types)
      }
      if (!is.null(min_score)) {
        checkmate::assert_number(min_score, lower = 0, upper = 1)
        params$min_score <- min_score
      }
      if (!is.null(vocab_release)) {
        params$vocab_release <- vocab_release
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
    #' @param relationship_ids Filter by relationship type IDs (character vector or comma-separated string).
    #' @param vocabulary_ids Filter by target vocabulary IDs (character vector or comma-separated string).
    #' @param domain_ids Filter by target domain IDs (character vector or comma-separated string).
    #' @param include_invalid Include relationships to invalid concepts. Default `FALSE`.
    #' @param standard_only Only include relationships to standard concepts. Default `FALSE`.
    #' @param include_reverse Include reverse relationships. Default `FALSE`.
    #' @param vocab_release Specific vocabulary release version. Default `NULL`.
    #'
    #' @returns Relationships data.
    relationships = function(concept_id,
                             relationship_ids = NULL,
                             vocabulary_ids = NULL,
                             domain_ids = NULL,
                             include_invalid = FALSE,
                             standard_only = FALSE,
                             include_reverse = FALSE,
                             vocab_release = NULL) {
      concept_id <- validate_concept_id(concept_id)

      params <- list()

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
        query = if (length(params) > 0) params else NULL
      )
    },

    #' @description
    #' Get recommended concepts using OHDSI Phoebe algorithm.
    #'
    #' @param concept_ids Vector of source concept IDs (1-100).
    #' @param relationship_types Filter by relationship types (max 20).
    #' @param vocabulary_ids Filter to specific vocabularies (max 50).
    #' @param domain_ids Filter to specific domains (max 50).
    #' @param standard_only Only return standard concepts. Default `TRUE`.
    #' @param include_invalid Include invalid/deprecated concepts. Default `FALSE`.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page (default 100, max 1000).
    #'
    #' @returns Recommendations grouped by source concept ID with pagination metadata.
    recommended = function(concept_ids,
                           relationship_types = NULL,
                           vocabulary_ids = NULL,
                           domain_ids = NULL,
                           standard_only = TRUE,
                           include_invalid = FALSE,
                           page = 1,
                           page_size = 100) {
      checkmate::assert_integerish(concept_ids, min.len = 1, max.len = 100)
      checkmate::assert_integerish(page, len = 1, lower = 1)
      checkmate::assert_integerish(page_size, len = 1, lower = 1, upper = 1000)

      body <- list(concept_ids = as.integer(concept_ids))

      if (!is.null(relationship_types)) {
        checkmate::assert_character(relationship_types, max.len = 20)
        body$relationship_types <- as.character(relationship_types)
      }
      if (!is.null(vocabulary_ids)) {
        checkmate::assert_character(vocabulary_ids, max.len = 50)
        body$vocabulary_ids <- as.character(vocabulary_ids)
      }
      if (!is.null(domain_ids)) {
        checkmate::assert_character(domain_ids, max.len = 50)
        body$domain_ids <- as.character(domain_ids)
      }

      body$standard_only <- isTRUE(standard_only)
      body$include_invalid <- isTRUE(include_invalid)
      body$page <- as.integer(page)
      body$page_size <- as.integer(page_size)

      perform_post(private$.base_req, "concepts/recommended", body = body)
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub ConceptsResource>\n")
      cat("  Methods: get, get_by_code, batch, suggest, related, relationships, recommended\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
