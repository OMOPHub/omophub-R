# OMOPHub R SDK

**Query millions of standardized medical concepts from R**

Access SNOMED CT, ICD-10, RxNorm, LOINC, and 90+ OHDSI ATHENA
vocabularies without downloading, installing, or maintaining local
databases.

[![CRAN
status](https://www.r-pkg.org/badges/version/omophub)](https://CRAN.R-project.org/package=omophub)
[![CRAN
downloads](https://cranlogs.r-pkg.org/badges/omophub)](https://cran.r-project.org/package=omophub)
[![R-CMD-check](https://github.com/omopHub/omophub-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/omopHub/omophub-R/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/omopHub/omophub-R/branch/main/graph/badge.svg)](https://app.codecov.io/gh/omopHub/omophub-R?branch=main)
[![License:
MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

**[Documentation](https://docs.omophub.com/sdks/r/overview)** · **[API
Reference](https://docs.omophub.com/api-reference)** ·
**[Examples](https://github.com/omopHub/omophub-R/tree/main/inst/examples)**

------------------------------------------------------------------------

## Why OMOPHub?

Working with OHDSI ATHENA vocabularies traditionally requires
downloading multi-gigabyte files, setting up a database, and writing
complex SQL queries. **OMOPHub eliminates this friction.**

| Traditional Approach                   | With OMOPHub                  |
|----------------------------------------|-------------------------------|
| Download 5GB+ ATHENA vocabulary files  | `install.packages("omophub")` |
| Set up and maintain database instance  | One API call                  |
| Write complex SQL with multiple JOINs  | Simple R functions            |
| Manually update vocabularies quarterly | Always current data           |
| Local infrastructure required          | Works anywhere R runs         |

## Installation

``` r
# Install from CRAN
install.packages("omophub")

# Or install development version from GitHub
# install.packages("pak")
pak::pak("omopHub/omophub-R")
```

## Authentication

``` r
library(omophub)

# Option 1: Environment variable (recommended)
Sys.setenv(OMOPHUB_API_KEY = "oh_xxxxxxxxx")

# Option 2: Use helper function
set_api_key("oh_xxxxxxxxx")

# Option 3: Store securely in system keyring
set_api_key("oh_xxxxxxxxx", store = "keyring")
```

Get your API key from the [OMOPHub
Dashboard](https://dashboard.omophub.com/api-keys).

## Quick Start

``` r
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

## Use Cases

### ETL & Data Pipelines

Validate and map clinical codes during OMOP CDM transformations:

``` r
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

``` r
# Check if condition codes are valid
condition_codes <- c("E11.9", "I10", "J44.9")

for (code in condition_codes) {
  tryCatch({
    concept <- client$concepts$get_by_code("ICD10CM", code)
    message(sprintf("OK %s: %s", code, concept$concept_name))
  }, omophub_api_error = function(e) {
    message(sprintf("ERROR %s: Invalid code!", code))
  })
}
```

### Phenotype Development

Explore hierarchies to build comprehensive concept sets:

``` r
# Get all descendants for phenotype definition
descendants <- client$hierarchy$descendants(
  201826,  # Type 2 diabetes mellitus
  max_levels = 5
)

concept_set <- sapply(descendants$concepts, function(x) x$concept_id)
message(sprintf("Found %d concepts for T2DM phenotype", length(concept_set)))
```

### Integration with tidyverse

``` r
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

| Resource       | Description                         | Key Methods                                                                                            |
|----------------|-------------------------------------|--------------------------------------------------------------------------------------------------------|
| `concepts`     | Concept lookup and batch operations | [`get()`](https://rdrr.io/r/base/get.html), `get_by_code()`, `batch()`, `suggest()`                    |
| `search`       | Full-text and semantic search       | `basic()`, `advanced()`, `basic_all()`                                                                 |
| `hierarchy`    | Navigate concept relationships      | `ancestors()`, `descendants()`                                                                         |
| `mappings`     | Cross-vocabulary mappings           | [`get()`](https://rdrr.io/r/base/get.html), [`map()`](https://purrr.tidyverse.org/reference/map.html)  |
| `vocabularies` | Vocabulary metadata                 | [`list()`](https://rdrr.io/r/base/list.html), [`get()`](https://rdrr.io/r/base/get.html), `stats()`    |
| `domains`      | Domain information                  | [`list()`](https://rdrr.io/r/base/list.html), [`get()`](https://rdrr.io/r/base/get.html), `concepts()` |

## Pagination

``` r
# Automatic pagination - fetch all results
all_results <- client$search$basic_all("diabetes", page_size = 100)

# Manual pagination
page1 <- client$search$basic("diabetes", page = 1, page_size = 20)
page2 <- client$search$basic("diabetes", page = 2, page_size = 20)
```

## Configuration

``` r
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

``` r
tryCatch({
  result <- client$concepts$get(999999999)
}, omophub_not_found_error = function(e) {
  message("Concept not found: ", conditionMessage(e))
}, omophub_auth_error = function(e) {
  message("Check your API key")
}, omophub_rate_limit_error = function(e) {
  message("Rate limited, please wait")
}, omophub_api_error = function(e) {
  message("API error: ", conditionMessage(e))
})
```

## Compared to Alternatives

| Feature             | OMOPHub SDK | ATHENA Download       | OHDSI WebAPI     |
|---------------------|-------------|-----------------------|------------------|
| Setup time          | 1 minute    | Hours                 | Hours            |
| Infrastructure      | None        | PostgreSQL required   | Full OHDSI stack |
| Updates             | Automatic   | Manual download       | Manual           |
| Programmatic access | Native R    | SQL/DatabaseConnector | REST API         |

**Best for:** R users who need quick, programmatic access to OMOP
vocabularies without infrastructure overhead.

## Examples

The package includes comprehensive examples in `inst/examples/`:

| Example                      | Description                                             |
|------------------------------|---------------------------------------------------------|
| `basic_usage.R`              | Getting started - client setup, concept lookup, search  |
| `search_concepts.R`          | Search capabilities - filters, autocomplete, pagination |
| `navigate_hierarchy.R`       | Hierarchy navigation - ancestors, descendants           |
| `map_between_vocabularies.R` | Cross-vocabulary mapping                                |
| `error_handling.R`           | Error handling patterns                                 |

Run an example:

``` r
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

``` r
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
- [GitHub Discussions](https://github.com/omopHub/omophub-R/discussions)
- Email: <support@omophub.com>
- Website: [omophub.com](https://omophub.com)

## License

MIT License - see [LICENSE](https://omophub.github.io/omophub-R/LICENSE)
for details.

------------------------------------------------------------------------

*Built for the OHDSI community*
