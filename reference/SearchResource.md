# Search Resource

R6 class providing access to search operations.

## Value

Search results with pagination.

A tibble of all matching concepts.

Search results with facets and metadata.

Autocomplete suggestions.

## Methods

### Public methods

- [`SearchResource$new()`](#method-SearchResource-new)

- [`SearchResource$basic()`](#method-SearchResource-basic)

- [`SearchResource$basic_all()`](#method-SearchResource-basic_all)

- [`SearchResource$advanced()`](#method-SearchResource-advanced)

- [`SearchResource$autocomplete()`](#method-SearchResource-autocomplete)

- [`SearchResource$print()`](#method-SearchResource-print)

- [`SearchResource$clone()`](#method-SearchResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new SearchResource.

#### Usage

    SearchResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method `basic()`

Basic concept search.

#### Usage

    SearchResource$basic(
      query,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      concept_class_ids = NULL,
      standard_concept = NULL,
      include_synonyms = FALSE,
      include_invalid = FALSE,
      min_score = NULL,
      exact_match = FALSE,
      page = 1,
      page_size = 20,
      sort_by = NULL,
      sort_order = NULL
    )

#### Arguments

- `query`:

  Search query string.

- `vocabulary_ids`:

  Filter by vocabulary IDs.

- `domain_ids`:

  Filter by domain IDs.

- `concept_class_ids`:

  Filter by concept class IDs.

- `standard_concept`:

  Filter by standard concept ("S", "C", or NULL).

- `include_synonyms`:

  Search in synonyms. Default `FALSE`.

- `include_invalid`:

  Include invalid concepts. Default `FALSE`.

- `min_score`:

  Minimum relevance score.

- `exact_match`:

  Require exact match. Default `FALSE`.

- `page`:

  Page number (1-based). Default 1.

- `page_size`:

  Results per page. Default 20.

- `sort_by`:

  Sort field.

- `sort_order`:

  Sort order ("asc" or "desc").

------------------------------------------------------------------------

### Method `basic_all()`

Fetch all search results with automatic pagination.

#### Usage

    SearchResource$basic_all(
      query,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      page_size = 100,
      max_pages = Inf,
      progress = TRUE,
      ...
    )

#### Arguments

- `query`:

  Search query string.

- `vocabulary_ids`:

  Filter by vocabulary IDs.

- `domain_ids`:

  Filter by domain IDs.

- `page_size`:

  Results per page. Default 100.

- `max_pages`:

  Maximum pages to fetch. Default Inf.

- `progress`:

  Show progress bar. Default `TRUE`.

- `...`:

  Additional search parameters.

------------------------------------------------------------------------

### Method `advanced()`

Advanced concept search with facets.

#### Usage

    SearchResource$advanced(
      query,
      vocabularies = NULL,
      domains = NULL,
      concept_classes = NULL,
      standard_concepts_only = FALSE,
      include_invalid = FALSE,
      relationship_filters = NULL,
      limit = 20,
      offset = 0
    )

#### Arguments

- `query`:

  Search query string.

- `vocabularies`:

  Filter by vocabularies.

- `domains`:

  Filter by domains.

- `concept_classes`:

  Filter by concept classes.

- `standard_concepts_only`:

  Only return standard concepts. Default `FALSE`.

- `include_invalid`:

  Include invalid concepts. Default `FALSE`.

- `relationship_filters`:

  Relationship-based filters.

- `limit`:

  Maximum results. Default 20.

- `offset`:

  Result offset. Default 0.

------------------------------------------------------------------------

### Method `autocomplete()`

Get autocomplete suggestions.

#### Usage

    SearchResource$autocomplete(
      query,
      vocabulary_ids = NULL,
      domains = NULL,
      max_suggestions = 10
    )

#### Arguments

- `query`:

  Partial query string.

- `vocabulary_ids`:

  Filter by vocabulary IDs.

- `domains`:

  Filter by domains.

- `max_suggestions`:

  Maximum suggestions. Default 10.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print resource information.

#### Usage

    SearchResource$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    SearchResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
