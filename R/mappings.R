#' Mappings Resource
#'
#' @description
#' R6 class providing access to mapping operations.
#'
#' @keywords internal
MappingsResource <- R6::R6Class(
  "MappingsResource",
  public = list(
    #' @description
    #' Create a new MappingsResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' Get mappings for a concept.
    #'
    #' @param concept_id The concept ID.
    #' @param target_vocabulary Filter to a specific target vocabulary (e.g., "ICD10CM").
    #' @param include_invalid Include invalid/deprecated mappings. Default `FALSE`.
    #' @param vocab_release Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.
    #'
    #' @returns Mappings for the concept.
    get = function(concept_id,
                   target_vocabulary = NULL,
                   include_invalid = FALSE,
                   vocab_release = NULL) {
      concept_id <- validate_concept_id(concept_id)

      params <- list()

      if (!is.null(target_vocabulary)) {
        checkmate::assert_string(target_vocabulary, min.chars = 1)
        params$target_vocabulary <- target_vocabulary
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }
      if (!is.null(vocab_release)) {
        checkmate::assert_string(vocab_release, min.chars = 1)
        params$vocab_release <- vocab_release
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/mappings"),
        query = if (length(params) > 0) params else NULL
      )
    },

    #' @description
    #' Map concepts to a target vocabulary.
    #'
    #' @param source_concepts Vector of OMOP concept IDs to map.
    #' @param target_vocabulary Target vocabulary ID (e.g., "ICD10CM", "SNOMED").
    #' @param mapping_type Mapping type (direct, equivalent, broader, narrower).
    #' @param include_invalid Include invalid mappings. Default `FALSE`.
    #' @param vocab_release Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.
    #'
    #' @returns Mapping results with summary.
    map = function(source_concepts,
                   target_vocabulary,
                   mapping_type = NULL,
                   include_invalid = FALSE,
                   vocab_release = NULL) {
      checkmate::assert_integerish(source_concepts, min.len = 1)
      checkmate::assert_string(target_vocabulary, min.chars = 1)

      body <- list(
        source_concepts = as.integer(source_concepts),
        target_vocabulary = target_vocabulary
      )

      if (!is.null(mapping_type)) {
        body$mapping_type <- mapping_type
      }
      if (isTRUE(include_invalid)) {
        body$include_invalid <- TRUE
      }

      query <- list()
      if (!is.null(vocab_release)) {
        query$vocab_release <- vocab_release
      }

      perform_post(private$.base_req, "concepts/map", body = body, query = if (length(query) > 0) query else NULL)
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub MappingsResource>\n")
      cat("  Methods: get, map\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
