#' OMOPHub API Client
#'
#' @description
#' R6 class for interacting with the OMOPHub vocabulary service.
#' Provides access to OHDSI ATHENA standardized medical vocabularies.
#'
#' @details
#' The client provides access to these resources:
#' - `concepts`: Concept lookup and batch operations
#' - `search`: Basic and advanced concept search
#' - `vocabularies`: Vocabulary listing and details
#' - `domains`: Domain listing and concept filtering
#' - `hierarchy`: Ancestor and descendant navigation
#' - `relationships`: Concept relationships
#' - `mappings`: Concept mappings between vocabularies
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Create client (uses OMOPHUB_API_KEY env var)
#' client <- OMOPHubClient$new()
#'
#' # Or with explicit API key
#' client <- OMOPHubClient$new(api_key = "your_api_key")
#'
#' # Search for concepts
#' results <- client$search$basic("diabetes")
#'
#' # Get a specific concept
#' concept <- client$concepts$get(201826)
#'
#' # Use specific vocabulary version
#' client <- OMOPHubClient$new(vocab_version = "2025.1")
#' }
OMOPHubClient <- R6::R6Class(
  "OMOPHubClient",
  public = list(
    #' @description
    #' Create a new OMOPHub client.
    #'
    #' @param api_key API key for authentication. If not provided, reads from
    #'   `OMOPHUB_API_KEY` environment variable or system keyring.
    #' @param base_url API base URL. Defaults to `https://api.omophub.com/v1`.
    #' @param timeout Request timeout in seconds. Defaults to 30.
    #' @param max_retries Maximum retry attempts for failed requests. Defaults to 3.
    #' @param vocab_version Optional vocabulary version (e.g., "2025.1").
    #'   If not specified, uses the latest version.
    #'
    #' @returns A new `OMOPHubClient` object.
    initialize = function(api_key = NULL,
                          base_url = NULL,
                          timeout = 30,
                          max_retries = 3,
                          vocab_version = NULL) {
      private$.api_key <- get_api_key(api_key)
      private$.base_url <- base_url %||% .omophub_env$default_base_url
      private$.timeout <- timeout %||% .omophub_env$default_timeout
      private$.max_retries <- max_retries %||% .omophub_env$default_max_retries
      private$.vocab_version <- vocab_version

      # Build base request
      private$.base_req <- build_request(
        base_url = private$.base_url,
        api_key = private$.api_key,
        timeout = private$.timeout,
        max_retries = private$.max_retries,
        vocab_version = private$.vocab_version
      )

      # Initialize resource accessors (lazy loading via active bindings)
      # Resources are initialized on first access
      invisible(self)
    },

    #' @description
    #' Print client information.
    print = function() {
      cat("<OMOPHubClient>\n")
      cat("  Base URL:", private$.base_url, "\n")
      cat("  Authenticated:", !is.null(private$.api_key), "\n")
      if (!is.null(private$.vocab_version)) {
        cat("  Vocabulary Version:", private$.vocab_version, "\n")
      }
      cat("  Timeout:", private$.timeout, "seconds\n")
      cat("  Max Retries:", private$.max_retries, "\n")
      invisible(self)
    }
  ),
  active = list(
    #' @field concepts Access to concept operations.
    concepts = function() {
      if (is.null(private$.concepts)) {
        private$.concepts <- ConceptsResource$new(private$.base_req)
      }
      private$.concepts
    },

    #' @field search Access to search operations.
    search = function() {
      if (is.null(private$.search)) {
        private$.search <- SearchResource$new(private$.base_req)
      }
      private$.search
    },

    #' @field vocabularies Access to vocabulary operations.
    vocabularies = function() {
      if (is.null(private$.vocabularies)) {
        private$.vocabularies <- VocabulariesResource$new(private$.base_req)
      }
      private$.vocabularies
    },

    #' @field domains Access to domain operations.
    domains = function() {
      if (is.null(private$.domains)) {
        private$.domains <- DomainsResource$new(private$.base_req)
      }
      private$.domains
    },

    #' @field hierarchy Access to hierarchy operations.
    hierarchy = function() {
      if (is.null(private$.hierarchy)) {
        private$.hierarchy <- HierarchyResource$new(private$.base_req)
      }
      private$.hierarchy
    },

    #' @field relationships Access to relationship operations.
    relationships = function() {
      if (is.null(private$.relationships)) {
        private$.relationships <- RelationshipsResource$new(private$.base_req)
      }
      private$.relationships
    },

    #' @field mappings Access to mapping operations.
    mappings = function() {
      if (is.null(private$.mappings)) {
        private$.mappings <- MappingsResource$new(private$.base_req)
      }
      private$.mappings
    }
  ),
  private = list(
    .base_url = NULL,
    .api_key = NULL,
    .timeout = NULL,
    .max_retries = NULL,
    .vocab_version = NULL,
    .base_req = NULL,

    # Lazy-loaded resources
    .concepts = NULL,
    .search = NULL,
    .vocabularies = NULL,
    .domains = NULL,
    .hierarchy = NULL,
    .relationships = NULL,
    .mappings = NULL
  )
)
