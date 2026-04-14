# OMOPHub R SDK

**Query millions of standardized medical concepts from R**

Access SNOMED CT, ICD-10, RxNorm, LOINC, and 90+ OHDSI ATHENA vocabularies without downloading, installing, or maintaining local databases.

[![CRAN status](https://www.r-pkg.org/badges/version/omophub)](https://CRAN.R-project.org/package=omophub)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/omophub)](https://cran.r-project.org/package=omophub)
[![R-CMD-check](https://github.com/omopHub/omophub-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/omopHub/omophub-R/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/omopHub/omophub-R/branch/main/graph/badge.svg)](https://app.codecov.io/gh/omopHub/omophub-R?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**[Documentation](https://docs.omophub.com/sdks/r/overview)** ·
**[API Reference](https://docs.omophub.com/api-reference)** ·
**[Examples](https://github.com/omopHub/omophub-R/tree/main/inst/examples)**

---

## Why OMOPHub?
Working with OHDSI ATHENA vocabularies traditionally requires downloading multi-gigabyte files, setting up a database, and writing complex SQL queries. **OMOPHub eliminates this friction.**

| Traditional Approach | With OMOPHub |
|---------------------|--------------|
| Download 5GB+ ATHENA vocabulary files | `install.packages("omophub")` |
| Set up and maintain database instance | One API call |
| Write complex SQL with multiple JOINs | Simple R functions |
| Manually update vocabularies quarterly | Always current data |
| Local infrastructure required | Works anywhere R runs |

## Installation

```r
# Install from CRAN
install.packages("omophub")

# Or install development version from GitHub
# install.packages("pak")
pak::pak("omopHub/omophub-R")
```

## Authentication

```r
library(omophub)

# Option 1: Environment variable (recommended)
Sys.setenv(OMOPHUB_API_KEY = "oh_xxxxxxxxx")

# Option 2: Use helper function
set_api_key("oh_xxxxxxxxx")

# Option 3: Store securely in system keyring
set_api_key("oh_xxxxxxxxx", store = "keyring")
```

Get your API key from the [OMOPHub Dashboard](https://dashboard.omophub.com/api-keys).

## Quick Start

```r
library(omophub)

# Create client
client <- OMOPHubClient$new()

# Get a concept by ID
concept <- client$concepts$get(201826)
concept$concept_name
# [1] "Type 2 diabetes mellitus"

# Search for concepts
results <- client$search$basic("metformin", vocabulary_ids = "RxNorm")
results$data

# Get concept by vocabulary code
snomed_concept <- client$concepts$get_by_code("SNOMED", "44054006")

# Map to another vocabulary
mappings <- client$mappings$get(201826, target_vocabulary = "ICD10CM")

# Navigate hierarchy
ancestors <- client$hierarchy$ancestors(201826, max_levels = 3)
```

## Semantic Search

Use natural language queries to find concepts using neural embeddings:

```r
# Natural language search - understands clinical intent
results <- client$search$semantic("high blood sugar levels")
for (r in results$data$results) {
  cat(sprintf("%s (similarity: %.2f)\n", r$concept_name, r$similarity_score))
}

# Filter by vocabulary and set minimum similarity threshold
results <- client$search$semantic(
  "heart attack",
  vocabulary_ids = "SNOMED",
  domain_ids = "Condition",
  threshold = 0.5
)

# Fetch all results with auto-pagination
all_results <- client$search$semantic_all("chronic kidney disease", page_size = 50)

# Find concepts similar to a reference concept
similar <- client$search$similar(concept_id = 201826, algorithm = "hybrid")
for (s in similar$similar_concepts) {
  cat(sprintf("%s (score: %.2f)\n", s$concept_name, s$similarity_score))
}
```

### Bulk Search

Search for multiple terms in a single API call:

```r
# Bulk lexical search (up to 50 queries) - returns a flat list of
# per-query result objects; iterate it directly.
results <- client$search$bulk_basic(list(
  list(search_id = "q1", query = "diabetes mellitus"),
  list(search_id = "q2", query = "hypertension"),
  list(search_id = "q3", query = "aspirin")
), defaults = list(vocabulary_ids = list("SNOMED"), page_size = 5))

for (item in results) {
  cat(sprintf("%s: %d results\n", item$search_id, length(item$results)))
}

# Bulk semantic search (up to 25 queries) - returns a dict with
# `results`, `total_searches`, `completed_count`, and `total_duration`.
response <- client$search$bulk_semantic(list(
  list(search_id = "s1", query = "heart failure treatment options"),
  list(search_id = "s2", query = "type 2 diabetes medication")
), defaults = list(threshold = 0.5, page_size = 10))

for (item in response$results) {
  cat(sprintf("%s: %d results\n", item$search_id, length(item$results)))
}
```

## FHIR-to-OMOP Resolution

Resolve FHIR coded values to OMOP standard concepts in one call:

```r
# Single FHIR Coding -> OMOP concept + CDM target table
result <- client$fhir$resolve(
  system = "http://snomed.info/sct",
  code = "44054006",
  resource_type = "Condition"
)
result$resolution$target_table
# [1] "condition_occurrence"

# ICD-10-CM -> traverses 'Maps to' automatically
result <- client$fhir$resolve(
  system = "http://hl7.org/fhir/sid/icd-10-cm",
  code = "E11.9"
)
result$resolution$standard_concept$vocabulary_id
# [1] "SNOMED"

# Batch resolve up to 100 codings
batch <- client$fhir$resolve_batch(list(
  list(system = "http://snomed.info/sct", code = "44054006"),
  list(system = "http://loinc.org", code = "2339-0"),
  list(system = "http://www.nlm.nih.gov/research/umls/rxnorm", code = "197696")
))
cat(sprintf("Resolved %d/%d\n", batch$summary$resolved, batch$summary$total))

# CodeableConcept with vocabulary preference (SNOMED wins over ICD-10)
result <- client$fhir$resolve_codeable_concept(
  coding = list(
    list(system = "http://snomed.info/sct", code = "44054006"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
  ),
  resource_type = "Condition"
)
result$best_match$resolution$source_concept$vocabulary_id
# [1] "SNOMED"
```

### Tibble Output for Batch Resolution

Pass `as_tibble = TRUE` to get a flat [`tibble`](https://tibble.tidyverse.org/) with one row per input coding - ready to pipe into `dplyr` / `tidyr`:

```r
library(dplyr)

tbl <- client$fhir$resolve_batch(
  list(
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "I10"),
    list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "J45.909")
  ),
  as_tibble = TRUE
)

tbl |>
  filter(status == "resolved") |>
  select(source_code, standard_concept_name, target_table)
#> # A tibble: 3 x 3
#>   source_code standard_concept_name       target_table
#>   <chr>       <chr>                       <chr>
#> 1 E11.9       Type 2 diabetes mellitus    condition_occurrence
#> 2 I10         Essential hypertension      condition_occurrence
#> 3 J45.909     Asthma                      condition_occurrence
```

The tibble columns are `source_system`, `source_code`, `source_concept_id`, `source_concept_name`, `standard_concept_id`, `standard_concept_name`, `standard_vocabulary_id`, `domain_id`, `target_table`, `mapping_type`, `similarity_score`, `status`, and `status_detail`. Failed rows stay in-place with `status = "failed"` and the API error text in `status_detail`. The batch summary (`total` / `resolved` / `failed`) is attached as `attr(tbl, "summary")`.

Default `as_tibble = FALSE` still returns the legacy `list(results, summary)` shape.

### Standalone Wrapper Functions

The R6 interface is always available:

```r
client$fhir$resolve(system = "http://snomed.info/sct", code = "44054006")
```

For pipe-friendly workflows, three standalone wrappers forward to the same R6 methods and take the client as their first argument:

```r
# Equivalent to client$fhir$resolve()
client |>
  fhir_resolve(
    system = "http://snomed.info/sct",
    code = "44054006",
    resource_type = "Condition"
  )

# Tibble-shaped batch in a pipe
tbl <- client |>
  fhir_resolve_batch(
    codings = list(
      list(system = "http://snomed.info/sct", code = "44054006"),
      list(system = "http://loinc.org", code = "2339-0")
    ),
    as_tibble = TRUE
  )

client |>
  fhir_resolve_codeable_concept(
    coding = list(
      list(system = "http://snomed.info/sct", code = "44054006"),
      list(system = "http://hl7.org/fhir/sid/icd-10-cm", code = "E11.9")
    ),
    resource_type = "Condition"
  )
```

Both forms are fully supported - pick whichever reads better for the surrounding code.

### FHIR Client Interop

When you need raw FHIR `Parameters` / `Bundle` responses instead of the Concept Resolver envelope, `omophub_fhir_url()` returns the OMOPHub FHIR Terminology Service base URL for a given FHIR version (`"r4"` default, plus `"r4b"`, `"r5"`, `"r6"`). Use it with [`httr2`](https://httr2.r-lib.org/) or [`fhircrackr`](https://cran.r-project.org/package=fhircrackr) to talk directly to OMOPHub's FHIR endpoint.

```r
library(httr2)

# Call CodeSystem/$lookup directly against OMOPHub's FHIR endpoint
resp <- request(omophub_fhir_url()) |>
  req_url_path_append("CodeSystem/$lookup") |>
  req_url_query(
    system = "http://snomed.info/sct",
    code = "44054006"
  ) |>
  req_headers(Authorization = paste("Bearer", Sys.getenv("OMOPHUB_API_KEY"))) |>
  req_perform()

params <- resp_body_json(resp)
# Raw FHIR Parameters resource with the concept display and designations.

# R5 / R6 endpoints work the same way
omophub_fhir_url("r5")
#> "https://fhir.omophub.com/fhir/r5"
```

**When to use which**: Use `client$fhir$resolve()` (or `fhir_resolve()`) when you want OMOP-enriched answers (standard concept, CDM target table, mapping quality). Use `omophub_fhir_url()` + `httr2` when you need raw FHIR responses for FHIR-native tooling.

## Use Cases

### ETL & Data Pipelines

Validate and map clinical codes during OMOP CDM transformations:

```r
# Validate source codes and find standard equivalents
validate_and_map <- function(source_vocab, source_code) {
  concept <- client$concepts$get_by_code(source_vocab, source_code)
  
  if (concept$standard_concept != "S") {
    mappings <- client$mappings$get(
      concept$concept_id,
      target_vocabulary = "SNOMED"
    )
    return(mappings$mappings[[1]]$target_concept_id)
  }
  
  concept$concept_id
}

# Example: Map ICD-10 to SNOMED
standard_id <- validate_and_map("ICD10CM", "E11.9")
```

### Data Quality Checks

Verify codes exist and are valid:

```r
# Check if condition codes are valid. HTTP 404 responses come through
# as httr2's `httr2_http_404` condition class.
condition_codes <- c("E11.9", "I10", "J44.9")

for (code in condition_codes) {
  tryCatch({
    concept <- client$concepts$get_by_code("ICD10CM", code)
    message(sprintf("OK %s: %s", code, concept$concept_name))
  }, httr2_http_404 = function(e) {
    message(sprintf("ERROR %s: Invalid code!", code))
  })
}
```

### Phenotype Development

Explore hierarchies to build comprehensive concept sets:

```r
# Get all descendants for phenotype definition. `descendants()` returns
# `list(data = list(descendants = [...], concept_id, concept_name, ...), meta)`
descendants <- client$hierarchy$descendants(
  201826,  # Type 2 diabetes mellitus
  max_levels = 5
)

descendant_list <- descendants$data$descendants
concept_set <- vapply(descendant_list, function(x) x$concept_id, integer(1))
message(sprintf("Found %d concepts for T2DM phenotype", length(concept_set)))
```

### Integration with tidyverse

```r
library(dplyr)
library(purrr)

# Search and convert to tibble
results <- client$search$basic("hypertension", page_size = 100)

concepts_df <- results$data %>%
  map_dfr(~ tibble(
    concept_id = .x$concept_id,
    concept_name = .x$concept_name,
    vocabulary_id = .x$vocabulary_id,
    domain_id = .x$domain_id
  ))

# Filter and analyze
concepts_df %>%
  filter(vocabulary_id == "SNOMED") %>%
  count(domain_id)
```

## API Resources

| Resource | Description | Key Methods |
|----------|-------------|-------------|
| `concepts` | Concept lookup and batch operations | `get()`, `get_by_code()`, `batch()`, `suggest()` |
| `search` | Full-text and semantic search | `basic()`, `advanced()`, `semantic()`, `similar()`, `bulk_basic()`, `bulk_semantic()` |
| `hierarchy` | Navigate concept relationships | `ancestors()`, `descendants()` |
| `mappings` | Cross-vocabulary mappings | `get()`, `map()` |
| `vocabularies` | Vocabulary metadata | `list()`, `get()`, `stats()` |
| `domains` | Domain information | `list()`, `get()`, `concepts()` |
| `fhir` | FHIR-to-OMOP resolution | `resolve()`, `resolve_batch()`, `resolve_codeable_concept()` |

## Pagination

```r
# Automatic pagination - fetch all results
all_results <- client$search$basic_all("diabetes", page_size = 100)

# Manual pagination
page1 <- client$search$basic("diabetes", page = 1, page_size = 20)
page2 <- client$search$basic("diabetes", page = 2, page_size = 20)
```

## Configuration

```r
# Specify vocabulary version
client <- OMOPHubClient$new(vocab_version = "2025.2")

# Custom configuration
client <- OMOPHubClient$new(
  api_key = "oh_xxx",
  base_url = "https://api.omophub.com/v1",
  timeout = 30
)
```

## Error Handling

HTTP errors are raised as [httr2 condition classes](https://httr2.r-lib.org/reference/req_error.html) (`httr2_http_404`, `httr2_http_401`, `httr2_http_429`, `httr2_http_403`, etc.). Pre-request input-validation errors use the SDK's `omophub_validation_error` class.

```r
tryCatch({
  result <- client$concepts$get(999999999)
}, httr2_http_404 = function(e) {
  message("Concept not found: ", conditionMessage(e)[[1]])
}, httr2_http_401 = function(e) {
  message("Unauthorized - check your API key")
}, httr2_http_403 = function(e) {
  message("Forbidden - API key lacks permission or vocabulary restricted")
}, httr2_http_429 = function(e) {
  # The SDK already auto-retries 429 via httr2::req_retry() with
  # exponential backoff; handle here only for custom logging.
  message("Rate limited (", e$retry_after %||% "?", "s)")
}, httr2_http = function(e) {
  # Generic HTTP error fallback (any 4xx/5xx not caught above)
  message("HTTP error: ", conditionMessage(e)[[1]])
}, omophub_validation_error = function(e) {
  # Pre-request validation (bad concept_id type, empty query, etc.)
  message("Validation error: ", conditionMessage(e)[[1]])
})
```

See [`inst/examples/error_handling.R`](inst/examples/error_handling.R) for the full set of patterns including graceful degradation and batch error collection.

## Compared to Alternatives

| Feature | OMOPHub SDK | ATHENA Download | OHDSI WebAPI |
|---------|-------------|-----------------|--------------|
| Setup time | 1 minute | Hours | Hours |
| Infrastructure | None | PostgreSQL required | Full OHDSI stack |
| Updates | Automatic | Manual download | Manual |
| Programmatic access | Native R | SQL/DatabaseConnector | REST API |

**Best for:** R users who need quick, programmatic access to OMOP vocabularies without infrastructure overhead.

## Examples

The package includes comprehensive examples in `inst/examples/`:

| Example | Description |
|---------|-------------|
| `basic_usage.R` | Getting started - client setup, concept lookup, search |
| `search_concepts.R` | Search capabilities - filters, autocomplete, pagination |
| `navigate_hierarchy.R` | Hierarchy navigation - ancestors, descendants |
| `map_between_vocabularies.R` | Cross-vocabulary mapping |
| `error_handling.R` | Error handling patterns |
| `fhir_resolver.R` | FHIR Concept Resolver - single / batch / CodeableConcept, quality, recommendations |
| `fhir_interop.R` | 1.7.0 interop - tibble batch output, standalone wrappers, `omophub_fhir_url()` |

Run an example:

```r
example_path <- system.file("examples", "basic_usage.R", package = "omophub")
source(example_path)
```

## Documentation

- [Full Documentation](https://docs.omophub.com/sdks/r/overview)
- [API Reference](https://docs.omophub.com/api-reference)
- [Examples](https://github.com/omopHub/omophub-R/tree/main/inst/examples)
- [Get API Key](https://dashboard.omophub.com/api-keys)

## Contributing

We welcome contributions! 

```r
# Clone and install for development
# install.packages("devtools")
devtools::install_github("omopHub/omophub-R")

# Run tests
devtools::test()

# Check package
devtools::check()
```

## Support

- [GitHub Issues](https://github.com/omopHub/omophub-R/issues)
- Email: support@omophub.com
- Website: [omophub.com](https://omophub.com)

## License

MIT License - see [LICENSE](LICENSE) for details.

---

*Built for the OHDSI community*
