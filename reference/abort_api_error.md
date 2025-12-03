# Abort with OMOPHub API Error

Abort with OMOPHub API Error

## Usage

``` r
abort_api_error(status, message, endpoint, call = rlang::caller_env())
```

## Arguments

- status:

  HTTP status code.

- message:

  Error message.

- endpoint:

  API endpoint that failed.

- call:

  The calling environment.
