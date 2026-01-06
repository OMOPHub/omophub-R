# Relationships Resource

R6 class providing access to relationship operations.

## Value

Relationships data with pagination metadata.

Relationship types with pagination metadata.

## Methods

### Public methods

- [`RelationshipsResource$new()`](#method-RelationshipsResource-new)

- [`RelationshipsResource$get()`](#method-RelationshipsResource-get)

- [`RelationshipsResource$types()`](#method-RelationshipsResource-types)

- [`RelationshipsResource$print()`](#method-RelationshipsResource-print)

- [`RelationshipsResource$clone()`](#method-RelationshipsResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new RelationshipsResource.

#### Usage

    RelationshipsResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Get relationships for a concept.

#### Usage

    RelationshipsResource$get(
      concept_id,
      relationship_ids = NULL,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      include_invalid = FALSE,
      standard_only = FALSE,
      include_reverse = FALSE,
      page = 1,
      page_size = 100,
      vocab_release = NULL
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `relationship_ids`:

  Filter by relationship type IDs (character vector or comma-separated
  string).

- `vocabulary_ids`:

  Filter by target vocabulary IDs (character vector or comma-separated
  string).

- `domain_ids`:

  Filter by target domain IDs (character vector or comma-separated
  string).

- `include_invalid`:

  Include relationships to invalid concepts. Default `FALSE`.

- `standard_only`:

  Only include relationships to standard concepts. Default `FALSE`.

- `include_reverse`:

  Include reverse relationships. Default `FALSE`.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page (max 1000). Default 100.

- `vocab_release`:

  Specific vocabulary release version. Default `NULL`.

------------------------------------------------------------------------

### Method `types()`

Get available relationship types from the OMOP CDM.

#### Usage

    RelationshipsResource$types(page = 1, page_size = 100)

#### Arguments

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page (max 500). Default 100.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print resource information.

#### Usage

    RelationshipsResource$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    RelationshipsResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
