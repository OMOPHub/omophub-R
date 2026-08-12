# Mappings Resource

R6 class providing access to mapping operations.

## Value

Mappings for the concept, with pagination metadata attached as the
`pagination` attribute.

A tibble of all mappings for the concept.

Mapping results with summary.

## Methods

### Public methods

- [`MappingsResource$new()`](#method-MappingsResource-new)

- [`MappingsResource$get()`](#method-MappingsResource-get)

- [`MappingsResource$get_all()`](#method-MappingsResource-get_all)

- [`MappingsResource$map()`](#method-MappingsResource-map)

- [`MappingsResource$print()`](#method-MappingsResource-print)

- [`MappingsResource$clone()`](#method-MappingsResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new MappingsResource.

#### Usage

    MappingsResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Get one page of mappings for a concept.

The endpoint is paginated and a concept can easily have more mappings
than one page holds, so a full page means "there is probably more", not
"this is everything". Read the `pagination` attribute on the result, or
use `get_all()` to walk every page.

#### Usage

    MappingsResource$get(
      concept_id,
      target_vocabulary = NULL,
      include_invalid = NULL,
      vocab_release = NULL,
      relationship_ids = NULL,
      page = 1,
      page_size = 100
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `target_vocabulary`:

  Filter to a specific target vocabulary (e.g., "ICD10CM").

- `include_invalid`:

  Whether to return mappings whose relationship or target concept is
  deprecated. Default `NULL` takes the server default, which for this
  endpoint is to *include* them; pass `FALSE` to exclude them. The
  source concept is never filtered, so a deprecated concept still
  returns what it maps to.

- `vocab_release`:

  Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.

- `relationship_ids`:

  Character vector of relationship types to return. Defaults server-side
  to `"Maps to"`. Pass `c("Maps to", "Maps to value")` to also get the
  Value-as-Concept decomposition of composite concepts - "Allergy to
  penicillin G" maps to "Allergy to drug" via `Maps to` and to
  "penicillin G" via `Maps to value`, and the default returns only the
  first of those.

- `page`:

  Page number. Default 1.

- `page_size`:

  Mappings per page. Default 100, maximum 200.

------------------------------------------------------------------------

### Method `get_all()`

Get every mapping for a concept, walking all pages.

Prefer this over [`get()`](https://rdrr.io/r/base/get.html) when
assembling a code list — [`get()`](https://rdrr.io/r/base/get.html)
returns a single page, and a partial code list is wrong in a way nothing
in the result reveals.

#### Usage

    MappingsResource$get_all(
      concept_id,
      target_vocabulary = NULL,
      include_invalid = NULL,
      vocab_release = NULL,
      relationship_ids = NULL,
      page_size = 100,
      max_pages = Inf,
      progress = TRUE
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `target_vocabulary`:

  Filter to a specific target vocabulary (e.g., "ICD10CM").

- `include_invalid`:

  Whether to return deprecated mappings. Same semantics as `$get()`,
  including the include-by-default behaviour.

- `vocab_release`:

  Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.

- `relationship_ids`:

  Relationship types to return. Same semantics as `$get()` – see there
  for the Value-as-Concept case.

- `page_size`:

  Mappings fetched per request. Default 100, maximum 200.

- `max_pages`:

  Maximum pages to fetch. Default `Inf`.

- `progress`:

  Show progress bar. Default `TRUE`.

------------------------------------------------------------------------

### Method [`map()`](https://purrr.tidyverse.org/reference/map.html)

Map concepts to a target vocabulary.

#### Usage

    MappingsResource$map(
      target_vocabulary,
      source_concepts = NULL,
      source_codes = NULL,
      mapping_type = NULL,
      include_invalid = FALSE,
      vocab_release = NULL
    )

#### Arguments

- `target_vocabulary`:

  Target vocabulary ID (e.g., "ICD10CM", "SNOMED", "RxNorm").

- `source_concepts`:

  Vector of OMOP concept IDs to map. Use this OR source_codes, not both.

- `source_codes`:

  List of vocabulary/code pairs to map. Each element should be a list
  with `vocabulary_id` and `concept_code`. Use this OR source_concepts,
  not both.

- `mapping_type`:

  Mapping type filter (direct, equivalent, broader, narrower).

- `include_invalid`:

  Include invalid mappings. Default `FALSE`.

- `vocab_release`:

  Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print resource information.

#### Usage

    MappingsResource$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MappingsResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
