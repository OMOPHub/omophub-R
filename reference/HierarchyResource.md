# Hierarchy Resource

R6 class providing access to hierarchy operations (ancestors and
descendants).

## Value

For flat format: ancestors, descendants arrays with level/total counts.
For graph format: nodes and edges arrays for visualization.

Ancestors with hierarchy summary.

Descendants with hierarchy summary.

## Methods

### Public methods

- [`HierarchyResource$new()`](#method-HierarchyResource-new)

- [`HierarchyResource$get()`](#method-HierarchyResource-get)

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

### Method [`get()`](https://rdrr.io/r/base/get.html)

Get complete concept hierarchy (ancestors and descendants).

#### Usage

    HierarchyResource$get(
      concept_id,
      format = "flat",
      vocabulary_ids = NULL,
      domain_ids = NULL,
      max_levels = 10,
      max_results = NULL,
      relationship_types = NULL,
      include_invalid = FALSE
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `format`:

  Response format - "flat" (default) or "graph" for visualization.

- `vocabulary_ids`:

  Filter to specific vocabularies (character vector).

- `domain_ids`:

  Filter to specific domains (character vector).

- `max_levels`:

  Maximum hierarchy levels to traverse in both directions (default 10).

- `max_results`:

  Maximum results per direction for performance optimization.

- `relationship_types`:

  Relationship types to follow (default: "Is a").

- `include_invalid`:

  Include deprecated/invalid concepts. Default `FALSE`.

------------------------------------------------------------------------

### Method `ancestors()`

Get concept ancestors.

#### Usage

    HierarchyResource$ancestors(
      concept_id,
      vocabulary_ids = NULL,
      max_levels = NULL,
      relationship_types = NULL,
      include_paths = FALSE,
      include_distance = TRUE,
      include_invalid = FALSE,
      page = 1,
      page_size = 100
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `vocabulary_ids`:

  Filter to specific vocabularies (character vector).

- `max_levels`:

  Maximum hierarchy levels to traverse.

- `relationship_types`:

  Relationship types to follow (default: "Is a").

- `include_paths`:

  Include path information. Default `FALSE`.

- `include_distance`:

  Include distance from source. Default `TRUE`.

- `include_invalid`:

  Include deprecated/invalid concepts. Default `FALSE`.

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
      vocabulary_ids = NULL,
      max_levels = 10,
      relationship_types = NULL,
      include_distance = TRUE,
      include_paths = FALSE,
      include_invalid = FALSE,
      domain_ids = NULL,
      page = 1,
      page_size = 100
    )

#### Arguments

- `concept_id`:

  The concept ID.

- `vocabulary_ids`:

  Filter to specific vocabularies (character vector).

- `max_levels`:

  Maximum hierarchy levels (default 10, max 20).

- `relationship_types`:

  Relationship types to follow.

- `include_distance`:

  Include distance from source. Default `TRUE`.

- `include_paths`:

  Include path information. Default `FALSE`.

- `include_invalid`:

  Include deprecated/invalid concepts. Default `FALSE`.

- `domain_ids`:

  Filter by domains.

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
