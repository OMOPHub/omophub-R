# Tests for S3 response classes (R/response.R)

# ==============================================================================
# omophub_concepts
# ==============================================================================

test_that("new_omophub_concepts creates correct S3 class from list", {
  data <- list(mock_concept(), mock_concept(concept_id = 12345))
  meta <- list(total_items = 100, page = 1, page_size = 20, has_next = TRUE)

  result <- new_omophub_concepts(data, meta)

  expect_s3_class(result, "omophub_concepts")
  expect_s3_class(result, "list")
  expect_s3_class(result$data, "tbl_df")
  expect_equal(nrow(result$data), 2)
  expect_equal(result$total, 100)
  expect_equal(result$page, 1)
  expect_equal(result$page_size, 20)
  expect_true(result$has_next)
})

test_that("new_omophub_concepts handles tibble input", {
  data <- tibble::tibble(
    concept_id = c(201826, 12345),
    concept_name = c("Diabetes", "Hypertension")
  )
  meta <- list(total_items = 2)

  result <- new_omophub_concepts(data, meta)

  expect_s3_class(result, "omophub_concepts")
  expect_equal(nrow(result$data), 2)
  expect_equal(result$total, 2)
})

test_that("new_omophub_concepts handles empty list", {
  result <- new_omophub_concepts(list(), list())

  expect_s3_class(result, "omophub_concepts")
  expect_equal(nrow(result$data), 0)
  expect_equal(result$total, 0)
})

test_that("new_omophub_concepts uses defaults when meta is empty", {
  data <- list(mock_concept())
  result <- new_omophub_concepts(data, list())

  expect_equal(result$page, 1L)
  expect_equal(result$has_next, FALSE)
})

test_that("print.omophub_concepts outputs expected format", {
  data <- list(mock_concept())
  result <- new_omophub_concepts(data, list(total_items = 100, page = 1))

  expect_output(print(result), "<OMOPHub Concept Results>")
  expect_output(print(result), "Total: 100 concepts found")
  expect_output(print(result), "page 1")
})

test_that("print.omophub_concepts returns object invisibly", {
  data <- list(mock_concept())
  result <- new_omophub_concepts(data, list())

  expect_invisible(print(result))
})

test_that("as.data.frame.omophub_concepts returns data.frame", {
  data <- list(mock_concept(), mock_concept(concept_id = 12345))
  result <- new_omophub_concepts(data, list())

  df <- as.data.frame(result)

  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 2)
  expect_true("concept_id" %in% names(df))
})

# ==============================================================================
# omophub_vocabularies
# ==============================================================================

test_that("new_omophub_vocabularies creates correct S3 class", {
  data <- list(mock_vocabulary(), mock_vocabulary(vocabulary_id = "ICD10CM"))
  meta <- list(total_items = 50)


  result <- new_omophub_vocabularies(data, meta)

  expect_s3_class(result, "omophub_vocabularies")
  expect_s3_class(result$data, "tbl_df")
  expect_equal(nrow(result$data), 2)
  expect_equal(result$total, 50)
})

test_that("new_omophub_vocabularies handles empty data", {
  result <- new_omophub_vocabularies(list(), list())

  expect_s3_class(result, "omophub_vocabularies")
  expect_equal(nrow(result$data), 0)
})

test_that("print.omophub_vocabularies outputs expected format", {
  data <- list(mock_vocabulary())
  result <- new_omophub_vocabularies(data, list(total_items = 10))

  expect_output(print(result), "<OMOPHub Vocabularies>")
  expect_output(print(result), "Total: 10 vocabularies")
})

test_that("as.data.frame.omophub_vocabularies returns data.frame", {
  data <- list(mock_vocabulary())
  result <- new_omophub_vocabularies(data, list())

  df <- as.data.frame(result)

  expect_s3_class(df, "data.frame")
  expect_true("vocabulary_id" %in% names(df))
})

# ==============================================================================
# omophub_hierarchy
# ==============================================================================

test_that("new_omophub_hierarchy creates correct S3 class", {
  data <- list(mock_concept(), mock_concept(concept_id = 999))
  meta <- list(total_items = 5, summary = list(max_level = 3))

  result <- new_omophub_hierarchy(data, meta, type = "ancestors")

  expect_s3_class(result, "omophub_hierarchy")
  expect_s3_class(result$data, "tbl_df")
  expect_equal(nrow(result$data), 2)
  expect_equal(result$type, "ancestors")
  expect_equal(result$total, 5)
  expect_equal(result$summary$max_level, 3)
})

test_that("new_omophub_hierarchy handles descendants type", {
  result <- new_omophub_hierarchy(list(), list(), type = "descendants")

  expect_equal(result$type, "descendants")
})

test_that("print.omophub_hierarchy outputs expected format", {
  data <- list(mock_concept())
  result <- new_omophub_hierarchy(data, list(total_items = 3), type = "ancestors")

  expect_output(print(result), "<OMOPHub Hierarchy: ancestors")
  expect_output(print(result), "Total: 3 concepts")
})

test_that("as.data.frame.omophub_hierarchy returns data.frame", {
  data <- list(mock_concept())
  result <- new_omophub_hierarchy(data, list())

  df <- as.data.frame(result)

  expect_s3_class(df, "data.frame")
})

# ==============================================================================
# omophub_relationships
# ==============================================================================

test_that("new_omophub_relationships creates correct S3 class", {
  data <- list(
    list(
      relationship_id = "Is a",
      concept_id_1 = 201826,
      concept_id_2 = 999
    )
  )
  meta <- list(total_items = 10)

  result <- new_omophub_relationships(data, meta)

  expect_s3_class(result, "omophub_relationships")
  expect_s3_class(result$data, "tbl_df")
  expect_equal(result$total, 10)
})

test_that("new_omophub_relationships handles empty data", {
  result <- new_omophub_relationships(list(), list())

  expect_s3_class(result, "omophub_relationships")
  expect_equal(nrow(result$data), 0)
})

test_that("print.omophub_relationships outputs expected format", {
  data <- list(list(relationship_id = "Is a", concept_id_1 = 1, concept_id_2 = 2))
  result <- new_omophub_relationships(data, list(total_items = 5))

  expect_output(print(result), "<OMOPHub Relationships>")
  expect_output(print(result), "Total: 5 relationships")
})

test_that("as.data.frame.omophub_relationships returns data.frame", {
  data <- list(list(relationship_id = "Is a", concept_id_1 = 1, concept_id_2 = 2))
  result <- new_omophub_relationships(data, list())

  df <- as.data.frame(result)

  expect_s3_class(df, "data.frame")
})

# ==============================================================================
# omophub_mappings
# ==============================================================================

test_that("new_omophub_mappings creates correct S3 class", {
  data <- list(
    list(
      source_concept_id = 201826,
      target_concept_id = 12345,
      target_vocabulary_id = "ICD10CM"
    )
  )
  meta <- list(total_items = 8)

  result <- new_omophub_mappings(data, meta)

  expect_s3_class(result, "omophub_mappings")
  expect_s3_class(result$data, "tbl_df")
  expect_equal(result$total, 8)
})

test_that("new_omophub_mappings handles empty data", {
  result <- new_omophub_mappings(list(), list())

  expect_s3_class(result, "omophub_mappings")
  expect_equal(nrow(result$data), 0)
})

test_that("print.omophub_mappings outputs expected format", {
  data <- list(list(source_concept_id = 1, target_concept_id = 2, target_vocabulary_id = "X"))
  result <- new_omophub_mappings(data, list(total_items = 3))

  expect_output(print(result), "<OMOPHub Mappings>")
  expect_output(print(result), "Total: 3 mappings")
})

test_that("as.data.frame.omophub_mappings returns data.frame", {
  data <- list(list(source_concept_id = 1, target_concept_id = 2, target_vocabulary_id = "X"))
  result <- new_omophub_mappings(data, list())

  df <- as.data.frame(result)

  expect_s3_class(df, "data.frame")
})

# ==============================================================================
# Edge cases for all types
# ==============================================================================

test_that("response classes handle data with NULL values", {
  data <- list(
    list(concept_id = 201826, concept_name = NULL, vocabulary_id = "SNOMED")
  )

  # Should not error, NULL becomes NA in tibble
  result <- new_omophub_concepts(data, list())

  expect_s3_class(result, "omophub_concepts")
  expect_equal(nrow(result$data), 1)
})

test_that("response classes handle nested pagination meta", {
  data <- list(mock_concept())
  meta <- list(
    pagination = list(
      page = 2,
      page_size = 50,
      total_items = 200,
      has_next = TRUE
    )
  )

  # Using the nested pagination format
  result <- new_omophub_concepts(data, meta$pagination)

  expect_equal(result$page, 2)
  expect_equal(result$page_size, 50)
  expect_equal(result$total, 200)
  expect_true(result$has_next)
})
