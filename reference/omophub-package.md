# omophub: R Client for the 'OMOPHub' Medical Vocabulary API

Provides an R interface to the 'OMOPHub' API for accessing 'OHDSI
ATHENA' standardized medical vocabularies. Supports concept search,
vocabulary exploration, hierarchy navigation, relationship queries, and
concept mappings with automatic pagination and rate limiting.

Provides an R interface to the OMOPHub API for accessing OHDSI ATHENA
standardized medical vocabularies. Supports concept search, vocabulary
exploration, hierarchy navigation, relationship queries, and concept
mappings with automatic pagination and rate limiting.

## Main Client

The main entry point is the
[OMOPHubClient](https://omophub.github.io/omophub-R/reference/OMOPHubClient.md)
R6 class which provides access to all API resources:

    library(omophub)
    client <- OMOPHubClient$new()

    # Search for concepts
    results <- client$search$basic("diabetes")

    # Get a specific concept
    concept <- client$concepts$get(201826)

## Authentication

Set your API key using one of these methods:

- Environment variable: `OMOPHUB_API_KEY`

- Explicit argument: `OMOPHubClient$new(api_key = "your_key")`

- Keyring: `set_api_key("your_key", store = "keyring")`

## Resources

The client provides access to these resources:

- `concepts`: Concept lookup and batch operations

- `search`: Basic and advanced concept search

- `vocabularies`: Vocabulary listing and details

- `domains`: Domain listing and concept filtering

- `hierarchy`: Ancestor and descendant navigation

- `relationships`: Concept relationships

- `mappings`: Concept mappings between vocabularies

## See also

Useful links:

- <https://github.com/omopHub/omophub-R>

- <https://docs.omophub.com>

- <https://omophub.github.io/omophub-R/>

- <https://omophub.com>

- Report bugs at <https://github.com/omopHub/omophub-R/issues>

## Author

**Maintainer**: Alex Chen <alex@omophub.com> \[copyright holder\]

Other contributors:

- Observational Health Data Science and Informatics \[copyright holder\]
