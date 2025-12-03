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
    #' @param target_vocabularies Filter by target vocabularies.
    #' @param mapping_types Filter by mapping types.
    #' @param direction Mapping direction ("outgoing", "incoming", "both"). Default "both".
    #' @param include_indirect Include indirect mappings. Default `FALSE`.
    #' @param standard_only Only standard concept mappings. Default `FALSE`.
    #' @param include_mapping_quality Include quality metrics. Default `FALSE`.
    #' @param include_synonyms Include synonyms. Default `FALSE`.
    #' @param include_context Include mapping context. Default `FALSE`.
    #' @param active_only Only active mappings. Default `TRUE`.
    #' @param sort_by Sort field.
    #' @param sort_order Sort order.
    #' @param page Page number. Default 1.
    #' @param page_size Results per page. Default 50.
    #'
    #' @returns Mappings with summary.
    get = function(concept_id,
                   target_vocabularies = NULL,
                   mapping_types = NULL,
                   direction = "both",
                   include_indirect = FALSE,
                   standard_only = FALSE,
                   include_mapping_quality = FALSE,
                   include_synonyms = FALSE,
                   include_context = FALSE,
                   active_only = TRUE,
                   sort_by = NULL,
                   sort_order = NULL,
                   page = 1,
                   page_size = 50) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size)

      params <- list(
        direction = direction,
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(target_vocabularies)) {
        params$target_vocabularies <- join_params(target_vocabularies)
      }
      if (!is.null(mapping_types)) {
        params$mapping_types <- join_params(mapping_types)
      }
      if (isTRUE(include_indirect)) {
        params$include_indirect <- "true"
      }
      if (isTRUE(standard_only)) {
        params$standard_only <- "true"
      }
      if (isTRUE(include_mapping_quality)) {
        params$include_mapping_quality <- "true"
      }
      if (isTRUE(include_synonyms)) {
        params$include_synonyms <- "true"
      }
      if (isTRUE(include_context)) {
        params$include_context <- "true"
      }
      if (!isTRUE(active_only)) {
        params$active_only <- "false"
      }
      if (!is.null(sort_by)) {
        params$sort_by <- sort_by
      }
      if (!is.null(sort_order)) {
        params$sort_order <- sort_order
      }

      perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/mappings"),
        query = params
      )
    },

    #' @description
    #' Map concepts to a target vocabulary.
    #'
    #' @param source_concepts Vector of OMOP concept IDs to map.
    #' @param target_vocabulary Target vocabulary ID (e.g., "ICD10CM", "SNOMED").
    #' @param mapping_type Mapping type (direct, equivalent, broader, narrower).
    #' @param include_invalid Include invalid mappings. Default `FALSE`.
    #'
    #' @returns Mapping results with summary.
    map = function(source_concepts,
                   target_vocabulary,
                   mapping_type = NULL,
                   include_invalid = FALSE) {
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

      perform_post(private$.base_req, "concepts/map", body = body)
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
