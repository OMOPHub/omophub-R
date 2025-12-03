# Concepts Resource

R6 class providing access to concept operations.

## Value

A list containing the concept data.

A list containing the concept data with mappings.

A list with `concepts` and any `failures`.

A list of suggestions.

Related concepts with scores and analysis.

Relationships with summary.

## Methods

### Public methods

- [`ConceptsResource$new()`](#method-ConceptsResource-new)

- [`ConceptsResource$get()`](#method-ConceptsResource-get)

- [`ConceptsResource$get_by_code()`](#method-ConceptsResource-get_by_code)

- [`ConceptsResource$batch()`](#method-ConceptsResource-batch)

- [`ConceptsResource$suggest()`](#method-ConceptsResource-suggest)

- [`ConceptsResource$related()`](#method-ConceptsResource-related)

- [`ConceptsResource$relationships()`](#method-ConceptsResource-relationships)

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
      include_synonyms = FALSE
    )

#### Arguments

- `concept_id`:

  The OMOP concept ID.

- `include_relationships`:

  Include related concepts. Default `FALSE`.

- `include_synonyms`:

  Include concept synonyms. Default `FALSE`.

------------------------------------------------------------------------

### Method `get_by_code()`

Get a concept by vocabulary and code.

#### Usage

    ConceptsResource$get_by_code(vocabulary_id, concept_code)

#### Arguments

- `vocabulary_id`:

  The vocabulary ID (e.g., "SNOMED", "ICD10CM").

- `concept_code`:

  The concept code within the vocabulary.

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
      standard_only = FALSE
    )

#### Arguments

- `concept_ids`:

  Vector of concept IDs (max 1000).

- `include_relationships`:

  Include related concepts. Default `FALSE`.

- `include_synonyms`:

  Include concept synonyms. Default `FALSE`.

- `include_mappings`:

  Include concept mappings. Default `FALSE`.

- `vocabulary_filter`:

  Filter results to specific vocabularies.

- `standard_only`:

  Only return standard concepts. Default `FALSE`.

------------------------------------------------------------------------

### Method `suggest()`

Get concept suggestions (autocomplete).

#### Usage

    ConceptsResource$suggest(query, vocabulary = NULL, domain = NULL, limit = 10)

#### Arguments

- `query`:

  Search query (min 2 characters).

- `vocabulary`:

  Filter to specific vocabulary.

- `domain`:

  Filter to specific domain.

- `limit`:

  Maximum suggestions (default 10, max 50).

------------------------------------------------------------------------

### Method `related()`

Get related concepts.

#### Usage

    ConceptsResource$related(
      concept_id,
      relatedness_types = NULL,
      vocabulary_ids = NULL,
      domain_ids = NULL,
      min_relatedness_score = NULL,
      max_results = 50,
      include_scores = TRUE,
      standard_concepts_only = FALSE
    )

#### Arguments

- `concept_id`:

  The source concept ID.

- `relatedness_types`:

  Types of relatedness (hierarchical, semantic, etc.).

- `vocabulary_ids`:

  Filter to specific vocabularies.

- `domain_ids`:

  Filter to specific domains.

- `min_relatedness_score`:

  Minimum relatedness score.

- `max_results`:

  Maximum results (default 50, max 200).

- `include_scores`:

  Include score breakdown. Default `TRUE`.

- `standard_concepts_only`:

  Only return standard concepts. Default `FALSE`.

------------------------------------------------------------------------

### Method `relationships()`

Get concept relationships.

#### Usage

    ConceptsResource$relationships(
      concept_id,
      relationship_type = NULL,
      target_vocabulary = NULL,
      include_invalid = FALSE,
      page = 1,
      page_size = 20
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

  Items per page. Default 20.

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
