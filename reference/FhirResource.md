# FHIR-to-OMOP Concept Resolver

R6 class providing access to the FHIR-to-OMOP Concept Resolver
endpoints. Translates FHIR coded values (system URI + code) into OMOP
standard concepts, CDM target tables, and optional Phoebe
recommendations.

## Value

A list with `input` and `resolution` containing source/standard
concepts, target CDM table, and optional enrichments.

When `as_tibble = FALSE` (default), a list with `results` (per-item) and
`summary` (total/resolved/failed). When `as_tibble = TRUE`, a
[tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
suitable for `dplyr`/`tidyr` pipelines.

A list with `best_match`, `alternatives`, and `unresolved`.

## Details

Access via the `fhir` active binding on an `OMOPHubClient`:

    client <- OMOPHubClient$new(api_key = "oh_xxx")
    result <- client$fhir$resolve(
      system = "http://snomed.info/sct",
      code = "44054006",
      resource_type = "Condition"
    )
    result$data$resolution$target_table
    # "condition_occurrence"

## Methods

### Public methods

- [`FhirResource$new()`](#method-FhirResource-new)

- [`FhirResource$resolve()`](#method-FhirResource-resolve)

- [`FhirResource$resolve_batch()`](#method-FhirResource-resolve_batch)

- [`FhirResource$resolve_codeable_concept()`](#method-FhirResource-resolve_codeable_concept)

- [`FhirResource$clone()`](#method-FhirResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new FhirResource.

#### Usage

    FhirResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method `resolve()`

Resolve a single FHIR Coding to an OMOP standard concept.

Provide at least one of (`system` + `code`), (`vocabulary_id` + `code`),
or `display`.

#### Usage

    FhirResource$resolve(
      system = NULL,
      code = NULL,
      display = NULL,
      vocabulary_id = NULL,
      resource_type = NULL,
      include_recommendations = FALSE,
      recommendations_limit = 5L,
      include_quality = FALSE
    )

#### Arguments

- `system`:

  FHIR code system URI (e.g. `"http://snomed.info/sct"`).

- `code`:

  Code value from the FHIR Coding.

- `display`:

  Human-readable text (semantic search fallback).

- `vocabulary_id`:

  Direct OMOP vocabulary_id, bypasses URI resolution.

- `resource_type`:

  FHIR resource type (e.g. `"Condition"`, `"Observation"`).

- `include_recommendations`:

  Logical. Include Phoebe recommendations. Default `FALSE`.

- `recommendations_limit`:

  Integer. Max recommendations (1-20). Default `5L`.

- `include_quality`:

  Logical. Include mapping quality signal. Default `FALSE`.

------------------------------------------------------------------------

### Method `resolve_batch()`

Batch-resolve up to 100 FHIR Codings.

Failed items are reported inline without failing the batch.

#### Usage

    FhirResource$resolve_batch(
      codings,
      resource_type = NULL,
      include_recommendations = FALSE,
      recommendations_limit = 5L,
      include_quality = FALSE,
      as_tibble = FALSE
    )

#### Arguments

- `codings`:

  A list of coding lists, each with optional elements `system`, `code`,
  `display`, `vocabulary_id`.

- `resource_type`:

  FHIR resource type applied to all codings.

- `include_recommendations`:

  Logical. Default `FALSE`.

- `recommendations_limit`:

  Integer. Default `5L`.

- `include_quality`:

  Logical. Default `FALSE`.

- `as_tibble`:

  Logical. When `TRUE`, returns a
  [tibble::tibble](https://tibble.tidyverse.org/reference/tibble.html)
  with one row per input coding and flat columns for the source concept,
  standard concept, target CDM table, mapping type, and resolution
  status. The batch `summary` (total/resolved/failed) is attached as
  `attr(result, "summary")`. Default `FALSE` keeps the legacy
  list-shaped return.

------------------------------------------------------------------------

### Method `resolve_codeable_concept()`

Resolve a FHIR CodeableConcept with vocabulary preference.

Picks the best match per OHDSI preference order (SNOMED \> RxNorm \>
LOINC \> CVX \> ICD-10). Falls back to `text` via semantic search if no
coding resolves.

#### Usage

    FhirResource$resolve_codeable_concept(
      coding,
      text = NULL,
      resource_type = NULL,
      include_recommendations = FALSE,
      recommendations_limit = 5L,
      include_quality = FALSE
    )

#### Arguments

- `coding`:

  A list of coding lists, each with `system`, `code`, and optional
  `display`.

- `text`:

  Optional CodeableConcept.text for semantic fallback.

- `resource_type`:

  FHIR resource type.

- `include_recommendations`:

  Logical. Default `FALSE`.

- `recommendations_limit`:

  Integer. Default `5L`.

- `include_quality`:

  Logical. Default `FALSE`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    FhirResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
