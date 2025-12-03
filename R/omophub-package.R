#' @keywords internal
"_PACKAGE"

#' omophub: R Client for the OMOPHub Medical Vocabulary API
#'
#' Provides an R interface to the OMOPHub API for accessing OHDSI ATHENA
#' standardized medical vocabularies. Supports concept search, vocabulary
#' exploration, hierarchy navigation, relationship queries, and concept
#' mappings with automatic pagination and rate limiting.
#'
#' @section Main Client:
#' The main entry point is the [OMOPHubClient] R6 class which provides
#' access to all API resources:
#'
#' ```r
#' library(omophub)
#' client <- OMOPHubClient$new()
#'
#' # Search for concepts
#' results <- client$search$basic("diabetes")
#'
#' # Get a specific concept
#' concept <- client$concepts$get(201826)
#' ```
#'
#' @section Authentication:
#' Set your API key using one of these methods:
#' - Environment variable: `OMOPHUB_API_KEY`
#' - Explicit argument: `OMOPHubClient$new(api_key = "your_key")`
#' - Keyring: `set_api_key("your_key", store = "keyring")`
#'
#' @section Resources:
#' The client provides access to these resources:
#' - `concepts`: Concept lookup and batch operations
#' - `search`: Basic and advanced concept search
#' - `vocabularies`: Vocabulary listing and details
#' - `domains`: Domain listing and concept filtering
#' - `hierarchy`: Ancestor and descendant navigation
#' - `relationships`: Concept relationships
#' - `mappings`: Concept mappings between vocabularies
#'
#' @importFrom httr2 request req_url_path_append req_url_query req_headers
#' @importFrom httr2 req_body_json req_perform resp_body_json resp_status
#' @importFrom httr2 req_throttle req_retry req_timeout req_user_agent req_error
#' @importFrom R6 R6Class
#' @importFrom rlang abort caller_env
#' @importFrom cli cli_abort cli_warn cli_inform
#' @importFrom glue glue
#' @importFrom tibble tibble as_tibble
#' @importFrom purrr map map_chr map_int map_dbl map_lgl
#'
#' @name omophub-package
#' @aliases omophub
NULL

# Default configuration values
.omophub_env <- new.env(parent = emptyenv())
.omophub_env$default_base_url <- "https://api.omophub.com/v1"
.omophub_env$default_timeout <- 30
.omophub_env$default_max_retries <- 3
.omophub_env$rate_limit_capacity <- 100
.omophub_env$rate_limit_fill_time <- 60
