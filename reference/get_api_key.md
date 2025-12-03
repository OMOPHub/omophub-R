# Get OMOPHub API Key

Retrieves the OMOPHub API key from multiple sources in priority order:

1.  Explicit argument

2.  `OMOPHUB_API_KEY` environment variable

3.  System keyring (if `keyring` package is installed)

## Usage

``` r
get_api_key(key = NULL)
```

## Arguments

- key:

  Optional explicit API key. If provided, this takes precedence.

## Value

A character string containing the API key.

## Examples

``` r
if (FALSE) { # \dontrun{
# From environment variable
Sys.setenv(OMOPHUB_API_KEY = "your_api_key")
key <- get_api_key()

# Explicit key
key <- get_api_key("your_api_key")
} # }
```
