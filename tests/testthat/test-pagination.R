# Tests for pagination utilities (R/pagination.R)

# ==============================================================================
# extract_pagination
# ==============================================================================

test_that("extract_pagination extracts nested pagination metadata", {
  response <- list(
    meta = list(
      pagination = list(
        page = 2,
        page_size = 50,
        total_items = 200,
        total_pages = 4,
        has_next = TRUE,
        has_previous = TRUE
      )
    )
  )

  result <- extract_pagination(response)

  expect_equal(result$page, 2)
  expect_equal(result$page_size, 50)

  expect_equal(result$total_items, 200)
  expect_equal(result$total_pages, 4)
  expect_true(result$has_next)
  expect_true(result$has_previous)
})

test_that("extract_pagination extracts flat meta format", {
  response <- list(
    meta = list(
      page = 1,
      page_size = 20,
      total_items = 50,
      has_next = FALSE
    )
  )

  result <- extract_pagination(response)

  expect_equal(result$page, 1)
  expect_equal(result$page_size, 20)
  expect_equal(result$total_items, 50)
  expect_false(result$has_next)
})

test_that("extract_pagination uses defaults for missing fields", {
  response <- list(meta = list())

  result <- extract_pagination(response)

  expect_equal(result$page, 1L)
  expect_equal(result$page_size, 20L)
  expect_true(is.na(result$total_items))
  expect_true(is.na(result$total_pages))
  expect_true(is.na(result$has_next))
  expect_true(is.na(result$has_previous))
})

test_that("extract_pagination handles NULL response", {
  result <- extract_pagination(list())

  expect_equal(result$page, 1L)
  expect_equal(result$page_size, 20L)
})

test_that("extract_pagination handles per_page alias", {
  response <- list(
    meta = list(
      page = 1,
      per_page = 25
    )
  )

  result <- extract_pagination(response)

  expect_equal(result$page_size, 25)
})

test_that("extract_pagination handles total alias", {
  response <- list(
    meta = list(
      total = 150
    )
  )

  result <- extract_pagination(response)

  expect_equal(result$total_items, 150)
})

# ==============================================================================
# paginate_lazy
# ==============================================================================

test_that("paginate_lazy creates iterator with correct methods", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = page)),
      meta = list(has_next = page < 3)
    )
  }

  iterator <- paginate_lazy(fetch_fn, page_size = 10)

  expect_type(iterator, "list")
  expect_true("next_page" %in% names(iterator))
  expect_true("has_more" %in% names(iterator))
  expect_true("current_page" %in% names(iterator))
  expect_true("reset" %in% names(iterator))
})

test_that("paginate_lazy starts at page 0", {
  fetch_fn <- function(page, size) list(data = list(), meta = list(has_next = FALSE))

  iterator <- paginate_lazy(fetch_fn)

  expect_equal(iterator$current_page(), 0)
  expect_true(iterator$has_more())
})

test_that("paginate_lazy next_page fetches sequential pages", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = page)),
      meta = list(has_next = page < 3)
    )
  }

  iterator <- paginate_lazy(fetch_fn, page_size = 10)

  result1 <- iterator$next_page()
  expect_equal(iterator$current_page(), 1)
  expect_equal(result1[[1]]$id, 1)
  expect_true(iterator$has_more())

  result2 <- iterator$next_page()
  expect_equal(iterator$current_page(), 2)
  expect_equal(result2[[1]]$id, 2)
  expect_true(iterator$has_more())

  result3 <- iterator$next_page()
  expect_equal(iterator$current_page(), 3)
  expect_equal(result3[[1]]$id, 3)
  expect_false(iterator$has_more())
})

test_that("paginate_lazy returns NULL when no more pages", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = page)),
      meta = list(has_next = FALSE)
    )
  }

  iterator <- paginate_lazy(fetch_fn)

  # First page
  iterator$next_page()
  expect_false(iterator$has_more())

  # Should return NULL when no more pages
  result <- iterator$next_page()
  expect_null(result)
})

test_that("paginate_lazy reset works correctly", {
  call_count <- 0
  fetch_fn <- function(page, size) {
    call_count <<- call_count + 1
    list(
      data = list(list(id = page)),
      meta = list(has_next = page < 2)
    )
  }

  iterator <- paginate_lazy(fetch_fn)

  # Fetch first two pages
  iterator$next_page()
  iterator$next_page()
  expect_equal(iterator$current_page(), 2)
  expect_false(iterator$has_more())

  # Reset
  iterator$reset()
  expect_equal(iterator$current_page(), 0)
  expect_true(iterator$has_more())

  # Fetch again
  result <- iterator$next_page()
  expect_equal(result[[1]]$id, 1)
})

test_that("paginate_lazy uses total_pages when has_next not available", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = page)),
      meta = list(total_pages = 2)
    )
  }

  iterator <- paginate_lazy(fetch_fn)

  iterator$next_page()
  expect_true(iterator$has_more())

  iterator$next_page()
  expect_false(iterator$has_more())
})

test_that("paginate_lazy uses data length when no pagination info", {
  fetch_fn <- function(page, size) {
    # Return fewer items than page_size to signal end
    if (page == 1) {
      list(data = as.list(1:10), meta = list())
    } else {
      list(data = as.list(1:5), meta = list())  # Less than page_size
    }
  }

  iterator <- paginate_lazy(fetch_fn, page_size = 10)

  iterator$next_page()
  expect_true(iterator$has_more())  # Got 10 items = page_size

  iterator$next_page()
  expect_false(iterator$has_more())  # Got 5 items < page_size
})

# ==============================================================================
# paginate_all
# ==============================================================================

test_that("paginate_all fetches all pages and combines to tibble", {
  fetch_fn <- function(page, size) {
    if (page <= 3) {
      list(
        data = list(
          list(id = (page - 1) * 2 + 1, name = paste0("Item", (page - 1) * 2 + 1)),
          list(id = (page - 1) * 2 + 2, name = paste0("Item", (page - 1) * 2 + 2))
        ),
        meta = list(has_next = page < 3)
      )
    } else {
      list(data = list(), meta = list(has_next = FALSE))
    }
  }

  result <- paginate_all(fetch_fn, page_size = 2, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 6)  # 3 pages * 2 items
  expect_true("id" %in% names(result))
  expect_true("name" %in% names(result))
})

test_that("paginate_all respects max_pages limit", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = page)),
      meta = list(has_next = TRUE)  # Always has more
    )
  }

  result <- paginate_all(fetch_fn, page_size = 1, max_pages = 2, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)  # Limited to 2 pages
})

test_that("paginate_all returns empty tibble for no results", {
  fetch_fn <- function(page, size) {
    list(data = list(), meta = list(has_next = FALSE))
  }

  result <- paginate_all(fetch_fn, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("paginate_all handles single page result", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = 1, name = "Only item")),
      meta = list(has_next = FALSE)
    )
  }

  result <- paginate_all(fetch_fn, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
})

test_that("paginate_all stops when data is empty", {
  call_count <- 0
  fetch_fn <- function(page, size) {
    call_count <<- call_count + 1
    if (page == 1) {
      list(
        data = list(list(id = 1)),
        meta = list(has_next = TRUE)  # Says there's more
      )
    } else {
      list(data = list(), meta = list(has_next = TRUE))  # But returns empty
    }
  }

  result <- paginate_all(fetch_fn, progress = FALSE)

  expect_equal(nrow(result), 1)
  expect_equal(call_count, 2)  # Called twice, stopped on empty
})

test_that("paginate_all handles data frames in results", {
  fetch_fn <- function(page, size) {
    list(
      data = list(
        data.frame(id = page, name = paste0("Item", page))
      ),
      meta = list(has_next = page < 2)
    )
  }

  result <- paginate_all(fetch_fn, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
})

test_that("paginate_all uses total_pages when has_next not available", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = page)),
      meta = list(total_pages = 3)
    )
  }

  result <- paginate_all(fetch_fn, progress = FALSE)

  expect_equal(nrow(result), 3)
})

test_that("paginate_all handles NULL values in data", {
  fetch_fn <- function(page, size) {
    list(
      data = list(list(id = page, name = NULL, value = "test")),
      meta = list(has_next = page < 2)
    )
  }

  result <- paginate_all(fetch_fn, progress = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  # NULL values should become NA
  expect_true(all(is.na(result$name)))
})
