# Changelog

## omophub 1.1.0

### New Features

- Added `include_synonyms` and `include_relationships` parameters to
  `get_by_code()` for retrieving concept synonyms and relationships in a
  single request.

### Changes

- User-Agent header updated to `OMOPHub-SDK-R/{version}`.

## omophub 1.0.0

### Initial CRAN Release

#### Features

- **Client**: R6-based `OMOPHubClient` for accessing OMOPHub API
- **Concepts**: Get, batch lookup, suggest, and explore medical concepts
- **Search**: Basic and advanced search with filtering and pagination
- **Vocabularies**: List and explore OMOP vocabularies
- **Domains**: Browse concepts by clinical domain
- **Hierarchy**: Navigate concept ancestors and descendants
- **Relationships**: Query concept relationships
- **Mappings**: Map concepts between vocabularies

#### Infrastructure

- Automatic rate limiting with
  [`httr2::req_throttle()`](https://httr2.r-lib.org/reference/req_throttle.html)
- Automatic retry with exponential backoff for transient errors
- Pagination helpers (`basic_all()`) returning tibbles
- Environment variable support for API key (`OMOPHUB_API_KEY`)
- Vocabulary version pinning via `vocab_version` parameter

#### Documentation

- Full roxygen2 documentation for all exported functions
- Getting started vignette
- pkgdown website support
