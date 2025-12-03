# Set OMOPHub API Key

Stores the OMOPHub API key in the specified location.

## Usage

``` r
set_api_key(key, store = c("env", "keyring"))
```

## Arguments

- key:

  The API key to store.

- store:

  Where to store the key. One of:

  - `"env"`: Set as environment variable for current session (default)

  - `"keyring"`: Store securely in system keyring (requires `keyring`
    package)

## Value

Invisibly returns `TRUE` on success.

## Examples

``` r
if (FALSE) { # \dontrun{
# Store in environment (current session only)
set_api_key("your_api_key")

# Store securely in keyring (persistent)
set_api_key("your_api_key", store = "keyring")
} # }
```
