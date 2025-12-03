# Getting Started with omophub

## Introduction

The omophub package provides an R interface to the OMOPHub API for
accessing OHDSI ATHENA standardized medical vocabularies. This vignette
demonstrates basic usage patterns.

## Installation

Install from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("omophub/omophub-R")
```

## Authentication

The package requires an API key from
[OMOPHub](https://dashboard.omophub.com).

Set your API key as an environment variable:

``` r
Sys.setenv(OMOPHUB_API_KEY = "your_api_key_here")
```

Or add it to your `.Renviron` file for persistence:

    OMOPHUB_API_KEY=your_api_key_here

## Creating a Client

``` r
library(omophub)

# Create client (reads API key from environment)
client <- OMOPHubClient$new()

# Or provide API key explicitly
client <- OMOPHubClient$new(api_key = "your_api_key")

# With additional options
client <- OMOPHubClient$new(
  api_key = "your_api_key",
  timeout = 30,
  max_retries = 3,
  vocab_version = "2025.1"
)
```

## Getting Concepts

Retrieve a concept by its OMOP concept ID:

``` r
concept <- client$concepts$get(201826)
print(concept$concept_name)
# [1] "Type 2 diabetes mellitus"
```

Get a concept by vocabulary-specific code:

``` r
concept <- client$concepts$get_by_code("SNOMED", "44054006")
print(concept$concept_name)
# [1] "Type 2 diabetes mellitus"
```

## Batch Operations

Retrieve multiple concepts in a single request:

``` r
result <- client$concepts$batch(c(201826, 4329847, 1112807))
for (concept in result$concepts) {
  cat(sprintf("%s: %s\n", concept$concept_id, concept$concept_name))
}
```

## Searching Concepts

Basic search:

``` r
results <- client$search$basic("diabetes mellitus", page_size = 10)
for (concept in results$data) {
  cat(sprintf("%s: %s\n", concept$concept_id, concept$concept_name))
}
```

Search with filters:

``` r
results <- client$search$basic(
  "heart attack",
  vocabulary_ids = "SNOMED",
  domain_ids = "Condition",
  page_size = 20
)
```

## Autocomplete

Get suggestions for autocomplete:

``` r
suggestions <- client$search$autocomplete("diab", max_suggestions = 5)
for (s in suggestions$suggestions) {
  print(s$suggestion)
}
```

## Pagination

### Manual Pagination

``` r
# First page
results <- client$search$basic("diabetes", page = 1, page_size = 50)

# Check pagination info
print(results$meta$total_items)
print(results$meta$has_next)

# Get next page if available
if (isTRUE(results$meta$has_next)) {
  page2 <- client$search$basic("diabetes", page = 2, page_size = 50)
}
```

### Automatic Pagination

Fetch all results as a tibble:

``` r
all_results <- client$search$basic_all(
  "diabetes",
  page_size = 100,
  max_pages = 5,
  progress = TRUE
)

# Results are a tibble
print(nrow(all_results))
print(names(all_results))
```

## Hierarchy Navigation

Get ancestors (parent concepts):

``` r
result <- client$hierarchy$ancestors(201826, max_levels = 3)
for (ancestor in result$ancestors) {
  print(ancestor$concept_name)
}
```

Get descendants (child concepts):

``` r
result <- client$hierarchy$descendants(201826, max_levels = 2)
for (descendant in result$descendants) {
  print(descendant$concept_name)
}
```

## Concept Mappings

Find how a concept maps to other vocabularies:

``` r
result <- client$mappings$get(201826)
for (mapping in result$mappings) {
  cat(sprintf("%s: %s\n",
              mapping$target_vocabulary_id,
              mapping$target_concept_name))
}
```

Map to specific vocabularies:

``` r
result <- client$mappings$get(
  201826,
  target_vocabularies = c("ICD10CM", "ICD9CM")
)
```

## Error Handling

Use `tryCatch` to handle errors:

``` r
tryCatch(
  {
    concept <- client$concepts$get(999999999)
  },
  omophub_not_found = function(e) {
    message("Concept not found: ", e$message)
  },
  omophub_api_error = function(e) {
    message("API error: ", e$message)
  }
)
```

## Further Resources

- [OMOPHub API Documentation](https://docs.omophub.com)
- [Package Documentation](https://omophub.github.io/omophub-R)
- [GitHub Repository](https://github.com/omophub/omophub-R)
