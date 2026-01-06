# Concepts Resource

R6 class providing access to concept operations.

## Value

A list containing the concept data.

A list containing the concept data with optional relationships and
synonyms.

A list with `concepts` and any `failures`.

A list with suggestions and pagination metadata.

Related concepts with relationship scores.

Relationships data.

Recommendations grouped by source concept ID with pagination metadata.

## Methods

### Public methods

- [`ConceptsResource$new()`](#method-ConceptsResource-new)

- [`ConceptsResource$get()`](#method-ConceptsResource-get)

- [`ConceptsResource$get_by_code()`](#method-ConceptsResource-get_by_code)

- [`ConceptsResource$batch()`](#method-ConceptsResource-batch)

- [`ConceptsResource$suggest()`](#method-ConceptsResource-suggest)

- [`ConceptsResource$related()`](#method-ConceptsResource-related)

- [`ConceptsResource$relationships()`](#method-ConceptsResource-relationships)

- [`ConceptsResource$recommended()`](#method-ConceptsResource-recommended)

- [`ConceptsResource$print()`](#method-ConceptsResource-print)

- [`ConceptsResource$clone()`](#method-ConceptsResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new ConceptsResource.

#### Usage

    ConceptsResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Get a concept by ID.

#### Usage

    ConceptsResource$get(
      concept_id,
      include_relationships = FALSE,
      include_synonyms = FALSE,
      include_hierarchy = FALSE,
      vocab_release = NULL
    )

#### Arguments

- `concept_id`:

  The OMOP concept ID.

- `include_relationships`:

  Include related concepts (parents/children). Default `FALSE`.

- `include_synonyms`:

  Include concept synonyms. Default `FALSE`.

- `include_hierarchy`:

  Include hierarchy information. Default `FALSE`.

- `vocab_release`:

  Specific vocabulary release (e.g., "2025.2"). Default `NULL`.

------------------------------------------------------------------------

### Method `get_by_code()`

Get a concept by vocabulary and code.

#### Usage

    ConceptsResource$get_by_code(
      vocabulary_id,
      concept_code,
      include_relationships = FALSE,
      include_synonyms = FALSE,
      include_hierarchy = FALSE,
      vocab_release = NULL
    )

#### Arguments

- `vocabulary_id`:

  The vocabulary ID (e.g., "SNOMED", "ICD10CM").

- `concept_code`:

  The concept code within the vocabulary.

- `include_relationships`:

  Include related concepts (parents/children). Default `FALSE`.

- `include_synonyms`:

  Include concept synonyms. Default `FALSE`.

- `include_hierarchy`:

  Include hierarchy information. Default `FALSE`.

- `vocab_release`:

  Specific vocabulary release (e.g., "2025.2"). Default `NULL`.

------------------------------------------------------------------------

### Method `batch()`

Get multiple concepts by IDs.

#### Usage

    ConceptsResource$batch(
      concept_ids,
      include_relationships = FALSE,
      include_synonyms = FALSE,
      include_mappings = FALSE,
      vocabulary_filter = NULL,
      standard_only = TRUE
    )

#### Arguments

- `concept_ids`:

  Vector of concept IDs (max 100).

- `include_relationships`:

  Include related concepts. Default `FALSE`.

- `include_synonyms`:

  Include concept synonyms. Default `FALSE`.

- `include_mappings`:

  Include concept mappings. Default `FALSE`.

- `vocabulary_filter`:

  Filter results to specific vocabularies.

- `standard_only`:

  Only return standard concepts. Default `TRUE`.

------------------------------------------------------------------------

### Method `suggest()`

Get concept suggestions (autocomplete).

#### Usage

    ConceptsResource$suggest(
      query,
      page = 1,
      page_size = 10,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      vocab_release = NULL
    )

#### Arguments

- `query`:

  Search query (min 2 characters, max 100 characters).

- `page`:

  Page number (default 1).

- `page_size`:

  Number of suggestions per page (default 10, max 100).

- `vocabulary_ids`:

  Filter to specific vocabularies (character vector).

- `domain_ids`:

  Filter to specific domains (character vector).

- `vocab_release`:

  Specific vocabulary release (e.g., "2025.2").

------------------------------------------------------------------------

### Method `related()`

Get related concepts.

#### Usage

    ConceptsResource$related(
      concept_id,
      relationship_types = NULL,
      min_score = NULL,
      page_size = 20,
      vocab_release = NULL
    )

#### Arguments

- `concept_id`:

  The source concept ID.

- `relationship_types`:

  Filter by relationship types (e.g., c("Is a", "Maps to")).

- `min_score`:

  Minimum relationship score (0.0-1.0).

- `page_size`:

  Maximum number of results (default 20, max 100).

- `vocab_release`:

  Specific vocabulary release (e.g., "2025.1").

------------------------------------------------------------------------

### Method `relationships()`

Get concept relationships.

#### Usage

    ConceptsResource$relationships(
      concept_id,
      relationship_ids = NULL,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      include_invalid = FALSE,
      standard_only = FALSE,
      include_reverse = FALSE,
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

- `vocab_release`:

  Specific vocabulary release version. Default `NULL`.

------------------------------------------------------------------------

### Method `recommended()`

Get recommended concepts using OHDSI Phoebe algorithm.

#### Usage

    ConceptsResource$recommended(
      concept_ids,
      relationship_types = NULL,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      standard_only = TRUE,
      include_invalid = FALSE,
      page = 1,
      page_size = 100
    )

#### Arguments

- `concept_ids`:

  Vector of source concept IDs (1-100).

- `relationship_types`:

  Filter by relationship types (max 20).

- `vocabulary_ids`:

  Filter to specific vocabularies (max 50).

- `domain_ids`:

  Filter to specific domains (max 50).

- `standard_only`:

  Only return standard concepts. Default `TRUE`.

- `include_invalid`:

  Include invalid/deprecated concepts. Default `FALSE`.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page (default 100, max 1000).

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print resource information.

#### Usage

    ConceptsResource$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    ConceptsResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
