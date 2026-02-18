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
    #' @param vocabulary_ids Filter by vocabulary IDs.
    #' @param domain_ids Filter by domain IDs.
    #' @param concept_class_ids Filter by concept class IDs.
    #' @param standard_concepts_only Only return standard concepts. Default `FALSE`.
    #' @param include_invalid Include invalid concepts. Default `FALSE`.
    #' @param relationship_filters Relationship-based filters.
    #' @param page Page number (1-based). Default 1.
    #' @param page_size Results per page. Default 20.
    #'
    #' @returns Search results with facets and metadata.
    advanced = function(query,
                        vocabulary_ids = NULL,
                        domain_ids = NULL,
                        concept_class_ids = NULL,
                        standard_concepts_only = FALSE,
                        include_invalid = FALSE,
                        relationship_filters = NULL,
                        page = 1,
                        page_size = 20) {
      checkmate::assert_string(query, min.chars = 1)
      checkmate::assert_integerish(page, lower = 1, len = 1, any.missing = FALSE)
      checkmate::assert_integerish(page_size, lower = 1, upper = 1000, len = 1, any.missing = FALSE)

      body <- list(query = query)

      if (!is.null(vocabulary_ids)) {
        body$vocabulary_ids <- as.character(vocabulary_ids)
      }
      if (!is.null(domain_ids)) {
        body$domain_ids <- as.character(domain_ids)
      }
      if (!is.null(concept_class_ids)) {
        body$concept_class_ids <- as.character(concept_class_ids)
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
      if (page != 1) {
        body$page <- as.integer(page)
      }
      if (page_size != 20) {
        body$page_size <- as.integer(page_size)
      }

      perform_post(private$.base_req, "search/advanced", body = body)
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
      checkmate::assert_integerish(max_suggestions, lower = 1, len = 1, any.missing = FALSE)

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
    #' Semantic concept search using neural embeddings.
    #'
    #' @param query Natural language search query (required).
    #' @param vocabulary_ids Filter by vocabulary IDs.
    #' @param domain_ids Filter by domain IDs.
    #' @param standard_concept Filter by standard concept ('S' or 'C').
    #' @param concept_class_id Filter by concept class ID.
    #' @param threshold Minimum similarity threshold (0.0-1.0, default 0.5).
    #' @param page Page number (1-based). Default 1.
    #' @param page_size Results per page (max 100). Default 20.
    #'
    #' @returns List with results and pagination metadata.
    semantic = function(query,
                        vocabulary_ids = NULL,
                        domain_ids = NULL,
                        standard_concept = NULL,
                        concept_class_id = NULL,
                        threshold = NULL,
                        page = 1,
                        page_size = 20) {
      checkmate::assert_string(query, min.chars = 1)
      pag <- validate_pagination(page, page_size, max_page_size = 100)

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
      if (!is.null(standard_concept)) {
        checkmate::assert_choice(standard_concept, c("S", "C"))
        params$standard_concept <- standard_concept
      }
      if (!is.null(concept_class_id)) {
        params$concept_class_id <- concept_class_id
      }
      if (!is.null(threshold)) {
        checkmate::assert_number(threshold, lower = 0, upper = 1)
        params$threshold <- threshold
      }

      perform_get(private$.base_req, "concepts/semantic-search", query = params)
    },

    #' @description
    #' Fetch all semantic search results with automatic pagination.
    #'
    #' @param query Natural language search query (required).
    #' @param vocabulary_ids Filter by vocabulary IDs.
    #' @param domain_ids Filter by domain IDs.
    #' @param standard_concept Filter by standard concept ('S' or 'C').
    #' @param concept_class_id Filter by concept class ID.
    #' @param threshold Minimum similarity threshold (0.0-1.0).
    #' @param page_size Results per page. Default 100.
    #' @param max_pages Maximum pages to fetch. Default Inf.
    #' @param progress Show progress bar. Default `TRUE`.
    #'
    #' @returns A tibble of all matching concepts with similarity scores.
    semantic_all = function(query,
                            vocabulary_ids = NULL,
                            domain_ids = NULL,
                            standard_concept = NULL,
                            concept_class_id = NULL,
                            threshold = NULL,
                            page_size = 100,
                            max_pages = Inf,
                            progress = TRUE) {
      fetch_fn <- function(page, size) {
        result <- self$semantic(
          query = query,
          vocabulary_ids = vocabulary_ids,
          domain_ids = domain_ids,
          standard_concept = standard_concept,
          concept_class_id = concept_class_id,
          threshold = threshold,
          page = page,
          page_size = size
        )
        # Handle different response structures
        if (is.list(result) && "data" %in% names(result) && "meta" %in% names(result)) {
          data <- result$data
          if (is.list(data) && "results" %in% names(data)) {
            data <- data$results
          }
          list(data = data, meta = result$meta)
        } else if (is.list(result) && "results" %in% names(result)) {
          list(data = result$results, meta = result$meta %||% list())
        } else {
          list(data = result %||% list(), meta = list())
        }
      }

      paginate_all(fetch_fn, page_size = page_size, max_pages = max_pages, progress = progress)
    },

    #' @description
    #' Find concepts similar to a reference concept or query.
    #'
    #' Must provide exactly one of: concept_id, concept_name, or query.
    #'
    #' @param concept_id Concept ID to find similar concepts for.
    #' @param concept_name Concept name to find similar concepts for.
    #' @param query Natural language query for semantic similarity.
    #' @param algorithm One of 'semantic', 'lexical', or 'hybrid' (default).
    #' @param similarity_threshold Minimum similarity (0.0-1.0). Default 0.7.
    #' @param page_size Max results (max 1000). Default 20.
    #' @param vocabulary_ids Filter by vocabulary IDs.
    #' @param domain_ids Filter by domain IDs.
    #' @param standard_concept Filter by standard concept flag ('S', 'C', or 'N').
    #' @param include_invalid Include invalid/deprecated concepts.
    #' @param include_scores Include detailed similarity scores.
    #' @param include_explanations Include similarity explanations.
    #'
    #' @returns List with similar_concepts and search_metadata.
    #'
    #' @note When algorithm='semantic', only single vocabulary/domain filter supported.
    similar = function(concept_id = NULL,
                       concept_name = NULL,
                       query = NULL,
                       algorithm = "hybrid",
                       similarity_threshold = 0.7,
                       page_size = 20,
                       vocabulary_ids = NULL,
                       domain_ids = NULL,
                       standard_concept = NULL,
                       include_invalid = NULL,
                       include_scores = NULL,
                       include_explanations = NULL) {
      # Validate exactly one of concept_id, concept_name, or query provided
      provided <- sum(!is.null(concept_id), !is.null(concept_name), !is.null(query))
      if (provided != 1) {
        cli::cli_abort(
          "Exactly one of {.arg concept_id}, {.arg concept_name}, or {.arg query} must be provided"
        )
      }

      checkmate::assert_choice(algorithm, c("semantic", "lexical", "hybrid"))
      checkmate::assert_number(similarity_threshold, lower = 0, upper = 1)
      checkmate::assert_integerish(page_size, lower = 1, upper = 1000)
      if (!is.null(concept_id)) {
        checkmate::assert_integerish(concept_id, len = 1, any.missing = FALSE)
      }

      body <- list(
        algorithm = algorithm,
        similarity_threshold = similarity_threshold
      )

      if (!is.null(concept_id)) {
        body$concept_id <- as.integer(concept_id)
      }
      if (!is.null(concept_name)) {
        body$concept_name <- concept_name
      }
      if (!is.null(query)) {
        body$query <- query
      }
      if (page_size != 20) {
        body$page_size <- as.integer(page_size)
      }
      if (!is.null(vocabulary_ids)) {
        body$vocabulary_ids <- as.list(vocabulary_ids)
      }
      if (!is.null(domain_ids)) {
        body$domain_ids <- as.list(domain_ids)
      }
      if (!is.null(standard_concept)) {
        checkmate::assert_choice(standard_concept, c("S", "C", "N"))
        body$standard_concept <- standard_concept
      }
      if (!is.null(include_invalid)) {
        body$include_invalid <- include_invalid
      }
      if (!is.null(include_scores)) {
        body$include_scores <- include_scores
      }
      if (!is.null(include_explanations)) {
        body$include_explanations <- include_explanations
      }

      perform_post(private$.base_req, "search/similar", body = body)
    },

    #' @description
    #' Print resource information.
    print = function() {
      cat("<OMOPHub SearchResource>\n")
      cat("  Methods: basic, basic_all, advanced, autocomplete, semantic, semantic_all, similar\n")
      invisible(self)
    }
  ),
  private = list(
    .base_req = NULL
  )
)
