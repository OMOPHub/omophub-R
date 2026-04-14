# Batch-resolve FHIR Codings

Standalone wrapper for `client$fhir$resolve_batch()`. When
`as_tibble = TRUE`, the result is a flat `tibble` suitable for
`dplyr`/`tidyr` pipelines.

## Usage

``` r
fhir_resolve_batch(client, ...)
```

## Arguments

- client:

  An
  [OMOPHubClient](https://omophub.github.io/omophub-R/reference/OMOPHubClient.md)
  instance.

- ...:

  Arguments passed to `FhirResource$resolve_batch()`.

## Value

See `FhirResource$resolve_batch()`.

## See also

[FhirResource](https://omophub.github.io/omophub-R/reference/FhirResource.md),
[`fhir_resolve()`](https://omophub.github.io/omophub-R/reference/fhir_resolve.md),
[`fhir_resolve_codeable_concept()`](https://omophub.github.io/omophub-R/reference/fhir_resolve_codeable_concept.md)

## Examples

``` r
if (FALSE) { # \dontrun{
client <- OMOPHubClient$new(api_key = Sys.getenv("OMOPHUB_API_KEY"))
tbl <- fhir_resolve_batch(
  client,
  codings = list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://loinc.org", code = "2339-0")
  ),
  as_tibble = TRUE
)
dplyr::filter(tbl, status == "resolved")
} # }
```
