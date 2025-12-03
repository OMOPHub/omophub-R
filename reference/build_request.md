# Build Base OMOPHub Request

Creates an httr2 request object with authentication, rate limiting, and
retry logic configured.

## Usage

``` r
build_request(
  base_url,
  api_key,
  timeout = 30,
  max_retries = 3,
  vocab_version = NULL
)
```

## Arguments

- base_url:

  API base URL.

- api_key:

  API key for authentication.

- timeout:

  Request timeout in seconds.

- max_retries:

  Maximum retry attempts.

- vocab_version:

  Optional vocabulary version.

## Value

An httr2 request object.
