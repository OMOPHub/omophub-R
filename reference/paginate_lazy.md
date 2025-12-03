# Create Lazy Pagination Iterator

Creates an iterator that fetches pages on demand.

## Usage

``` r
paginate_lazy(fetch_fn, page_size = 100)
```

## Arguments

- fetch_fn:

  A function that takes `page` and `size` arguments.

- page_size:

  Number of items per page. Default 100.

## Value

An iterator object with `next_page()` and `has_more()` methods.
