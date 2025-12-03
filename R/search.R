#' Search Resource
#'
#' @description
#' R6 class providing access to search operations.
#'
#' @keywords internal
SearchResource <- R6::R6Class(
  "SearchResource",
  public = list(
    #' @description
    #' Create a new SearchResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' Basic concept search.
    #'
    #' @param query Search query string.
    #' @param vocabulary_ids Filter by vocabulary IDs.
    #' @param domain_ids Filter by domain IDs.
    #' @param concept_class_ids Filter by concept class IDs.
    #' @param standard_concept Filter by standard concept ("S", "C", or NULL).
    #' @param include_synonyms Search in synonyms. Default `FALSE`.
    #' @param include_invalid Include invalid concepts. Default `FALSE`.
    #' @param min_score Minimum relevance score.
    #' @param exact_match Require exact match. Default `FALSE`.
    #' @param page Page number (1-based). Default 1.
    #' @param page_size Results per page. Default 20.
    #' @param sort_by Sort field.
    #' @param sort_order Sort order ("asc" or "desc").
    #'
    #' @returns Search results with pagination.
    basic = function(query,
                     vocabulary_ids = NULL,
                     domain_ids = NULL,
                     concept_class_ids = NULL,
                     standard_concept = NULL,
                     include_synonyms = FALSE,
                     include_invalid = FALSE,
                     min_score = NULL,
                     exact_match = FALSE,
                     page = 1,
                     page_size = 20,
                     sort_by = NULL,
                     sort_order = NULL) {
      checkmate::assert_string(query, min.chars = 1)
      pag <- validate_pagination(page, page_size)

      params <- list(
        query = query,
        page = pag$page,
        page_size = pag$page_size
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(domain_ids)) {
        params$domain_ids <- join_params(domain_ids)
      }
      if (!is.null(concept_class_ids)) {
        params$concept_class_ids <- join_params(concept_class_ids)
      }
      if (!is.null(standard_concept)) {
        params$standard_concept <- standard_concept
      }
      if (isTRUE(include_synonyms)) {
        params$include_synonyms <- "true"
      }
      if (isTRUE(include_invalid)) {
        params$include_invalid <- "true"
      }
      if (!is.null(min_score)) {
        params$min_score <- min_score
      }
      if (isTRUE(exact_match)) {
        params$exact_match <- "true"
      }
      if (!is.null(sort_by)) {
        params$sort_by <- sort_by
      }
      if (!is.null(sort_order)) {
        params$sort_order <- sort_order
      }

      perform_get(private$.base_req, "search/concepts", query = params)
    },

    #' @description
    #' Fetch all search results with automatic pagination.
    #'
    #' @param query Search query string.
    #' @param vocabulary_ids Filter by vocabulary IDs.
    #' @param domain_ids Filter by domain IDs.
    #' @param page_size Results per page. Default 100.
    #' @param max_pages Maximum pages to fetch. Default Inf.
    #' @param progress Show progress bar. Default `TRUE`.
    #' @param ... Additional search parameters.
    #'
    #' @returns A tibble of all matching concepts.
    basic_all = function(query,
                         vocabulary_ids = NULL,
                         domain_ids = NULL,
                         page_size = 100,
                         max_pages = Inf,
                         progress = TRUE,
                         ...) {
      fetch_fn <- function(page, size) {
        result <- self$basic(
          query,
          vocabulary_ids = vocabulary_ids,
          domain_ids = domain_ids,
          page = page,
          page_size = size,
          ...
        )
        # Result has pagination structure: list(data=concepts, meta=pagination)
        # or it's directly the concepts array (for non-paginated responses)
        if (is.list(result) && "data" %in% names(result) && "meta" %in% names(result)) {
          # Paginated response - return data and meta
          list(data = result$data, meta = result$meta)
        } else if (is.list(result) && !is.null(result$concepts)) {
          # Wrapped in concepts key
          data <- result$concepts
          meta <- result$meta$pagination %||% result$meta %||% list()
          list(data = data, meta = meta)
        } else if (is.list(result) && (is.null(names(result)) || !("data" %in% names(result)))) {
          # Unnamed list = array of concepts directly
          list(data = result, meta = list())
        } else {
          list(data = result %||% list(), meta = list())
        }
      }

      paginate_all(fetch_fn, page_size = page_size, max_pages = max_pages, progress = progress)
    },

    #' @description
    #' Advanced concept search with facets.
    #'
    #' @param query Search query string.
    #' @param vocabularies Filter by vocabularies.
    #' @param domains Filter by domains.
    #' @param concept_classes Filter by concept classes.
    #' @param standard_concepts_only Only return standard concepts. Default `FALSE`.
    #' @param include_invalid Include invalid concepts. Default `FALSE`.
    #' @param relationship_filters Relationship-based filters.
    #' @param limit Maximum results. Default 20.
    #' @param offset Result offset. Default 0.
    #'
    #' @returns Search results with facets and metadata.
    advanced = function(query,
                        vocabularies = NULL,
                        domains = NULL,
                        concept_classes = NULL,
                        standard_concepts_only = FALSE,
                        include_invalid = FALSE,
                        relationship_filters = NULL,
                        limit = 20,
                        offset = 0) {
      checkmate::assert_string(query, min.chars = 1)

      body <- list(query = query)

      if (!is.null(vocabularies)) {
        body$vocabularies <- as.character(vocabularies)
      }
      if (!is.null(domains)) {
        body$domains <- as.character(domains)
      }
      if (!is.null(concept_classes)) {
        body$concept_classes <- as.character(concept_classes)
      }
      if (isTRUE(standard_concepts_only)) {
        body$standard_concepts_only <- TRUE
      }
      if (isTRUE(include_invalid)) {
        body$include_invalid <- TRUE
      }
      if (!is.null(relationship_filters)) {
        body$relationship_filters <- relationship_filters
      }
      if (limit != 20) {
        body$limit <- as.integer(limit)
      }
      if (offset > 0) {
        body$offset <- as.integer(offset)
      }

      perform_post(private$.base_req, "concepts/search/advanced", body = body)
    },

    #' @description
    #' Get autocomplete suggestions.
    #'
    #' @param query Partial query string.
    #' @param vocabulary_ids Filter by vocabulary IDs.
    #' @param domains Filter by domains.
    #' @param max_suggestions Maximum suggestions. Default 10.
    #'
    #' @returns Autocomplete suggestions.
    autocomplete = function(query,
                            vocabulary_ids = NULL,
                            domains = NULL,
                            max_suggestions = 10) {
      checkmate::assert_string(query, min.chars = 1)

      params <- list(
        query = query,
        max_suggestions = as.integer(max_suggestions)
      )

      if (!is.null(vocabulary_ids)) {
        params$vocabulary_ids <- join_params(vocabulary_ids)
      }
      if (!is.null(domains)) {
        params$domains <- join_params(domains)
      }

      perform_get(private$.base_req, "search/suggest", query = params)
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub SearchResource>\n")
      cat("  Methods: basic, basic_all, advanced, autocomplete\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
