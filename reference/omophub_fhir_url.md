# OMOPHub FHIR Terminology Service URL

Convenience helper for constructing the OMOPHub FHIR Terminology Service
base URL for a given FHIR version. Use it when configuring an external
FHIR client library (`httr2`, `fhircrackr`, etc.) to talk to OMOPHub's
FHIR endpoint directly.

## Usage

``` r
omophub_fhir_url(version = c("r4", "r4b", "r5", "r6"))
```

## Arguments

- version:

  FHIR version prefix. One of `"r4"` (default), `"r4b"`, `"r5"`, or
  `"r6"`.

## Value

A character scalar with the full FHIR base URL, e.g.
`"https://fhir.omophub.com/fhir/r4"`.

## Examples

``` r
omophub_fhir_url()
#> [1] "https://fhir.omophub.com/fhir/r4"
omophub_fhir_url("r5")
#> [1] "https://fhir.omophub.com/fhir/r5"

if (FALSE) { # \dontrun{
# Use with httr2 to call the $lookup operation directly
library(httr2)
req <- request(omophub_fhir_url()) |>
  req_url_path_append("CodeSystem/$lookup") |>
  req_url_query(
    system = "http://snomed.info/sct",
    code = "44054006"
  ) |>
  req_headers(Authorization = paste("Bearer", Sys.getenv("OMOPHUB_API_KEY")))
resp <- req_perform(req)
} # }
```
