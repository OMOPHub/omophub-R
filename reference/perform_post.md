# Perform POST Request

Perform POST Request

## Usage

``` r
perform_post(
  base_req,
  endpoint,
  body = NULL,
  query = NULL,
  preserve_pagination = FALSE
)
```

## Arguments

- base_req:

  Base request object.

- endpoint:

  API endpoint path.

- body:

  Named list for JSON body.

- query:

  Named list of query parameters.

- preserve_pagination:

  If `TRUE`, copy `meta$pagination` from the response envelope onto the
  returned list as a `pagination` element. Paginated POST endpoints
  carry their pagination in `meta` while the results sit in `data`, so
  unwrapping to `data` alone leaves the caller with a `page` argument
  and no way to know whether another page exists. Added as an element
  rather than changing the return shape, so existing accessors keep
  working.

## Value

Parsed JSON response (unwrapped from `data` field if present).
