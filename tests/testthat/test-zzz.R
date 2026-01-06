# Unit tests for zzz.R
# Tests package load and attach hooks

# ==============================================================================
# .onLoad() tests
# ==============================================================================

test_that(".onLoad sets default options when not present", {
  # Clear any existing options
  withr::with_options(
    list(
      omophub.base_url = NULL,
      omophub.timeout = NULL,
      omophub.max_retries = NULL
    ),
    {
      # Call .onLoad
      omophub:::.onLoad("", "omophub")

      # Check options were set
      expect_equal(getOption("omophub.base_url"), "https://api.omophub.com/v1")
      expect_equal(getOption("omophub.timeout"), 30)
      expect_equal(getOption("omophub.max_retries"), 3)
    }
  )
})

test_that(".onLoad preserves existing options", {
  withr::with_options(
    list(
      omophub.base_url = "https://custom.api.com/v1",
      omophub.timeout = 60,
      omophub.max_retries = 5
    ),
    {
      # Call .onLoad
      omophub:::.onLoad("", "omophub")

      # Check custom options were preserved
      expect_equal(getOption("omophub.base_url"), "https://custom.api.com/v1")
      expect_equal(getOption("omophub.timeout"), 60)
      expect_equal(getOption("omophub.max_retries"), 5)
    }
  )
})

test_that(".onLoad preserves partial existing options", {
  withr::with_options(
    list(
      omophub.base_url = "https://custom.api.com/v1",
      omophub.timeout = NULL,  # Should get default
      omophub.max_retries = 10
    ),
    {
      # Call .onLoad
      omophub:::.onLoad("", "omophub")

      # Check custom options preserved, missing got defaults
      expect_equal(getOption("omophub.base_url"), "https://custom.api.com/v1")
      expect_equal(getOption("omophub.timeout"), 30)  # Default
      expect_equal(getOption("omophub.max_retries"), 10)
    }
  )
})

# ==============================================================================
# .onAttach() tests
# ==============================================================================

test_that(".onAttach shows message when API key is missing", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = NA),  # Remove API key
    {
      # Clear any cached API key in keyring
      local_mocked_bindings(
        has_api_key = function() FALSE
      )

      expect_message(
        omophub:::.onAttach("", "omophub"),
        "No OMOPHUB_API_KEY found"
      )
    }
  )
})

test_that(".onAttach does not show message when API key is present", {
  withr::with_envvar(
    c(OMOPHUB_API_KEY = "test_key"),
    {
      # Mock has_api_key to return TRUE
      local_mocked_bindings(
        has_api_key = function() TRUE
      )

      # Should not produce any message
      expect_silent(
        suppressMessages(omophub:::.onAttach("", "omophub"))
      )
    }
  )
})
