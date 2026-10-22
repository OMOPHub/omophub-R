# Abort with OMOPHub API Error

Abort with OMOPHub API Error

## Usage

``` r
abort_api_error(
  status,
  message,
  endpoint,
  error_code = NULL,
  details = NULL,
  request_id = NULL,
  class = NULL,
  hint = NULL,
  ...,
  call = rlang::caller_env()
)
```

## Arguments

- status:

  HTTP status code.

- message:

  Error message.

- endpoint:

  API endpoint that failed.

- error_code:

  The server's `error.code`, if any.

- details:

  The server's `error.details`, if any.

- request_id:

  The request ID, if any.

- class:

  Additional condition classes, most specific first. They are placed
  ahead of `omophub_api_error`.

- hint:

  Optional extra `i` bullet for the message.

- ...:

  Additional fields stored on the condition.

- call:

  The calling environment.
