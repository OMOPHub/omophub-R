# Resolve a FHIR Coding to an OMOP standard concept

Standalone wrapper for `client$fhir$resolve()`. See
[FhirResource](https://omophub.github.io/omophub-R/reference/FhirResource.md)
for full parameter documentation.

## Usage

``` r
fhir_resolve(client, ...)
```

## Arguments

- client:

  An
  [OMOPHubClient](https://omophub.github.io/omophub-R/reference/OMOPHubClient.md)
  instance.

- ...:

  Arguments passed to `FhirResource$resolve()`.

## Value

A list with `input` and `resolution`.

## See also

[FhirResource](https://omophub.github.io/omophub-R/reference/FhirResource.md),
[`fhir_resolve_batch()`](https://omophub.github.io/omophub-R/reference/fhir_resolve_batch.md),
[`fhir_resolve_codeable_concept()`](https://omophub.github.io/omophub-R/reference/fhir_resolve_codeable_concept.md)

## Examples

``` r
if (FALSE) { # \dontrun{
client <- OMOPHubClient$new(api_key = Sys.getenv("OMOPHUB_API_KEY"))
fhir_resolve(
  client,
  system = "http://snomed.info/sct",
  code = "44054006",
  resource_type = "Condition"
)
} # }
```
