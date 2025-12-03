#' Get OMOPHub API Key
#'
#' @description
#' Retrieves the OMOPHub API key from multiple sources in priority order:
#' 1. Explicit argument
#' 2. `OMOPHUB_API_KEY` environment variable
#' 3. System keyring (if `keyring` package is installed)
#'
#' @param key Optional explicit API key. If provided, this takes precedence.
#'
#' @returns A character string containing the API key.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # From environment variable
#' Sys.setenv(OMOPHUB_API_KEY = "your_api_key")
#' key <- get_api_key()
#'
#' # Explicit key
#' key <- get_api_key("your_api_key")
#' }
get_api_key <- function(key = NULL) {
  # 1. Explicit argument takes precedence

if (!is.null(key)) {
    if (!is.character(key) || length(key) != 1 || nchar(key) == 0) {
      cli::cli_abort(c(
        "Invalid API key provided.",
        "i" = "API key must be a non-empty string."
      ))
    }
    return(key)
  }

  # 2. Environment variable
  env_key <- Sys.getenv("OMOPHUB_API_KEY", unset = NA_character_)
  if (!is.na(env_key) && nzchar(env_key)) {
    return(env_key)
  }

  # 3. Keyring fallback (optional)
  if (requireNamespace("keyring", quietly = TRUE)) {
    tryCatch(
      {
        keyring_key <- keyring::key_get("omophub", "api_key")
        if (!is.null(keyring_key) && nzchar(keyring_key)) {
          return(keyring_key)
        }
      },
      error = function(e) {
        # Key not found in keyring, continue to error
        NULL
      }
    )
  }

  # No key found
  cli::cli_abort(c(
    "No API key found.",
    "i" = "Set the {.envvar OMOPHUB_API_KEY} environment variable,",
    "i" = "or use {.code set_api_key()} to store your key,",
    "i" = "or pass {.arg api_key} to {.fun OMOPHubClient$new}."
  ))
}

#' Set OMOPHub API Key
#'
#' @description
#' Stores the OMOPHub API key in the specified location.
#'
#' @param key The API key to store.
#' @param store Where to store the key. One of:
#'   - `"env"`: Set as environment variable for current session (default)
#'   - `"keyring"`: Store securely in system keyring (requires `keyring` package)
#'
#' @returns Invisibly returns `TRUE` on success.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Store in environment (current session only)
#' set_api_key("your_api_key")
#'
#' # Store securely in keyring (persistent)
#' set_api_key("your_api_key", store = "keyring")
#' }
set_api_key <- function(key, store = c("env", "keyring")) {
  store <- match.arg(store)

  if (!is.character(key) || length(key) != 1 || nchar(key) == 0) {
    cli::cli_abort(c(
      "Invalid API key.",
      "i" = "API key must be a non-empty string."
    ))
  }

  if (store == "env") {
    Sys.setenv(OMOPHUB_API_KEY = key)
    cli::cli_inform(c(
      "v" = "API key set for current R session.",
      "i" = "Use {.code store = \"keyring\"} for persistent storage."
    ))
  } else if (store == "keyring") {
    if (!requireNamespace("keyring", quietly = TRUE)) {
      cli::cli_abort(c(
        "The {.pkg keyring} package is required for secure storage.",
        "i" = "Install it with: {.code install.packages(\"keyring\")}"
      ))
    }
    keyring::key_set_with_value("omophub", "api_key", key)
    cli::cli_inform(c(
      "v" = "API key stored securely in system keyring."
    ))
  }

  invisible(TRUE)
}

#' Check if API Key is Available
#'
#' @description
#' Checks whether an OMOPHub API key is available without throwing an error.
#'
#' @returns `TRUE` if an API key is available, `FALSE` otherwise.
#'
#' @export
has_api_key <- function() {
  tryCatch(
    {
      get_api_key()
      TRUE
    },
    error = function(e) FALSE
  )
}
