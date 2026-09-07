# Tests for pagination preservation in perform_post (R/request.R)
#
# `/v1/search/similar` is paginated, but its pagination sits in the response
# envelope's `meta` while the results sit in `data`. `perform_post` unwrapped to
# `data` unconditionally, so a caller who passed `page` had no way to learn
# whether another page existed. `perform_get` already preserved it; this brings
# the POST path into line, opt-in so no other resource's return shape changes.

json_response <- function(body) {
  httr2::response(
    status_code = 200,
    headers = list(`content-type` = "application/json"),
    body = charToRaw(jsonlite::toJSON(body, auto_unbox = TRUE))
  )
}

test_that("perform_post preserves pagination when asked", {
  httr2::local_mocked_responses(list(json_response(list(
    success = TRUE,
    data = list(similar_concepts = list(), search_metadata = list()),
    meta = list(pagination = list(
      page = 2, page_size = 20, total_items = 55,
      total_pages = 3, has_next = TRUE, has_previous = TRUE
    ))
  ))))

  result <- perform_post(
    httr2::request("https://api.omophub.com/v1"), "search/similar",
    body = list(concept_id = 201826), preserve_pagination = TRUE
  )

  expect_true(result$pagination$has_next)
  expect_equal(result$pagination$page, 2)
  # The existing shape is unchanged.
  expect_true("similar_concepts" %in% names(result))
})

test_that("perform_post unwraps to data by default", {
  httr2::local_mocked_responses(list(json_response(list(
    success = TRUE,
    data = list(similar_concepts = list(), search_metadata = list()),
    meta = list(pagination = list(page = 1, has_next = FALSE))
  ))))

  result <- perform_post(
    httr2::request("https://api.omophub.com/v1"), "search/similar",
    body = list(concept_id = 201826)
  )

  # Every other POST resource keeps the shape it had.
  expect_null(result$pagination)
})

test_that("perform_post adds no pagination element when meta carries none", {
  httr2::local_mocked_responses(list(json_response(list(
    success = TRUE,
    data = list(similar_concepts = list(), search_metadata = list())
  ))))

  result <- perform_post(
    httr2::request("https://api.omophub.com/v1"), "search/similar",
    body = list(concept_id = 201826), preserve_pagination = TRUE
  )

  expect_null(result$pagination)
})

test_that("search$similar exposes pagination end to end", {
  httr2::local_mocked_responses(function(req) {
    expect_equal(req$body$data$page, 3)
    json_response(list(
      success = TRUE,
      data = list(similar_concepts = list(), search_metadata = list()),
      meta = list(pagination = list(
        page = req$body$data$page,
        has_next = FALSE
      ))
    ))
  })

  resource <- SearchResource$new(httr2::request("https://api.omophub.com/v1"))
  result <- resource$similar(concept_id = 201826, page = 3)

  expect_equal(result$pagination$page, 3)
  expect_false(result$pagination$has_next)
})
