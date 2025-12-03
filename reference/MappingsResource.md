# Mappings Resource

R6 class providing access to mapping operations.

## Value

Mappings with summary.

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
      target_vocabularies = NULL,
      mapping_types = NULL,
      direction = "both",
      include_indirect = FALSE,
      standard_only = FALSE,
      include_mapping_quality = FALSE,
      include_synonyms = FALSE,
      include_context = FALSE,
      active_only = TRUE,
      sort_by = NULL,
      sort_order = NULL,
      page = 1,
      page_size = 50
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `target_vocabularies`:

  Filter by target vocabularies.

- `mapping_types`:

  Filter by mapping types.

- `direction`:

  Mapping direction ("outgoing", "incoming", "both"). Default "both".

- `include_indirect`:

  Include indirect mappings. Default `FALSE`.

- `standard_only`:

  Only standard concept mappings. Default `FALSE`.

- `include_mapping_quality`:

  Include quality metrics. Default `FALSE`.

- `include_synonyms`:

  Include synonyms. Default `FALSE`.

- `include_context`:

  Include mapping context. Default `FALSE`.

- `active_only`:

  Only active mappings. Default `TRUE`.

- `sort_by`:

  Sort field.

- `sort_order`:

  Sort order.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 50.

------------------------------------------------------------------------

### Method `map()`

Map concepts to a target vocabulary.

#### Usage

    MappingsResource$map(
      source_concepts,
      target_vocabulary,
      mapping_type = NULL,
      include_invalid = FALSE
    )

#### Arguments

- `source_concepts`:

  Vector of OMOP concept IDs to map.

- `target_vocabulary`:

  Target vocabulary ID (e.g., "ICD10CM", "SNOMED").

- `mapping_type`:

  Mapping type (direct, equivalent, broader, narrower).

- `include_invalid`:

  Include invalid mappings. Default `FALSE`.

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
