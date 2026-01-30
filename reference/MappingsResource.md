# Mappings Resource

R6 class providing access to mapping operations.

## Value

Mappings for the concept.

Mapping results with summary.

## Methods

### Public methods

- [`MappingsResource$new()`](#method-MappingsResource-new)

- [`MappingsResource$get()`](#method-MappingsResource-get)

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

Get mappings for a concept.

#### Usage

    MappingsResource$get(
      concept_id,
      target_vocabulary = NULL,
      include_invalid = FALSE,
      vocab_release = NULL
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `target_vocabulary`:

  Filter to a specific target vocabulary (e.g., "ICD10CM").

- `include_invalid`:

  Include invalid/deprecated mappings. Default `FALSE`.

- `vocab_release`:

  Specific vocabulary release version (e.g., "2025.1"). Default `NULL`.

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
