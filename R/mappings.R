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
    #' Get one page of mappings for a concept.
    #'
    #' The endpoint is paginated and a concept can easily have more mappings
    #' than one page holds, so a full page means "there is probably more",
    #' not "this is everything". Read the `pagination` attribute on the
    #' result, or use `get_all()` to walk every page.
    #'
    #' @param concept_id The concept ID.
    #' @param target_vocabulary Filter to a specific target vocabulary (e.g., "ICD10CM").
    #' @param include_invalid Whether to return mappings whose relationship or
    #'   target concept is deprecated. Default `NULL` takes the server default,
    #'   which for this endpoint is to *include* them; pass `FALSE` to exclude
    #'   them. The source concept is never filtered, so a deprecated concept
    #'   still returns what it maps to.
    #' @param vocab_release Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.
    #' @param relationship_ids Character vector of relationship types to return.
    #'   Defaults server-side to `"Maps to"`. Pass `c("Maps to", "Maps to value")`
    #'   to also get the Value-as-Concept decomposition of composite concepts -
    #'   "Allergy to penicillin G" maps to "Allergy to drug" via `Maps to` and to
    #'   "penicillin G" via `Maps to value`, and the default returns only the
    #'   first of those.
    #' @param page Page number. Default 1.
    #' @param page_size Mappings per page. Default 100, maximum 200.
    #'
    #' @returns Mappings for the concept, with pagination metadata attached as
    #'   the `pagination` attribute.
    get = function(concept_id,
                   target_vocabulary = NULL,
                   include_invalid = NULL,
                   vocab_release = NULL,
                   relationship_ids = NULL,
                   page = 1,
                   page_size = 100) {
      concept_id <- validate_concept_id(concept_id)
      pag <- validate_pagination(page, page_size, max_page_size = 200)

      params <- list(
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(target_vocabulary)) {
        checkmate::assert_string(target_vocabulary, min.chars = 1)
        params$target_vocabulary <- target_vocabulary
      }
      if (!is.null(relationship_ids)) {
        checkmate::assert_character(
          relationship_ids,
          min.len = 1,
          any.missing = FALSE
        )
        params$relationship_ids <- paste(relationship_ids, collapse = ",")
      }
      # Tri-state, not a flag. This endpoint defaults to *including* deprecated
      # mappings, so omitting the parameter and sending "false" are different
      # requests -- dropping a FALSE would silently return the rows the caller
      # asked to exclude.
      if (!is.null(include_invalid)) {
        checkmate::assert_flag(include_invalid)
        params$include_invalid <- if (include_invalid) "true" else "false"
      }
      if (!is.null(vocab_release)) {
        checkmate::assert_string(vocab_release, min.chars = 1)
        params$vocab_release <- vocab_release
      }

      result <- perform_get(
        private$.base_req,
        paste0("concepts/", concept_id, "/mappings"),
        query = params
      )

      private$.with_pagination(result)
    },

    #' @description
    #' Get every mapping for a concept, walking all pages.
    #'
    #' Prefer this over `get()` when assembling a code list — `get()` returns
    #' a single page, and a partial code list is wrong in a way nothing in
    #' the result reveals.
    #'
    #' @param concept_id The concept ID.
    #' @param target_vocabulary Filter to a specific target vocabulary (e.g., "ICD10CM").
    #' @param include_invalid Whether to return deprecated mappings. Same
    #'   semantics as `$get()`, including the include-by-default behaviour.
    #' @param vocab_release Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.
    #' @param relationship_ids Relationship types to return. Same semantics as
    #'   `$get()` -- see there for the Value-as-Concept case.
    #' @param page_size Mappings fetched per request. Default 100, maximum 200.
    #' @param max_pages Maximum pages to fetch. Default `Inf`.
    #' @param progress Show progress bar. Default `TRUE`.
    #'
    #' @returns A tibble of all mappings for the concept.
    get_all = function(concept_id,
                       target_vocabulary = NULL,
                       include_invalid = NULL,
                       vocab_release = NULL,
                       relationship_ids = NULL,
                       page_size = 100,
                       max_pages = Inf,
                       progress = TRUE) {
      concept_id <- validate_concept_id(concept_id)

      fetch_fn <- function(page, size) {
        result <- self$get(
          concept_id,
          target_vocabulary = target_vocabulary,
          relationship_ids = relationship_ids,
          include_invalid = include_invalid,
          page = page,
          page_size = size,
          vocab_release = vocab_release
        )
        list(
          data = result$mappings %||% list(),
          meta = attr(result, "pagination") %||% list()
        )
      }

      paginate_all(
        fetch_fn,
        page_size = page_size,
        max_pages = max_pages,
        progress = progress
      )
    },

    #' @description
    #' Map concepts to a target vocabulary.
    #'
    #' @param target_vocabulary Target vocabulary ID (e.g., "ICD10CM", "SNOMED", "RxNorm").
    #' @param source_concepts Vector of OMOP concept IDs to map. Use this OR source_codes, not both.
    #' @param source_codes List of vocabulary/code pairs to map. Each element should be a list
    #'   with `vocabulary_id` and `concept_code`. Use this OR source_concepts, not both.
    #' @param mapping_type Mapping type filter (direct, equivalent, broader, narrower).
    #' @param include_invalid Include invalid mappings. Default `FALSE`.
    #' @param vocab_release Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.
    #'
    #' @returns Mapping results with summary.
    map = function(target_vocabulary,
                   source_concepts = NULL,
                   source_codes = NULL,
                   mapping_type = NULL,
                   include_invalid = FALSE,
                   vocab_release = NULL) {
      checkmate::assert_string(target_vocabulary, min.chars = 1)

      # Validate: exactly one of source_concepts or source_codes required
      has_concepts <- !is.null(source_concepts) && length(source_concepts) > 0
      has_codes <- !is.null(source_codes) && length(source_codes) > 0

      if (!has_concepts && !has_codes) {
        abort_validation("Either source_concepts or source_codes is required")
      }
      if (has_concepts && has_codes) {
        abort_validation("Cannot use both source_concepts and source_codes")
      }

      body <- list(target_vocabulary = target_vocabulary)

      if (has_concepts) {
        checkmate::assert_integerish(source_concepts, min.len = 1)
        body$source_concepts <- as.integer(source_concepts)
      }

      if (has_codes) {
        checkmate::assert_list(source_codes, min.len = 1)
        # Validate each code entry has required fields
        for (i in seq_along(source_codes)) {
          if (!all(c("vocabulary_id", "concept_code") %in% names(source_codes[[i]]))) {
            abort_validation(
              sprintf("source_codes[%d] must have 'vocabulary_id' and 'concept_code'", i)
            )
          }
        }
        body$source_codes <- source_codes
      }

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
      cat("  Methods: get, get_all, map\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL,

    # Keep get()'s return shape stable across the API gaining pagination.
    #
    # perform_get() switches shape based on the response: without
    # meta.pagination it unwraps to body$data (so `result$mappings` works),
    # with it, it returns list(data = <body$data>, meta = <pagination>). When
    # GET /concepts/{id}/mappings became paginated on 2026-08-04 that flipped
    # this method's result out from under existing callers — `result$mappings`
    # started returning NULL against an unchanged SDK, with no error.
    #
    # So unwrap back to the documented shape and carry the pagination as an
    # attribute, which adds the new information without moving the old.
    .with_pagination = function(result) {
      if (is.list(result) && !is.null(result$data) && !is.null(result$meta)) {
        out <- result$data
        attr(out, "pagination") <- result$meta
        return(out)
      }
      result
    }
  )
)
