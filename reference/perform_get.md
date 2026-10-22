# Perform GET Request

Perform GET Request

## Usage

``` r
perform_get(base_req, endpoint, query = NULL, endpoint_encoded = FALSE)
```

## Arguments

- base_req:

  Base request object.

- endpoint:

  API endpoint path.

- query:

  Named list of query parameters.

- endpoint_encoded:

  Whether `endpoint` is already percent-encoded.

## Value

Parsed JSON response. For paginated endpoints, returns a list with
`data` (the results) and `meta` (pagination info). For single-item
endpoints, returns the unwrapped data directly.
