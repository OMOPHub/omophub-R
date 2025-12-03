test_that("get_api_key returns explicit key", {
  key <- get_api_key("my_explicit_key")
  expect_equal(key, "my_explicit_key")
})

test_that("get_api_key returns environment variable", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "env_api_key"),
    {
      key <- get_api_key()
      expect_equal(key, "env_api_key")
    }
  )
})

test_that("get_api_key errors when no key available", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = NA),
    {
      expect_error(get_api_key(), "No API key found")
    }
  )
})

test_that("get_api_key validates key format", {
  expect_error(get_api_key(""), "Invalid API key")
  expect_error(get_api_key(123), "Invalid API key")
  expect_error(get_api_key(c("a", "b")), "Invalid API key")
})

test_that("set_api_key sets environment variable", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = NA),
    {
      result <- set_api_key("new_key", store = "env")
      expect_true(result)
      expect_equal(Sys.getenv("OMOPHUB_API_KEY"), "new_key")
    }
  )
})

test_that("set_api_key validates input", {
  expect_error(set_api_key(""), "Invalid API key")
  expect_error(set_api_key(NULL), "Invalid API key")
})

test_that("has_api_key returns TRUE when key exists", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      expect_true(has_api_key())
    }
  )
})

test_that("has_api_key returns FALSE when no key", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = NA),
    {
      expect_false(has_api_key())
    }
  )
})
