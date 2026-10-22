# Parse the OMOPHub Error Envelope

The API answers failures with
`{"success": false, "error": {"code", "message", "details"}, "meta": {"request_id"}}`.
Anything else (an HTML page from a proxy, an empty body) degrades to a
status-only message rather than failing inside the error path.

## Usage

``` r
parse_error_body(resp)
```

## Arguments

- resp:

  An httr2 response object.

## Value

A list with `message`, `error_code`, `details`, and `request_id` (each
possibly `NULL` except `message`).
