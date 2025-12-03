# Relationships Resource

R6 class providing access to relationship operations.

## Value

Relationships with summary.

Relationship types with metadata.

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
      relationship_type = NULL,
      target_vocabulary = NULL,
      include_invalid = FALSE,
      page = 1,
      page_size = 50
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `relationship_type`:

  Filter by relationship type.

- `target_vocabulary`:

  Filter by target vocabulary.

- `include_invalid`:

  Include invalid relationships. Default `FALSE`.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 50.

------------------------------------------------------------------------

### Method `types()`

Get available relationship types.

#### Usage

    RelationshipsResource$types(
      vocabulary_ids = NULL,
      include_reverse = FALSE,
      include_usage_stats = FALSE,
      include_examples = FALSE,
      category = NULL,
      is_defining = NULL,
      standard_only = FALSE,
      page = 1,
      page_size = 100
    )

#### Arguments

- `vocabulary_ids`:

  Filter by vocabularies.

- `include_reverse`:

  Include reverse relationships. Default `FALSE`.

- `include_usage_stats`:

  Include usage statistics. Default `FALSE`.

- `include_examples`:

  Include example concepts. Default `FALSE`.

- `category`:

  Filter by category.

- `is_defining`:

  Filter by defining status.

- `standard_only`:

  Only standard relationships. Default `FALSE`.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 100.

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
