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
    #' @param as_tibble Logical. When `TRUE`, returns a [tibble::tibble]
    #'   with one row per input coding and flat columns for the source
    #'   concept, standard concept, target CDM table, mapping type, and
    #'   resolution status. The batch `summary` (total/resolved/failed)
    #'   is attached as `attr(result, "summary")`. Default `FALSE`
    #'   keeps the legacy list-shaped return.
    #'
    #' @returns When `as_tibble = FALSE` (default), a list with `results`
    #'   (per-item) and `summary` (total/resolved/failed). When
    #'   `as_tibble = TRUE`, a [tibble::tibble] suitable for
    #'   `dplyr`/`tidyr` pipelines.
    resolve_batch = function(codings,
                             resource_type = NULL,
                             include_recommendations = FALSE,
                             recommendations_limit = 5L,
                             include_quality = FALSE,
                             as_tibble = FALSE) {
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

      result <- perform_post(private$.base_req, "fhir/resolve/batch", body = body)

      if (isTRUE(as_tibble)) {
        return(fhir_batch_to_tibble(result, codings))
      }
      result
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


#' Flatten a batch resolver response into a tibble.
#'
#' Internal helper used by `FhirResource$resolve_batch(as_tibble = TRUE)`.
#' Produces one row per input coding with flat columns for the source
#' concept, standard concept, target CDM table, and status. The original
#' `summary` list is attached to the returned tibble via
#' `attr(x, "summary")`.
#'
#' @param result The raw list result from `perform_post`.
#' @param codings The original input `codings` list, used to align rows
#'   when items fail resolution and no `source_concept` is returned.
#' @returns A [tibble::tibble].
#' @keywords internal
fhir_batch_to_tibble <- function(result, codings) {
  items <- result$results %||% list()
  n <- length(codings)

  # Collapse a possibly-nested error object to a scalar string. The API
  # may return `error` as a plain string, a list like
  # `list(code = "concept_not_found", message = "...")`, or something
  # else. A list-column here would be expanded into extra tibble rows.
  error_to_string <- function(err) {
    if (is.null(err)) return(NA_character_)
    if (is.character(err) && length(err) == 1L) return(err)
    if (is.list(err)) {
      msg <- err$message %||% err$code %||% err$detail
      if (!is.null(msg) && is.character(msg) && length(msg) == 1L) {
        return(msg)
      }
      return(paste(names(err) %||% "", unlist(lapply(err, as.character)),
                   sep = "=", collapse = "; "))
    }
    # Zero-length / non-character fallbacks: single-bracket indexing
    # returns NA on a length-0 vector instead of throwing. Guards
    # against `character(0)`, `integer(0)`, etc.
    as.character(err)[1L]
  }

  make_row <- function(i) {
    input_coding <- codings[[i]]
    item <- if (i <= length(items)) items[[i]] else NULL

    # Failed items: the API returns them without a resolution block.
    resolution <- item$resolution
    if (is.null(resolution)) {
      return(tibble::tibble(
        source_system = input_coding$system %||% NA_character_,
        source_code = input_coding$code %||% NA_character_,
        source_concept_id = NA_integer_,
        source_concept_name = NA_character_,
        standard_concept_id = NA_integer_,
        standard_concept_name = NA_character_,
        standard_vocabulary_id = NA_character_,
        domain_id = NA_character_,
        target_table = NA_character_,
        mapping_type = NA_character_,
        similarity_score = NA_real_,
        status = "failed",
        status_detail = error_to_string(item$error)
      ))
    }

    src <- resolution$source_concept %||% list()
    std <- resolution$standard_concept %||% list()

    tibble::tibble(
      source_system = input_coding$system %||% NA_character_,
      source_code = input_coding$code %||% NA_character_,
      source_concept_id = src$concept_id %||% NA_integer_,
      source_concept_name = src$concept_name %||% NA_character_,
      standard_concept_id = std$concept_id %||% NA_integer_,
      standard_concept_name = std$concept_name %||% NA_character_,
      standard_vocabulary_id = std$vocabulary_id %||% NA_character_,
      domain_id = std$domain_id %||% NA_character_,
      target_table = resolution$target_table %||% NA_character_,
      mapping_type = resolution$mapping_type %||% NA_character_,
      similarity_score = resolution$similarity_score %||% NA_real_,
      status = "resolved",
      status_detail = NA_character_
    )
  }

  rows <- lapply(seq_len(n), make_row)
  tbl <- do.call(rbind, rows)
  attr(tbl, "summary") <- result$summary
  tbl
}


#' Null-coalescing operator.
#' @noRd
`%||%` <- function(a, b) if (is.null(a)) b else a


# =============================================================================
# Standalone wrapper functions
#
# Thin wrappers around the R6 `FhirResource` methods so users can write
# pipe-friendly code without dereferencing the client every call:
#
#   client |> fhir_resolve(system = "http://snomed.info/sct", code = "44054006")
#
# These forward all arguments to the underlying R6 method.
# =============================================================================

#' Resolve a FHIR Coding to an OMOP standard concept
#'
#' Standalone wrapper for `client$fhir$resolve()`. See
#' [FhirResource] for full parameter documentation.
#'
#' @param client An [OMOPHubClient] instance.
#' @param ... Arguments passed to `FhirResource$resolve()`.
#' @returns A list with `input` and `resolution`.
#' @seealso [FhirResource], [fhir_resolve_batch()],
#'   [fhir_resolve_codeable_concept()]
#' @examples
#' \dontrun{
#' client <- OMOPHubClient$new(api_key = Sys.getenv("OMOPHUB_API_KEY"))
#' fhir_resolve(
#'   client,
#'   system = "http://snomed.info/sct",
#'   code = "44054006",
#'   resource_type = "Condition"
#' )
#' }
#' @export
fhir_resolve <- function(client, ...) {
  client$fhir$resolve(...)
}


#' Batch-resolve FHIR Codings
#'
#' Standalone wrapper for `client$fhir$resolve_batch()`. When
#' `as_tibble = TRUE`, the result is a flat `tibble` suitable for
#' `dplyr`/`tidyr` pipelines.
#'
#' @param client An [OMOPHubClient] instance.
#' @param ... Arguments passed to `FhirResource$resolve_batch()`.
#' @returns See `FhirResource$resolve_batch()`.
#' @seealso [FhirResource], [fhir_resolve()],
#'   [fhir_resolve_codeable_concept()]
#' @examples
#' \dontrun{
#' client <- OMOPHubClient$new(api_key = Sys.getenv("OMOPHUB_API_KEY"))
#' tbl <- fhir_resolve_batch(
#'   client,
#'   codings = list(
#'     list(system = "http://snomed.info/sct", code = "44054006"),
#'     list(system = "http://loinc.org", code = "2339-0")
#'   ),
#'   as_tibble = TRUE
#' )
#' dplyr::filter(tbl, status == "resolved")
#' }
#' @export
fhir_resolve_batch <- function(client, ...) {
  client$fhir$resolve_batch(...)
}


#' Resolve a FHIR CodeableConcept with vocabulary preference
#'
#' Standalone wrapper for `client$fhir$resolve_codeable_concept()`.
#'
#' @param client An [OMOPHubClient] instance.
#' @param ... Arguments passed to `FhirResource$resolve_codeable_concept()`.
#' @returns See `FhirResource$resolve_codeable_concept()`.
#' @seealso [FhirResource], [fhir_resolve()], [fhir_resolve_batch()]
#' @examples
#' \dontrun{
#' client <- OMOPHubClient$new(api_key = Sys.getenv("OMOPHUB_API_KEY"))
#' fhir_resolve_codeable_concept(
#'   client,
#'   coding = list(
#'     list(system = "http://snomed.info/sct", code = "44054006"),
#'     list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
#'   ),
#'   resource_type = "Condition"
#' )
#' }
#' @export
fhir_resolve_codeable_concept <- function(client, ...) {
  client$fhir$resolve_codeable_concept(...)
}
