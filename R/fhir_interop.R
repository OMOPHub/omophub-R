# FHIR client interop helpers for the OMOPHub FHIR Terminology Service.
#
# These helpers make it easy to configure an external FHIR client (like
# `httr2`, `fhircrackr`, or a custom Spring Security OAuth2 client) to
# talk directly to OMOPHub's FHIR endpoint. They are intentionally thin
# and have no client dependency so users can use them even without an
# `OMOPHubClient` instance.


#' OMOPHub FHIR Terminology Service URL
#'
#' Convenience helper for constructing the OMOPHub FHIR Terminology
#' Service base URL for a given FHIR version. Use it when configuring
#' an external FHIR client library (`httr2`, `fhircrackr`, etc.) to
#' talk to OMOPHub's FHIR endpoint directly.
#'
#' @param version FHIR version prefix. One of `"r4"` (default),
#'   `"r4b"`, `"r5"`, or `"r6"`.
#' @returns A character scalar with the full FHIR base URL, e.g.
#'   `"https://fhir.omophub.com/fhir/r4"`.
#' @examples
#' omophub_fhir_url()
#' omophub_fhir_url("r5")
#'
#' \dontrun{
#' # Use with httr2 to call the $lookup operation directly
#' library(httr2)
#' req <- request(omophub_fhir_url()) |>
#'   req_url_path_append("CodeSystem/$lookup") |>
#'   req_url_query(
#'     system = "http://snomed.info/sct",
#'     code = "44054006"
#'   ) |>
#'   req_headers(Authorization = paste("Bearer", Sys.getenv("OMOPHUB_API_KEY")))
#' resp <- req_perform(req)
#' }
#' @export
omophub_fhir_url <- function(version = c("r4", "r4b", "r5", "r6")) {
  version <- match.arg(version)
  paste0("https://fhir.omophub.com/fhir/", version)
}
