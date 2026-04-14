# omophub 1.7.0

## New Features

* **Tibble output for batch FHIR resolution**
  `FhirResource$resolve_batch()` (and the standalone `fhir_resolve_batch()`)
  gained an `as_tibble` parameter. When `as_tibble = TRUE`, the call returns
  a flat `tibble::tibble` with one row per input coding and columns for the
  source concept, standard concept, target CDM table, mapping type, and
  resolution status - ready to pipe into `dplyr` / `tidyr`. The batch
  summary (`total` / `resolved` / `failed`) is attached as
  `attr(result, "summary")`. Default behavior is unchanged: `as_tibble = FALSE`
  still returns the legacy list shape.

* **Standalone wrapper functions**
  Thin, pipe-friendly wrappers around the R6 `FhirResource` methods:

  - `fhir_resolve(client, ...)`
  - `fhir_resolve_batch(client, ...)`
  - `fhir_resolve_codeable_concept(client, ...)`

  Both the R6 form (`client$fhir$resolve(...)`) and the standalone form
  work; pick whichever reads better in your pipeline.

* **FHIR client interop helper**
  New exported function `omophub_fhir_url(version)` returning the OMOPHub
  FHIR Terminology Service base URL for a given FHIR version (`"r4"`,
  `"r4b"`, `"r5"`, `"r6"`). Use it with `httr2`, `fhircrackr`, or any
  external FHIR client that wants to talk to OMOPHub's FHIR endpoint
  directly.

# omophub 1.6.0

## New Features

* **FHIR-to-OMOP Concept Resolver** (`client$fhir`): Translate FHIR coded
  values into OMOP standard concepts, CDM target tables, and optional Phoebe
  recommendations in a single API call.

  - `resolve()`: Resolve a single FHIR `Coding` (system URI + code) or
    text-only input via semantic search fallback. Returns the standard
    concept, target CDM table, domain alignment check, and optional mapping
    quality signal.

  - `resolve_batch()`: Batch-resolve up to 100 FHIR codings per request with
    inline per-item error reporting.

  - `resolve_codeable_concept()`: Resolve a FHIR `CodeableConcept` with
    multiple codings. Automatically picks the best match per OHDSI vocabulary
    preference (SNOMED > RxNorm > LOINC > CVX > ICD-10). Falls back to the
    `text` field via semantic search when no coding resolves.

## Tests

* Improved test coverage

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
