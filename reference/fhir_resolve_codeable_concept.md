# Resolve a FHIR CodeableConcept with vocabulary preference

Standalone wrapper for `client$fhir$resolve_codeable_concept()`.

## Usage

``` r
fhir_resolve_codeable_concept(client, ...)
```

## Arguments

- client:

  An
  [OMOPHubClient](https://omophub.github.io/omophub-R/reference/OMOPHubClient.md)
  instance.

- ...:

  Arguments passed to `FhirResource$resolve_codeable_concept()`.

## Value

See `FhirResource$resolve_codeable_concept()`.

## See also

[FhirResource](https://omophub.github.io/omophub-R/reference/FhirResource.md),
[`fhir_resolve()`](https://omophub.github.io/omophub-R/reference/fhir_resolve.md),
[`fhir_resolve_batch()`](https://omophub.github.io/omophub-R/reference/fhir_resolve_batch.md)

## Examples

``` r
if (FALSE) { # \dontrun{
client <- OMOPHubClient$new(api_key = Sys.getenv("OMOPHUB_API_KEY"))
fhir_resolve_codeable_concept(
  client,
  coding = list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
  ),
  resource_type = "Condition"
)
} # }
```
