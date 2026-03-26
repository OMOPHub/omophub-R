# omophub 1.5.0

## New Features

* **Bulk lexical search** (`bulk_basic()`): Execute up to 50 keyword searches
  in a single API call. Supports shared default filters for vocabulary, domain,
  and other parameters. Each search is identified by a unique `search_id` for
  result matching. Maps to `POST /v1/search/bulk`.

* **Bulk semantic search** (`bulk_semantic()`): Execute up to 25 natural-language
  searches using neural embeddings in a single call. Supports per-search
  similarity thresholds and shared defaults. Query length validated at 1-500
  characters. Maps to `POST /v1/search/semantic-bulk`.

# omophub 1.4.0

## New Features

* **Semantic search** (`semantic()`, `semantic_all()`): Natural language concept
  search using neural embeddings. Search for clinical intent like "high blood
  sugar levels" to find diabetes-related concepts. Supports filtering by
  vocabulary, domain, standard concept, concept class, and minimum similarity
  threshold. `semantic_all()` provides automatic pagination with progress bar.

* **Similarity search** (`similar()`): Find concepts similar to a reference
  concept ID, concept name, or natural language query. Three algorithm options:
  `'semantic'` (neural embeddings), `'lexical'` (string matching), and
  `'hybrid'` (combined). Configurable similarity threshold with optional
  detailed scores and explanations.

# omophub 1.3.0

## New Features

* **Hierarchy `get()` method**: New method to retrieve complete concept hierarchy (ancestors and descendants) in a single call with support for "flat" or "graph" visualization formats.

* **Vocabulary `domain_stats()` method**: New method to get statistics for a specific domain within a vocabulary.

* **Vocabulary `concept_classes()` method**: New method to list all available concept classes.

* Added `vocab_release` parameter to concepts, mappings, relationships, and hierarchy methods for explicit vocabulary version pinning.

* Added `include_hierarchy` parameter to `concepts$get()` and `concepts$get_by_code()`.

## Changes

* **API parameter naming**: Updated to match OMOPHub API v1.3.0 specifications:
  - `limit` → `page_size` for pagination
  - `vocabulary`, `domain` → `vocabulary_ids`, `domain_ids` for filtering
  - `max_results` → `page_size` for result limits
  - `relationship_type` → `relationship_ids` for relationship filtering
  - `target_vocabularies` → `target_vocabulary` (singular) in mappings
  - `vocabulary_id` → `vocabulary_ids` (plural) in hierarchy methods

* **API simplifications**: Several methods now have fewer parameters to match the simplified backend API:
  - `mappings$get()`: Removed `direction`, `include_indirect`, `standard_only`, `include_mapping_quality`, `include_synonyms`, `include_context`, pagination
  - `domains$list()`: Simplified to single `include_stats` parameter
  - `vocabularies$get()`: Now takes only `vocabulary_id`
  - `vocabularies$domains()`: Now takes no parameters

* **Batch limits**: `concepts$batch()` maximum reduced from 1000 to 100 concepts per request.

* **Default changes**:
  - `concepts$batch()` `standard_only` default changed from `FALSE` to `TRUE`
  - `relationships$get()` default `page_size` changed from 50 to 100

## Bug Fixes

* Fixed tests to use correct parameter names matching SDK implementation

# omophub 1.1.0

## New Features

* Added `include_synonyms` and `include_relationships` parameters to `get_by_code()` for retrieving concept synonyms and relationships in a single request.

## Changes

* User-Agent header updated to `OMOPHub-SDK-R/{version}`.

# omophub 1.0.0

## Initial CRAN Release

### Features

* **Client**: R6-based `OMOPHubClient` for accessing OMOPHub API
* **Concepts**: Get, batch lookup, suggest, and explore medical concepts
* **Search**: Basic and advanced search with filtering and pagination
* **Vocabularies**: List and explore OMOP vocabularies
* **Domains**: Browse concepts by clinical domain
* **Hierarchy**: Navigate concept ancestors and descendants
* **Relationships**: Query concept relationships
* **Mappings**: Map concepts between vocabularies

### Infrastructure

* Automatic rate limiting with `httr2::req_throttle()`
* Automatic retry with exponential backoff for transient errors
* Pagination helpers (`basic_all()`) returning tibbles
* Environment variable support for API key (`OMOPHUB_API_KEY`)
* Vocabulary version pinning via `vocab_version` parameter

### Documentation

* Full roxygen2 documentation for all exported functions
* Getting started vignette
* pkgdown website support
