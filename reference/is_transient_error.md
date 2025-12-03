# Check if Error is Transient (Retryable)

Check if Error is Transient (Retryable)

## Usage

``` r
is_transient_error(resp)
```

## Arguments

- resp:

  An httr2 response object.

## Value

`TRUE` if the error is transient and should be retried.
