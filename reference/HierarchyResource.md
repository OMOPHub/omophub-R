# Hierarchy Resource

R6 class providing access to hierarchy operations (ancestors and
descendants).

## Value

Ancestors with hierarchy summary.

Descendants with hierarchy summary.

## Methods

### Public methods

- [`HierarchyResource$new()`](#method-HierarchyResource-new)

- [`HierarchyResource$ancestors()`](#method-HierarchyResource-ancestors)

- [`HierarchyResource$descendants()`](#method-HierarchyResource-descendants)

- [`HierarchyResource$print()`](#method-HierarchyResource-print)

- [`HierarchyResource$clone()`](#method-HierarchyResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new HierarchyResource.

#### Usage

    HierarchyResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method `ancestors()`

Get concept ancestors.

#### Usage

    HierarchyResource$ancestors(
      concept_id,
      vocabulary_id = NULL,
      max_levels = NULL,
      relationship_types = NULL,
      include_paths = FALSE,
      include_distance = TRUE,
      standard_only = FALSE,
      include_deprecated = FALSE,
      page = 1,
      page_size = 100
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `vocabulary_id`:

  Filter to specific vocabulary.

- `max_levels`:

  Maximum hierarchy levels to traverse.

- `relationship_types`:

  Relationship types to follow (default: "Is a").

- `include_paths`:

  Include path information. Default `FALSE`.

- `include_distance`:

  Include distance from source. Default `TRUE`.

- `standard_only`:

  Only return standard concepts. Default `FALSE`.

- `include_deprecated`:

  Include deprecated concepts. Default `FALSE`.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 100.

------------------------------------------------------------------------

### Method `descendants()`

Get concept descendants.

#### Usage

    HierarchyResource$descendants(
      concept_id,
      vocabulary_id = NULL,
      max_levels = 10,
      relationship_types = NULL,
      include_distance = TRUE,
      standard_only = FALSE,
      include_deprecated = FALSE,
      domain_ids = NULL,
      concept_class_ids = NULL,
      include_synonyms = FALSE,
      page = 1,
      page_size = 100
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `vocabulary_id`:

  Filter to specific vocabulary.

- `max_levels`:

  Maximum hierarchy levels (default 10, max 10).

- `relationship_types`:

  Relationship types to follow.

- `include_distance`:

  Include distance from source. Default `TRUE`.

- `standard_only`:

  Only return standard concepts. Default `FALSE`.

- `include_deprecated`:

  Include deprecated concepts. Default `FALSE`.

- `domain_ids`:

  Filter by domains.

- `concept_class_ids`:

  Filter by concept classes.

- `include_synonyms`:

  Include synonyms. Default `FALSE`.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 100.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print resource information.

#### Usage

    HierarchyResource$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    HierarchyResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
