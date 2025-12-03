# Perform POST Request

Perform POST Request

## Usage

``` r
perform_post(base_req, endpoint, body = NULL, query = NULL)
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

## Value

Parsed JSON response (unwrapped from `data` field if present).
