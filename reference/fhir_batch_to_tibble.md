# Flatten a batch resolver response into a tibble.

Internal helper used by `FhirResource$resolve_batch(as_tibble = TRUE)`.
Produces one row per input coding with flat columns for the source
concept, standard concept, target CDM table, and status. The original
`summary` list is attached to the returned tibble via
`attr(x, "summary")`.

## Usage

``` r
fhir_batch_to_tibble(result, codings)
```

## Arguments

- result:

  The raw list result from `perform_post`.

- codings:

  The original input `codings` list, used to align rows when items fail
  resolution and no `source_concept` is returned.

## Value

A [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html).
