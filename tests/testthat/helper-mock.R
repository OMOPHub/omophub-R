# Mock helpers for testing

#' Create a mock response for testing
#'
#' @param data Response data
#' @param status HTTP status code
#' @param meta Pagination metadata
#' @keywords internal
mock_response <- function(data = list(), status = 200, meta = list()) {
  list(
    data = data,
    meta = meta,
    status = status
  )
}

#' Create mock concept data
#' @keywords internal
mock_concept <- function(
    concept_id = 201826,
    concept_name = "Type 2 diabetes mellitus",
    vocabulary_id = "SNOMED",
    domain_id = "Condition",
    concept_class_id = "Clinical Finding",
    standard_concept = "S",
    concept_code = "44054006"
) {
  list(
    concept_id = concept_id,
    concept_name = concept_name,
    vocabulary_id = vocabulary_id,
    domain_id = domain_id,
    concept_class_id = concept_class_id,
    standard_concept = standard_concept,
    concept_code = concept_code
  )
}

#' Create mock vocabulary data
#' @keywords internal
mock_vocabulary <- function(
    vocabulary_id = "SNOMED",
    vocabulary_name = "Systematic Nomenclature of Medicine - Clinical Terms",
    vocabulary_version = "2024-07-01",
    vocabulary_reference = "http://www.snomed.org/"
) {
  list(
    vocabulary_id = vocabulary_id,
    vocabulary_name = vocabulary_name,
    vocabulary_version = vocabulary_version,
    vocabulary_reference = vocabulary_reference
  )
}

#' Create mock pagination metadata
#' @keywords internal
mock_pagination <- function(
    page = 1,
    page_size = 20,
    total_items = 100,
    has_next = TRUE,
    has_previous = FALSE
) {
  list(
    pagination = list(
      page = page,
      page_size = page_size,
      total_items = total_items,
      total_pages = ceiling(total_items / page_size),
      has_next = has_next,
      has_previous = has_previous
    )
  )
}
