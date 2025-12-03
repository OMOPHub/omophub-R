# omophub <a href="https://omophub.github.io/omophub-R/"><img src="man/figures/logo.png" align="right" height="139" alt="omophub website" /></a>

<!-- badges: start -->
[![R-CMD-check](https://github.com/omopHub/omophub-R/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/omopHub/omophub-R/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/omopHub/omophub-R/branch/main/graph/badge.svg)](https://app.codecov.io/gh/omopHub/omophub-R?branch=main)
[![CRAN status](https://www.r-pkg.org/badges/version/omophub)](https://CRAN.R-project.org/package=omophub)
<!-- badges: end -->

R client for the [OMOPHub API](https://docs.omophub.com), providing access to OHDSI ATHENA standardized medical vocabularies.

## Installation

You can install the development version of omophub from [GitHub](https://github.com/omopHub/omophub-R):

```r
# install.packages("pak")
pak::pak("omopHub/omophub-R")
```

## Authentication

Set your API key using one of these methods:

```r
# Option 1: Environment variable (recommended)
Sys.setenv(OMOPHUB_API_KEY = "your_api_key")

# Option 2: Use the helper function
library(omophub)
set_api_key("your_api_key")

# Option 3: Store securely in system keyring
set_api_key("your_api_key", store = "keyring")
```

## Quick Start

```r
library(omophub)

# Create a client
client <- OMOPHubClient$new()

# Search for concepts
results <- client$search$basic("diabetes")
results$data

# Get a specific concept
concept <- client$concepts$get(201826)
concept$concept_name
# [1] "Type 2 diabetes mellitus"

# Get concept by vocabulary code
concept <- client$concepts$get_by_code("SNOMED", "44054006")

# Batch lookup multiple concepts
batch <- client$concepts$batch(c(201826, 320128, 4329847))

# Get concept ancestors (hierarchy)
ancestors <- client$hierarchy$ancestors(201826)

# Get concept mappings to another vocabulary
mappings <- client$mappings$get(201826, target_vocabularies = "ICD10CM")
```

## Resources

The client provides access to these resources:

| Resource | Description |
|----------|-------------|
| `concepts` | Concept lookup, batch operations, suggestions |
| `search` | Basic and advanced concept search |
| `vocabularies` | Vocabulary listing and details |
| `domains` | Domain listing and concept filtering |
| `hierarchy` | Ancestor and descendant navigation |
| `relationships` | Concept relationships |
| `mappings` | Concept mappings between vocabularies |

## Pagination

For large result sets, use automatic pagination:

```r
# Fetch all results automatically
all_results <- client$search$basic_all("diabetes", page_size = 100)

# Or paginate manually
page1 <- client$search$basic("diabetes", page = 1, page_size = 20)
page2 <- client$search$basic("diabetes", page = 2, page_size = 20)
```

## Vocabulary Versioning

Specify a vocabulary version when creating the client:
```r
client <- OMOPHubClient$new(vocab_version = "2025.2")
```

## Error Handling

The package uses structured error classes:

```r
tryCatch(
  {
    result <- client$concepts$get(999999999)
  },
  omophub_api_error = function(e) {
    message("API error: ", conditionMessage(e))
  },
  omophub_auth_error = function(e) {
    message("Authentication failed")
  }
)
```


## Documentation

- [Full Documentation](https://docs.omophub.com/sdks/r/overview)
- [API Reference](https://docs.omophub.com/api-reference)
- [Examples](https://github.com/omopHub/omophub-r/tree/main/examples)

## License

MIT License - see [LICENSE](LICENSE) for details.

## Support

- [GitHub Issues](https://github.com/omopHub/omophub-r/issues)
- [Documentation](https://docs.omophub.com)