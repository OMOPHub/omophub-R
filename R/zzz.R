#' Package Load Hook
#'
#' @param libname Library name.
#' @param pkgname Package name.
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Initialize package options
  op <- options()
  op_omophub <- list(
    omophub.base_url = "https://api.omophub.com/v1",
    omophub.timeout = 30,
    omophub.max_retries = 3
  )
  toset <- !(names(op_omophub) %in% names(op))
  if (any(toset)) options(op_omophub[toset])

  invisible()
}

#' Package Attach Hook
#'
#' @param libname Library name.
#' @param pkgname Package name.
#' @keywords internal
.onAttach <- function(libname, pkgname) {
  # Check for API key on attach
 if (!has_api_key()) {
    packageStartupMessage(
      "No OMOPHUB_API_KEY found. ",
      "Set it with Sys.setenv(OMOPHUB_API_KEY = 'your_key') ",
      "or use set_api_key()."
    )
  }
}
