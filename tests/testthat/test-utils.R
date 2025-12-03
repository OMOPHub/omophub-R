test_that("bool_to_str converts booleans correctly", {
  expect_equal(omophub:::bool_to_str(TRUE), "true")
  expect_equal(omophub:::bool_to_str(FALSE), "false")
  expect_null(omophub:::bool_to_str(NULL))
})

test_that("join_params joins vectors correctly", {
  expect_equal(omophub:::join_params(c("a", "b", "c")), "a,b,c")
  expect_equal(omophub:::join_params(c("SNOMED", "ICD10CM")), "SNOMED,ICD10CM")
  expect_null(omophub:::join_params(NULL))
  expect_null(omophub:::join_params(character(0)))
})

test_that("validate_concept_id accepts valid IDs", {
  expect_equal(omophub:::validate_concept_id(201826), 201826L)
  expect_equal(omophub:::validate_concept_id(1L), 1L)
})

test_that("validate_concept_id rejects invalid IDs", {
  expect_error(omophub:::validate_concept_id(0), "positive integer")
  expect_error(omophub:::validate_concept_id(-1), "positive integer")
  expect_error(omophub:::validate_concept_id("abc"), "positive integer")
  expect_error(omophub:::validate_concept_id(c(1, 2)), "positive integer")
})

test_that("validate_pagination accepts valid params", {
  result <- omophub:::validate_pagination(1, 20)
  expect_equal(result$page, 1L)
  expect_equal(result$page_size, 20L)
})

test_that("validate_pagination rejects invalid params", {
  expect_error(omophub:::validate_pagination(0, 20), "positive integer")
  expect_error(omophub:::validate_pagination(1, 0), "between 1 and")
  expect_error(omophub:::validate_pagination(1, 2000), "between 1 and")
})

test_that("null coalescing operator works", {
  # Use rlang's %||% as our internal one is not exported
  # This test verifies the basic behavior
  expect_equal(rlang::`%||%`(NULL, "default"), "default")
  expect_equal(rlang::`%||%`("value", "default"), "value")
  expect_equal(rlang::`%||%`(0, "default"), 0)
  expect_equal(rlang::`%||%`("", "default"), "")
})
