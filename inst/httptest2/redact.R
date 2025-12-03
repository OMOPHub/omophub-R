# Redaction function for httptest2
# Removes sensitive data from recorded HTTP responses

function(response) {
  # Redact API keys from headers
  response <- gsub_response(response, "Bearer [a-zA-Z0-9_-]+", "Bearer REDACTED")
  response <- gsub_response(response, "api_key=[^&]+", "api_key=REDACTED")
  response <- gsub_response(response, '"api_key":"[^"]+"', '"api_key":"REDACTED"')

  # Redact any OMOPHUB_API_KEY patterns
  response <- gsub_response(response, "oh_[a-zA-Z0-9]+", "oh_REDACTED")

  response
}
