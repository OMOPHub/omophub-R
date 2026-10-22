# Abort with Connection Error

Abort with Connection Error

## Usage

``` r
abort_connection_error(parent, endpoint, call = rlang::caller_env())
```

## Arguments

- parent:

  The underlying `httr2_failure` condition.

- endpoint:

  API endpoint that was being requested.

- call:

  The calling environment.
