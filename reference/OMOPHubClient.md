# OMOPHub API Client

R6 class for interacting with the OMOPHub vocabulary service. Provides
access to OHDSI ATHENA standardized medical vocabularies.

## Value

A new `OMOPHubClient` object.

## Details

The client provides access to these resources:

- `concepts`: Concept lookup and batch operations

- `search`: Basic and advanced concept search

- `vocabularies`: Vocabulary listing and details

- `domains`: Domain listing and concept filtering

- `hierarchy`: Ancestor and descendant navigation

- `relationships`: Concept relationships

- `mappings`: Concept mappings between vocabularies

## Active bindings

- `concepts`:

  Access to concept operations.

- `search`:

  Access to search operations.

- `vocabularies`:

  Access to vocabulary operations.

- `domains`:

  Access to domain operations.

- `hierarchy`:

  Access to hierarchy operations.

- `relationships`:

  Access to relationship operations.

- `mappings`:

  Access to mapping operations.

## Methods

### Public methods

- [`OMOPHubClient$new()`](#method-OMOPHubClient-new)

- [`OMOPHubClient$print()`](#method-OMOPHubClient-print)

- [`OMOPHubClient$clone()`](#method-OMOPHubClient-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new OMOPHub client.

#### Usage

    OMOPHubClient$new(
      api_key = NULL,
      base_url = NULL,
      timeout = 30,
      max_retries = 3,
      vocab_version = NULL
    )

#### Arguments

- `api_key`:

  API key for authentication. If not provided, reads from
  `OMOPHUB_API_KEY` environment variable or system keyring.

- `base_url`:

  API base URL. Defaults to `https://api.omophub.com/v1`.

- `timeout`:

  Request timeout in seconds. Defaults to 30.

- `max_retries`:

  Maximum retry attempts for failed requests. Defaults to 3.

- `vocab_version`:

  Optional vocabulary version (e.g., "2025.1"). If not specified, uses
  the latest version.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print client information.

#### Usage

    OMOPHubClient$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    OMOPHubClient$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# Create client (uses OMOPHUB_API_KEY env var)
client <- OMOPHubClient$new()

# Or with explicit API key
client <- OMOPHubClient$new(api_key = "your_api_key")

# Search for concepts
results <- client$search$basic("diabetes")

# Get a specific concept
concept <- client$concepts$get(201826)

# Use specific vocabulary version
client <- OMOPHubClient$new(vocab_version = "2025.1")
} # }
```
