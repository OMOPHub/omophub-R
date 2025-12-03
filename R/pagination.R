#' Fetch All Paginated Results
#'
#' @description
#' Fetches all pages of results and combines them into a single tibble.
#'
#' @param fetch_fn A function that takes `page` and `size` arguments and returns
#'   a list with `data` (the results) and `meta` (pagination metadata).
#' @param page_size Number of items per page. Default 100.
#' @param max_pages Maximum number of pages to fetch. Default `Inf`.
#' @param progress Show progress bar. Default `TRUE`.
#'
#' @returns A tibble containing all fetched results.
#'
#' @keywords internal
paginate_all <- function(fetch_fn, page_size = 100, max_pages = Inf, progress = TRUE) {
  all_data <- list()
  page <- 1
  has_more <- TRUE

  # Progress bar setup
  pb <- NULL
  if (progress && interactive()) {
    cli::cli_progress_bar(
      "Fetching pages",
      total = NA,
      format = "{cli::pb_spin} Fetching page {page}... ({length(all_data)} items)"
    )
  }

  while (has_more && page <= max_pages) {
    result <- fetch_fn(page, page_size)

    data <- result$data
    meta <- result$meta

    if (length(data) == 0) {
      break
    }

    all_data <- c(all_data, data)

    if (progress && interactive()) {
      cli::cli_progress_update()
    }

    # Check if there are more pages
    if (!is.null(meta$has_next)) {
      has_more <- isTRUE(meta$has_next)
    } else if (!is.null(meta$total_pages)) {
      has_more <- page < meta$total_pages
    } else {
      # If no pagination info, check if we got fewer results than requested
      has_more <- length(data) >= page_size
    }

    page <- page + 1
  }

  if (progress && interactive()) {
    cli::cli_progress_done()
  }

  # Convert list of lists to tibble
  if (length(all_data) == 0) {
    return(tibble::tibble())
  }

  # Try to bind rows - all_data is a list of concept lists
  tryCatch(
    {
      # Convert each concept to a tibble row and bind them
      tibble_list <- purrr::map(all_data, function(item) {
        if (is.data.frame(item)) {
          tibble::as_tibble(item)
        } else if (is.list(item) && !is.null(names(item))) {
          # Named list - convert NULL values to NA for proper tibble conversion
          item <- purrr::map(item, ~ if (is.null(.x)) NA else .x)
          tibble::as_tibble(item)
        } else {
          tibble::tibble(value = list(item))
        }
      })
      purrr::list_rbind(tibble_list)
    },
    error = function(e) {
      # If list_rbind fails, return list as-is with warning
      warning("Could not convert results to tibble: ", e$message)
      all_data
    }
  )
}

#' Create Lazy Pagination Iterator
#'
#' @description
#' Creates an iterator that fetches pages on demand.
#'
#' @param fetch_fn A function that takes `page` and `size` arguments.
#' @param page_size Number of items per page. Default 100.
#'
#' @returns An iterator object with `next_page()` and `has_more()` methods.
#'
#' @keywords internal
paginate_lazy <- function(fetch_fn, page_size = 100) {
  env <- new.env(parent = emptyenv())
  env$current_page <- 0
  env$has_more <- TRUE
  env$last_result <- NULL

  list(
    #' Get next page of results
    next_page = function() {
      if (!env$has_more) {
        return(NULL)
      }

      env$current_page <- env$current_page + 1
      result <- fetch_fn(env$current_page, page_size)

      env$last_result <- result

      # Check if there are more pages
      meta <- result$meta
      if (!is.null(meta$has_next)) {
        env$has_more <- isTRUE(meta$has_next)
      } else if (!is.null(meta$total_pages)) {
        env$has_more <- env$current_page < meta$total_pages
      } else {
        env$has_more <- length(result$data) >= page_size
      }

      result$data
    },

    #' Check if more pages are available
    has_more = function() {
      env$has_more
    },

    #' Get current page number
    current_page = function() {
      env$current_page
    },

    #' Reset iterator to beginning
    reset = function() {
      env$current_page <- 0
      env$has_more <- TRUE
      env$last_result <- NULL
      invisible(NULL)
    }
  )
}

#' Extract Pagination Metadata
#'
#' @description
#' Extracts pagination metadata from an API response.
#'
#' @param response API response object.
#'
#' @returns A list with pagination fields.
#'
#' @keywords internal
extract_pagination <- function(response) {
  meta <- response$meta$pagination %||% response$meta %||% list()

  list(
    page = meta$page %||% 1L,
    page_size = meta$page_size %||% meta$per_page %||% 20L,
    total_items = meta$total_items %||% meta$total %||% NA_integer_,
    total_pages = meta$total_pages %||% NA_integer_,
    has_next = meta$has_next %||% NA,
    has_previous = meta$has_previous %||% NA
  )
}
