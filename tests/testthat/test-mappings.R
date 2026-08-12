# Unit tests for MappingsResource (R/mappings.R)
# Uses mocked HTTP responses to avoid API calls

# ==============================================================================
# MappingsResource initialization
# ==============================================================================

test_that("MappingsResource initializes correctly", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_s3_class(resource, "MappingsResource")
  expect_s3_class(resource, "R6")
})

test_that("MappingsResource print method works", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_output(print(resource), "<OMOPHub MappingsResource>")
  expect_output(print(resource), "get, get_all, map")
})

# ==============================================================================
# get() method
# ==============================================================================

test_that("mappings$get validates concept_id", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(resource$get("invalid"))
  expect_error(resource$get(-1))
})

test_that("mappings$get calls correct endpoint", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(path = path, query = query)
      list(mappings = list())
    }
  )

  resource$get(201826)

  expect_equal(called_with$path, "concepts/201826/mappings")
})

test_that("mappings$get sends pagination params, defaults included", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826)
  expect_equal(called_with$query$page, 1L)
  expect_equal(called_with$query$page_size, 100L)

  resource$get(201826, page = 3, page_size = 200)
  expect_equal(called_with$query$page, 3L)
  expect_equal(called_with$query$page_size, 200L)
})

test_that("mappings$get rejects a page_size above the server ceiling", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(resource$get(201826, page_size = 500))
  expect_error(resource$get(201826, page = 0))
})

test_that("mappings$get keeps $mappings reachable when the API returns pagination", {
  # Regression guard: perform_get() changes shape once meta.pagination is
  # present, which silently moved mappings to $data$mappings for callers.
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  pagination <- list(
    page = 1L, page_size = 100L, total_items = 232L,
    total_pages = 3L, has_next = TRUE, has_previous = FALSE
  )
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      list(
        data = list(mappings = list(list(target_concept_id = 1))),
        meta = pagination
      )
    }
  )

  result <- resource$get(201826)

  expect_length(result$mappings, 1)
  expect_equal(attr(result, "pagination")$total_items, 232L)
  expect_true(attr(result, "pagination")$has_next)
})

test_that("mappings$get_all walks every page", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  pages_requested <- integer(0)
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      page <- query$page
      pages_requested <<- c(pages_requested, page)
      list(
        data = list(mappings = list(list(target_concept_id = page))),
        meta = list(
          page = page, page_size = 1L, total_items = 2L,
          total_pages = 2L, has_next = page < 2L, has_previous = page > 1L
        )
      )
    }
  )

  result <- resource$get_all(201826, page_size = 1, progress = FALSE)

  expect_equal(pages_requested, c(1L, 2L))
  expect_equal(nrow(result), 2)
  expect_equal(result$target_concept_id, c(1L, 2L))
})

test_that("mappings$get_all stops after one page without pagination metadata", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  calls <- 0L
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      calls <<- calls + 1L
      list(mappings = list(list(target_concept_id = 1)))
    }
  )

  result <- resource$get_all(201826, page_size = 100, progress = FALSE)

  expect_equal(calls, 1L)
  expect_equal(nrow(result), 1)
})

test_that("mappings$get includes target vocabulary filter", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, target_vocabulary = "ICD10CM")

  expect_equal(called_with$query$target_vocabulary, "ICD10CM")
})

test_that("mappings$get includes include_invalid option", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, include_invalid = TRUE)

  expect_equal(called_with$query$include_invalid, "true")
})

# @param-order vs signature is checked for every R6 method in the package
# by test-roxygen-param-order.R, so there is no mappings-only copy here.
test_that("mappings$get keeps the 1.8.1 positional contract", {
  # 1.8.1 shipped get(concept_id, target_vocabulary, include_invalid,
  # vocab_release). New arguments must be APPENDED: inserting one shifts every
  # positional caller onto the wrong parameter, and because the new arguments
  # validate their types, the symptom is a validation error rather than a
  # wrong result.
  formal_names <- names(formals(MappingsResource$public_methods$get))
  expect_equal(
    formal_names[1:4],
    c("concept_id", "target_vocabulary", "include_invalid", "vocab_release")
  )

  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  # The exact positional call a 1.8.1 user could have written.
  resource$get(201826, "ICD10CM", FALSE, "2025.1")

  expect_equal(called_with$query$target_vocabulary, "ICD10CM")
  expect_equal(called_with$query$include_invalid, "false")
  expect_equal(called_with$query$vocab_release, "2025.1")
  expect_null(called_with$query$relationship_ids)
})

test_that("mappings$get comma-joins relationship_ids", {
  # Value-as-Concept is unreachable without this: the server defaults to
  # "Maps to" alone, so a composite concept returns only half its
  # decomposition unless "Maps to value" is asked for too.
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(4167462)
  expect_null(called_with$query$relationship_ids)

  resource$get(4167462, relationship_ids = c("Maps to", "Maps to value"))
  expect_equal(called_with$query$relationship_ids, "Maps to,Maps to value")

  resource$get(4167462, relationship_ids = "Maps to value")
  expect_equal(called_with$query$relationship_ids, "Maps to value")
})

test_that("mappings$get_all forwards relationship_ids", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      structure(
        list(mappings = list()),
        pagination = list(
          page = 1, page_size = 100, total_items = 0,
          total_pages = 0, has_next = FALSE, has_previous = FALSE
        )
      )
    }
  )

  resource$get_all(
    4167462,
    relationship_ids = c("Maps to", "Maps to value"),
    progress = FALSE
  )

  expect_equal(called_with$query$relationship_ids, "Maps to,Maps to value")
})

test_that("mappings$get rejects a non-character relationship_ids", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) list(mappings = list())
  )

  expect_error(resource$get(4167462, relationship_ids = 42))
})

test_that("mappings$get treats include_invalid as tri-state, not a flag", {
  # This endpoint defaults to *including* deprecated mappings, so omitting the
  # parameter and sending "false" are different requests. FALSE used to be
  # dropped as falsy, silently returning the rows the caller asked to exclude.
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826)
  expect_null(called_with$query$include_invalid)

  resource$get(201826, include_invalid = FALSE)
  expect_equal(called_with$query$include_invalid, "false")

  resource$get(201826, include_invalid = TRUE)
  expect_equal(called_with$query$include_invalid, "true")
})

test_that("mappings$get_all forwards include_invalid = FALSE", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      structure(
        list(mappings = list()),
        pagination = list(
          page = 1, page_size = 100, total_items = 0,
          total_pages = 0, has_next = FALSE, has_previous = FALSE
        )
      )
    }
  )

  resource$get_all(201826, include_invalid = FALSE, progress = FALSE)

  expect_equal(called_with$query$include_invalid, "false")
})

test_that("mappings$get rejects a non-flag include_invalid", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) list(mappings = list())
  )

  expect_error(resource$get(201826, include_invalid = "yes"))
})

test_that("mappings$get includes vocab_release option", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_get = function(req, path, query = NULL) {
      called_with <<- list(query = query)
      list(mappings = list())
    }
  )

  resource$get(201826, vocab_release = "2025.1")

  expect_equal(called_with$query$vocab_release, "2025.1")
})

# ==============================================================================
# map() method
# ==============================================================================

test_that("mappings$map validates target_vocabulary", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(resource$map("", source_concepts = c(201826)))
  expect_error(resource$map(123, source_concepts = c(201826)))
})

test_that("mappings$map calls correct endpoint with body", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(path = path, body = body, query = query)
      list(mappings = list(), summary = list())
    }
  )

  resource$map("ICD10CM", source_concepts = c(201826, 12345))

  expect_equal(called_with$path, "concepts/map")
  expect_equal(called_with$body$source_concepts, c(201826L, 12345L))
  expect_equal(called_with$body$target_vocabulary, "ICD10CM")
})

test_that("mappings$map includes optional parameters", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(body = body, query = query)
      list(mappings = list())
    }
  )

  resource$map(
    "ICD10CM",
    source_concepts = c(201826),
    mapping_type = "equivalent",
    include_invalid = TRUE
  )

  expect_equal(called_with$body$mapping_type, "equivalent")
  expect_true(called_with$body$include_invalid)
})

# ==============================================================================
# map() with source_codes
# ==============================================================================

test_that("mappings$map works with source_codes", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  called_with <- NULL
  local_mocked_bindings(
    perform_post = function(req, path, body = NULL, query = NULL) {
      called_with <<- list(path = path, body = body)
      list(mappings = list())
    }
  )

  resource$map(
    target_vocabulary = "RxNorm",
    source_codes = list(
      list(vocabulary_id = "SNOMED", concept_code = "387517004"),
      list(vocabulary_id = "SNOMED", concept_code = "108774000")
    )
  )

  expect_equal(called_with$path, "concepts/map")
  expect_equal(called_with$body$target_vocabulary, "RxNorm")
  expect_true("source_codes" %in% names(called_with$body))
  expect_equal(length(called_with$body$source_codes), 2)
  expect_equal(called_with$body$source_codes[[1]]$vocabulary_id, "SNOMED")
})

test_that("mappings$map requires either source_concepts or source_codes", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(
    resource$map(target_vocabulary = "ICD10CM"),
    "Either source_concepts or source_codes is required"
  )
})

test_that("mappings$map rejects both source_concepts and source_codes", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  expect_error(
    resource$map(
      target_vocabulary = "ICD10CM",
      source_concepts = c(201826),
      source_codes = list(list(vocabulary_id = "SNOMED", concept_code = "44054006"))
    ),
    "Cannot use both source_concepts and source_codes"
  )
})

test_that("mappings$map validates source_codes structure", {
  base_req <- httr2::request("https://api.omophub.com/v1")
  resource <- MappingsResource$new(base_req)

  # Missing vocabulary_id
  expect_error(
    resource$map(
      target_vocabulary = "ICD10CM",
      source_codes = list(list(concept_code = "44054006"))
    ),
    "must have 'vocabulary_id' and 'concept_code'"
  )

  # Missing concept_code
  expect_error(
    resource$map(
      target_vocabulary = "ICD10CM",
      source_codes = list(list(vocabulary_id = "SNOMED"))
    ),
    "must have 'vocabulary_id' and 'concept_code'"
  )
})
