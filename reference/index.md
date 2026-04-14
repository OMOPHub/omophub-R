# Package index

## Client

Create and configure API clients

- [`OMOPHubClient`](https://omophub.github.io/omophub-R/reference/OMOPHubClient.md)
  : OMOPHub API Client
- [`get_api_key()`](https://omophub.github.io/omophub-R/reference/get_api_key.md)
  : Get OMOPHub API Key
- [`set_api_key()`](https://omophub.github.io/omophub-R/reference/set_api_key.md)
  : Set OMOPHub API Key
- [`has_api_key()`](https://omophub.github.io/omophub-R/reference/has_api_key.md)
  : Check if API Key is Available

## FHIR Resolution

Translate FHIR coded values to OMOP standard concepts and CDM target
tables via the FHIR Concept Resolver, plus helpers for interop with
external FHIR client libraries.

- [`fhir_resolve()`](https://omophub.github.io/omophub-R/reference/fhir_resolve.md)
  : Resolve a FHIR Coding to an OMOP standard concept
- [`fhir_resolve_batch()`](https://omophub.github.io/omophub-R/reference/fhir_resolve_batch.md)
  : Batch-resolve FHIR Codings
- [`fhir_resolve_codeable_concept()`](https://omophub.github.io/omophub-R/reference/fhir_resolve_codeable_concept.md)
  : Resolve a FHIR CodeableConcept with vocabulary preference
- [`omophub_fhir_url()`](https://omophub.github.io/omophub-R/reference/omophub_fhir_url.md)
  : OMOPHub FHIR Terminology Service URL

## Response Classes

S3 classes for API responses
