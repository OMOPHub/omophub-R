# Fetch All Paginated Results

Fetches all pages of results and combines them into a single tibble.

## Usage

``` r
paginate_all(fetch_fn, page_size = 100, max_pages = Inf, progress = TRUE)
```

## Arguments

- fetch_fn:

  A function that takes `page` and `size` arguments and returns a list
  with `data` (the results) and `meta` (pagination metadata).

- page_size:

  Number of items per page. Default 100.

- max_pages:

  Maximum number of pages to fetch. Default `Inf`.

- progress:

  Show progress bar. Default `TRUE`.

## Value

A tibble containing all fetched results.
