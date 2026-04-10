#' FHIR-to-OMOP Concept Resolver
#'
#' @description
#' R6 class providing access to the FHIR-to-OMOP Concept Resolver endpoints.
#' Translates FHIR coded values (system URI + code) into OMOP standard
#' concepts, CDM target tables, and optional Phoebe recommendations.
#'
#' @details
#' Access via the `fhir` active binding on an `OMOPHubClient`:
#' ```r
#' client <- OMOPHubClient$new(api_key = "oh_xxx")
#' result <- client$fhir$resolve(
#'   system = "http://snomed.info/sct",
#'   code = "44054006",
#'   resource_type = "Condition"
#' )
#' result$data$resolution$target_table
#' # "condition_occurrence"
#' ```
#'
#' @keywords internal
FhirResource <- R6::R6Class(
  "FhirResource",
  public = list(
    #' @description
    #' Create a new FhirResource.
    #' @param base_req Base httr2 request object.
    initialize = function(base_req) {
      private$.base_req <- base_req
    },

    #' @description
    #' Resolve a single FHIR Coding to an OMOP standard concept.
    #'
    #' Provide at least one of (`system` + `code`), (`vocabulary_id` + `code`),
    #' or `display`.
    #'
    #' @param system FHIR code system URI (e.g. `"http://snomed.info/sct"`).
    #' @param code Code value from the FHIR Coding.
    #' @param display Human-readable text (semantic search fallback).
    #' @param vocabulary_id Direct OMOP vocabulary_id, bypasses URI resolution.
    #' @param resource_type FHIR resource type (e.g. `"Condition"`, `"Observation"`).
    #' @param include_recommendations Logical. Include Phoebe recommendations. Default `FALSE`.
    #' @param recommendations_limit Integer. Max recommendations (1-20). Default `5L`.
    #' @param include_quality Logical. Include mapping quality signal. Default `FALSE`.
    #'
    #' @returns A list with `input` and `resolution` containing source/standard
    #'   concepts, target CDM table, and optional enrichments.
    resolve = function(system = NULL,
                       code = NULL,
                       display = NULL,
                       vocabulary_id = NULL,
                       resource_type = NULL,
                       include_recommendations = FALSE,
                       recommendations_limit = 5L,
                       include_quality = FALSE) {
      body <- compact_list(
        system = system,
        code = code,
        display = display,
        vocabulary_id = vocabulary_id,
        resource_type = resource_type
      )
      if (isTRUE(include_recommendations)) {
        body$include_recommendations <- TRUE
        body$recommendations_limit <- as.integer(recommendations_limit)
      }
      if (isTRUE(include_quality)) {
        body$include_quality <- TRUE
      }

      perform_post(private$.base_req, "fhir/resolve", body = body)
    },

    #' @description
    #' Batch-resolve up to 100 FHIR Codings.
    #'
    #' Failed items are reported inline without failing the batch.
    #'
    #' @param codings A list of coding lists, each with optional elements
    #'   `system`, `code`, `display`, `vocabulary_id`.
    #' @param resource_type FHIR resource type applied to all codings.
    #' @param include_recommendations Logical. Default `FALSE`.
    #' @param recommendations_limit Integer. Default `5L`.
    #' @param include_quality Logical. Default `FALSE`.
    #'
    #' @returns A list with `results` (per-item) and `summary`
    #'   (total/resolved/failed).
    resolve_batch = function(codings,
                             resource_type = NULL,
                             include_recommendations = FALSE,
                             recommendations_limit = 5L,
                             include_quality = FALSE) {
      stopifnot(is.list(codings), length(codings) >= 1, length(codings) <= 100)
      if (!all(vapply(codings, is.list, logical(1)))) {
        cli::cli_abort(c(
          "{.arg codings} must be a list of coding lists.",
          "i" = "Each element should be a list with {.field system}, {.field code}, etc.",
          "i" = "Example: {.code list(list(system = \"http://snomed.info/sct\", code = \"44054006\"))}"
        ))
      }

      body <- list(codings = codings)
      if (!is.null(resource_type)) body$resource_type <- resource_type
      if (isTRUE(include_recommendations)) {
        body$include_recommendations <- TRUE
        body$recommendations_limit <- as.integer(recommendations_limit)
      }
      if (isTRUE(include_quality)) body$include_quality <- TRUE

      perform_post(private$.base_req, "fhir/resolve/batch", body = body)
    },

    #' @description
    #' Resolve a FHIR CodeableConcept with vocabulary preference.
    #'
    #' Picks the best match per OHDSI preference order
    #' (SNOMED > RxNorm > LOINC > CVX > ICD-10). Falls back to `text`
    #' via semantic search if no coding resolves.
    #'
    #' @param coding A list of coding lists, each with `system`, `code`,
    #'   and optional `display`.
    #' @param text Optional CodeableConcept.text for semantic fallback.
    #' @param resource_type FHIR resource type.
    #' @param include_recommendations Logical. Default `FALSE`.
    #' @param recommendations_limit Integer. Default `5L`.
    #' @param include_quality Logical. Default `FALSE`.
    #'
    #' @returns A list with `best_match`, `alternatives`, and `unresolved`.
    resolve_codeable_concept = function(coding,
                                        text = NULL,
                                        resource_type = NULL,
                                        include_recommendations = FALSE,
                                        recommendations_limit = 5L,
                                        include_quality = FALSE) {
      stopifnot(is.list(coding), length(coding) >= 1, length(coding) <= 20)
      if (!all(vapply(coding, is.list, logical(1)))) {
        cli::cli_abort(c(
          "{.arg coding} must be a list of coding lists.",
          "i" = "Each element should be a list with {.field system} and {.field code}.",
          "i" = "Example: {.code list(list(system = \"http://snomed.info/sct\", code = \"44054006\"))}"
        ))
      }

      body <- list(coding = coding)
      if (!is.null(text)) body$text <- text
      if (!is.null(resource_type)) body$resource_type <- resource_type
      if (isTRUE(include_recommendations)) {
        body$include_recommendations <- TRUE
        body$recommendations_limit <- as.integer(recommendations_limit)
      }
      if (isTRUE(include_quality)) body$include_quality <- TRUE

      perform_post(private$.base_req, "fhir/resolve/codeable-concept", body = body)
    }
  ),
  private = list(
    .base_req = NULL
  )
)


#' Helper to remove NULL entries from a named list.
#' @param ... Named arguments.
#' @returns A list with NULL entries removed.
#' @keywords internal
compact_list <- function(...) {
  args <- list(...)
  args[!vapply(args, is.null, logical(1))]
}
