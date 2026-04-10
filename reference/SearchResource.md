# Search Resource

R6 class providing access to search operations.

## Value

Search results with pagination.

A tibble of all matching concepts.

Search results with facets and metadata.

Autocomplete suggestions.

List with results and pagination metadata.

A tibble of all matching concepts with similarity scores.

List with `results` (per-search), `total_searches`,
`completed_searches`, `failed_searches`.

List with `results` (per-search), `total_searches`, `completed_count`,
`failed_count`, `total_duration`.

List with similar_concepts and search_metadata.

## Note

When algorithm='semantic', only single vocabulary/domain filter
supported.

## Methods

### Public methods

- [`SearchResource$new()`](#method-SearchResource-new)

- [`SearchResource$basic()`](#method-SearchResource-basic)

- [`SearchResource$basic_all()`](#method-SearchResource-basic_all)

- [`SearchResource$advanced()`](#method-SearchResource-advanced)

- [`SearchResource$autocomplete()`](#method-SearchResource-autocomplete)

- [`SearchResource$semantic()`](#method-SearchResource-semantic)

- [`SearchResource$semantic_all()`](#method-SearchResource-semantic_all)

- [`SearchResource$bulk_basic()`](#method-SearchResource-bulk_basic)

- [`SearchResource$bulk_semantic()`](#method-SearchResource-bulk_semantic)

- [`SearchResource$similar()`](#method-SearchResource-similar)

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
      vocabulary_ids = NULL,
      domain_ids = NULL,
      concept_class_ids = NULL,
      standard_concepts_only = FALSE,
      include_invalid = FALSE,
      relationship_filters = NULL,
      page = 1,
      page_size = 20
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

- `standard_concepts_only`:

  Only return standard concepts. Default `FALSE`.

- `include_invalid`:

  Include invalid concepts. Default `FALSE`.

- `relationship_filters`:

  Relationship-based filters.

- `page`:

  Page number (1-based). Default 1.

- `page_size`:

  Results per page. Default 20.

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

### Method `semantic()`

Semantic concept search using neural embeddings.

#### Usage

    SearchResource$semantic(
      query,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      standard_concept = NULL,
      concept_class_id = NULL,
      threshold = NULL,
      page = 1,
      page_size = 20
    )

#### Arguments

- `query`:

  Natural language search query (required).

- `vocabulary_ids`:

  Filter by vocabulary IDs.

- `domain_ids`:

  Filter by domain IDs.

- `standard_concept`:

  Filter by standard concept ('S' or 'C').

- `concept_class_id`:

  Filter by concept class ID.

- `threshold`:

  Minimum similarity threshold (0.0-1.0, default 0.5).

- `page`:

  Page number (1-based). Default 1.

- `page_size`:

  Results per page (max 100). Default 20.

------------------------------------------------------------------------

### Method `semantic_all()`

Fetch all semantic search results with automatic pagination.

#### Usage

    SearchResource$semantic_all(
      query,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      standard_concept = NULL,
      concept_class_id = NULL,
      threshold = NULL,
      page_size = 100,
      max_pages = Inf,
      progress = TRUE
    )

#### Arguments

- `query`:

  Natural language search query (required).

- `vocabulary_ids`:

  Filter by vocabulary IDs.

- `domain_ids`:

  Filter by domain IDs.

- `standard_concept`:

  Filter by standard concept ('S' or 'C').

- `concept_class_id`:

  Filter by concept class ID.

- `threshold`:

  Minimum similarity threshold (0.0-1.0).

- `page_size`:

  Results per page. Default 100.

- `max_pages`:

  Maximum pages to fetch. Default Inf.

- `progress`:

  Show progress bar. Default `TRUE`.

------------------------------------------------------------------------

### Method `bulk_basic()`

Execute multiple lexical searches in a single request (max 50).

#### Usage

    SearchResource$bulk_basic(searches, defaults = NULL)

#### Arguments

- `searches`:

  List of search inputs. Each element is a named list with:

  - `search_id` (required): Unique ID to match results.

  - `query` (required): Search query string.

  - `vocabulary_ids`, `domain_ids`, `concept_class_ids`: Optional
    filters.

  - `standard_concept`, `include_invalid`, `page_size`: Optional params.

- `defaults`:

  Named list of default filters applied to all searches. Individual
  search-level values override defaults.

------------------------------------------------------------------------

### Method `bulk_semantic()`

Execute multiple semantic searches in a single request (max 25).

#### Usage

    SearchResource$bulk_semantic(searches, defaults = NULL)

#### Arguments

- `searches`:

  List of search inputs. Each element is a named list with:

  - `search_id` (required): Unique ID to match results.

  - `query` (required): Natural language query (1-500 chars).

  - `threshold`: Per-search similarity threshold (0-1).

  - `page_size`: Per-search result limit (1-50).

  - `vocabulary_ids`, `domain_ids`, `standard_concept`: Optional
    filters.

- `defaults`:

  Named list of default filters applied to all searches.

------------------------------------------------------------------------

### Method `similar()`

Find concepts similar to a reference concept or query.

Must provide exactly one of: concept_id, concept_name, or query.

#### Usage

    SearchResource$similar(
      concept_id = NULL,
      concept_name = NULL,
      query = NULL,
      algorithm = "hybrid",
      similarity_threshold = 0.7,
      page_size = 20,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      standard_concept = NULL,
      include_invalid = NULL,
      include_scores = NULL,
      include_explanations = NULL
    )

#### Arguments

- `concept_id`:

  Concept ID to find similar concepts for.

- `concept_name`:

  Concept name to find similar concepts for.

- `query`:

  Natural language query for semantic similarity.

- `algorithm`:

  One of 'semantic', 'lexical', or 'hybrid' (default).

- `similarity_threshold`:

  Minimum similarity (0.0-1.0). Default 0.7.

- `page_size`:

  Max results (max 1000). Default 20.

- `vocabulary_ids`:

  Filter by vocabulary IDs.

- `domain_ids`:

  Filter by domain IDs.

- `standard_concept`:

  Filter by standard concept flag ('S', 'C', or 'N').

- `include_invalid`:

  Include invalid/deprecated concepts.

- `include_scores`:

  Include detailed similarity scores.

- `include_explanations`:

  Include similarity explanations.

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
