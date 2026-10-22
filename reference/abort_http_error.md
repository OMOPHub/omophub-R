# Abort with the OMOPHub Condition for an HTTP Error Response

Maps a failed response to the documented condition hierarchy:

## Usage

``` r
abort_http_error(resp, endpoint, call = rlang::caller_env())
```

## Arguments

- resp:

  The failed httr2 response.

- endpoint:

  API endpoint that failed.

- call:

  The calling environment.

## Details

- 400 → `omophub_validation_error`

- 401, or `error.code` `invalid_api_key` / `missing_api_key` →
  `omophub_auth_error`

- 403 → `omophub_forbidden_error` (valid key, but not permitted)

- 404 → `omophub_not_found`

- 429 → `omophub_rate_limit_error` (with `retry_after`)

- 5xx → `omophub_server_error`

- anything else → `omophub_api_error`

Every class inherits from `omophub_api_error` and `omophub_error`. The
condition also keeps httr2's own classes (`httr2_http_<status>`,
`httr2_http`, `httr2_error`) and `resp`, so handlers written against the
httr2 conditions keep working.
