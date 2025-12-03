#' Create OMOPHub Concepts Result
#'
#' @description
#' Creates an S3 object for concept search results.
#'
#' @param data Concept data (list or tibble).
#' @param meta Pagination metadata.
#'
#' @returns An `omophub_concepts` S3 object.
#' @keywords internal
new_omophub_concepts <- function(data, meta = list()) {
  # Convert data to tibble if it's a list
  if (is.list(data) && !inherits(data, "data.frame")) {
    data <- tryCatch(
      purrr::list_rbind(purrr::map(data, tibble::as_tibble)),
      error = function(e) tibble::tibble(data = data)
    )
  }

  structure(
    list(
      data = tibble::as_tibble(data),
      total = meta$total_items %||% meta$total %||% nrow(data),
      page = meta$page %||% 1L,
      page_size = meta$page_size %||% nrow(data),
      has_next = meta$has_next %||% FALSE
    ),
    class = c("omophub_concepts", "list")
  )
}

#' @export
print.omophub_concepts <- function(x, ...) {
  cat("<OMOPHub Concept Results>\n")
  cat("  Total:", x$total, "concepts found\n")
  cat("  Showing:", nrow(x$data), "results (page", x$page, ")\n\n")
  print(x$data, n = 10)
  if (nrow(x$data) > 10) {
    cat("# ... with", nrow(x$data) - 10, "more rows\n")
  }
  invisible(x)
}

#' @export
as.data.frame.omophub_concepts <- function(x, ...) {
  as.data.frame(x$data)
}

#' Create OMOPHub Vocabularies Result
#'
#' @param data Vocabulary data.
#' @param meta Pagination metadata.
#' @returns An `omophub_vocabularies` S3 object.
#' @keywords internal
new_omophub_vocabularies <- function(data, meta = list()) {
  if (is.list(data) && !inherits(data, "data.frame")) {
    data <- tryCatch(
      purrr::list_rbind(purrr::map(data, tibble::as_tibble)),
      error = function(e) tibble::tibble(data = data)
    )
  }

  structure(
    list(
      data = tibble::as_tibble(data),
      total = meta$total_items %||% nrow(data)
    ),
    class = c("omophub_vocabularies", "list")
  )
}

#' @export
print.omophub_vocabularies <- function(x, ...) {
  cat("<OMOPHub Vocabularies>\n")
  cat("  Total:", x$total, "vocabularies\n\n")
  print(x$data, n = 10)
  invisible(x)
}

#' @export
as.data.frame.omophub_vocabularies <- function(x, ...) {
  as.data.frame(x$data)
}

#' Create OMOPHub Hierarchy Result
#'
#' @param data Hierarchy data (ancestors or descendants).
#' @param meta Metadata including summary.
#' @param type Type of hierarchy ("ancestors" or "descendants").
#' @returns An `omophub_hierarchy` S3 object.
#' @keywords internal
new_omophub_hierarchy <- function(data, meta = list(), type = "hierarchy") {
  if (is.list(data) && !inherits(data, "data.frame")) {
    data <- tryCatch(
      purrr::list_rbind(purrr::map(data, tibble::as_tibble)),
      error = function(e) tibble::tibble(data = data)
    )
  }

  structure(
    list(
      data = tibble::as_tibble(data),
      type = type,
      total = meta$total_items %||% nrow(data),
      summary = meta$summary %||% list()
    ),
    class = c("omophub_hierarchy", "list")
  )
}

#' @export
print.omophub_hierarchy <- function(x, ...) {
  cat("<OMOPHub Hierarchy:", x$type, ">\n")
  cat("  Total:", x$total, "concepts\n\n")
  print(x$data, n = 10)
  invisible(x)
}

#' @export
as.data.frame.omophub_hierarchy <- function(x, ...) {
  as.data.frame(x$data)
}

#' Create OMOPHub Relationships Result
#'
#' @param data Relationship data.
#' @param meta Metadata.
#' @returns An `omophub_relationships` S3 object.
#' @keywords internal
new_omophub_relationships <- function(data, meta = list()) {
  if (is.list(data) && !inherits(data, "data.frame")) {
    data <- tryCatch(
      purrr::list_rbind(purrr::map(data, tibble::as_tibble)),
      error = function(e) tibble::tibble(data = data)
    )
  }

  structure(
    list(
      data = tibble::as_tibble(data),
      total = meta$total_items %||% nrow(data),
      summary = meta$summary %||% list()
    ),
    class = c("omophub_relationships", "list")
  )
}

#' @export
print.omophub_relationships <- function(x, ...) {
  cat("<OMOPHub Relationships>\n")
  cat("  Total:", x$total, "relationships\n\n")
  print(x$data, n = 10)
  invisible(x)
}

#' @export
as.data.frame.omophub_relationships <- function(x, ...) {
  as.data.frame(x$data)
}

#' Create OMOPHub Mappings Result
#'
#' @param data Mapping data.
#' @param meta Metadata.
#' @returns An `omophub_mappings` S3 object.
#' @keywords internal
new_omophub_mappings <- function(data, meta = list()) {
  if (is.list(data) && !inherits(data, "data.frame")) {
    data <- tryCatch(
      purrr::list_rbind(purrr::map(data, tibble::as_tibble)),
      error = function(e) tibble::tibble(data = data)
    )
  }

  structure(
    list(
      data = tibble::as_tibble(data),
      total = meta$total_items %||% nrow(data),
      summary = meta$summary %||% list()
    ),
    class = c("omophub_mappings", "list")
  )
}

#' @export
print.omophub_mappings <- function(x, ...) {
  cat("<OMOPHub Mappings>\n")
  cat("  Total:", x$total, "mappings\n\n")
  print(x$data, n = 10)
  invisible(x)
}

#' @export
as.data.frame.omophub_mappings <- function(x, ...) {
  as.data.frame(x$data)
}
