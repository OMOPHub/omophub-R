# Perform a Request, Raising OMOPHub Conditions on Failure

[`req_error()`](https://httr2.r-lib.org/reference/req_error.html) makes
httr2 raise `httr2_http_*` for 4xx/5xx and `httr2_failure` for transport
errors (after
[`req_retry()`](https://httr2.r-lib.org/reference/req_retry.html) has
given up). Those are translated here into the documented `omophub_*`
condition hierarchy; see
[`abort_http_error()`](https://omophub.github.io/omophub-R/reference/abort_http_error.md).

## Usage

``` r
perform_request(req, endpoint, call = rlang::caller_env())
```

## Arguments

- req:

  The request to perform.

- endpoint:

  API endpoint path, for the error message.

- call:

  The calling environment reported on the condition.

## Value

The httr2 response.
