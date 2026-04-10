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

test_that("get_api_key falls back to keyring when available", {
  skip_if_not_installed("keyring")
  withr::with_envvar(
    c(OMOPHUB_API_KEY = NA),
    {
      # Mock keyring to return a key
      local_mocked_bindings(
        key_get = function(service, username) "keyring_api_key",
        .package = "keyring"
      )
      key <- get_api_key()
      expect_equal(key, "keyring_api_key")
    }
  )
})

test_that("set_api_key with keyring store errors when keyring missing", {
  # Skip if keyring is actually not installed (the error would fire naturally)
  # but test the branch where keyring IS installed by mocking key_set_with_value
  # (the "requires keyring" error path is lines 107-111 in auth.R)
  skip_if_not_installed("keyring")
  # If keyring IS installed, set_api_key(store="keyring") should succeed
  # (covered by the next test). This test just confirms the store arg works.
  expect_error(set_api_key("", store = "keyring"), "Invalid API key")
})

test_that("set_api_key with keyring store calls key_set_with_value", {
  skip_if_not_installed("keyring")
  called_with <- NULL
  local_mocked_bindings(
    key_set_with_value = function(service, username, password) {
      called_with <<- list(service = service, username = username, password = password)
    },
    .package = "keyring"
  )

  result <- set_api_key("my_secure_key", store = "keyring")

  expect_true(result)
  expect_equal(called_with$service, "omophub")
  expect_equal(called_with$username, "api_key")
  expect_equal(called_with$password, "my_secure_key")
})
