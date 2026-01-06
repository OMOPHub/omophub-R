# Vocabularies Resource

R6 class providing access to vocabulary operations.

## Value

Paginated vocabulary list.

Vocabulary details including vocabulary_id, vocabulary_name,
vocabulary_reference, vocabulary_version, vocabulary_concept_id.

Vocabulary statistics.

Domain statistics including concept counts and class breakdown.

List of all available domains with domain_id, domain_name, and
description.

List of all available concept classes with concept_class_id,
concept_class_name, and concept_class_concept_id.

Paginated concepts.

## Methods

### Public methods

- [`VocabulariesResource$new()`](#method-VocabulariesResource-new)

- [`VocabulariesResource$list()`](#method-VocabulariesResource-list)

- [`VocabulariesResource$get()`](#method-VocabulariesResource-get)

- [`VocabulariesResource$stats()`](#method-VocabulariesResource-stats)

- [`VocabulariesResource$domain_stats()`](#method-VocabulariesResource-domain_stats)

- [`VocabulariesResource$domains()`](#method-VocabulariesResource-domains)

- [`VocabulariesResource$concept_classes()`](#method-VocabulariesResource-concept_classes)

- [`VocabulariesResource$concepts()`](#method-VocabulariesResource-concepts)

- [`VocabulariesResource$print()`](#method-VocabulariesResource-print)

- [`VocabulariesResource$clone()`](#method-VocabulariesResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new VocabulariesResource.

#### Usage

    VocabulariesResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method [`list()`](https://rdrr.io/r/base/list.html)

List all vocabularies.

#### Usage

    VocabulariesResource$list(
      include_stats = FALSE,
      include_inactive = FALSE,
      sort_by = "name",
      sort_order = "asc",
      page = 1,
      page_size = 100
    )

#### Arguments

- `include_stats`:

  Include vocabulary statistics. Default `FALSE`.

- `include_inactive`:

  Include inactive vocabularies. Default `FALSE`.

- `sort_by`:

  Sort field ("name", "priority", "updated"). Default "name".

- `sort_order`:

  Sort order ("asc" or "desc"). Default "asc".

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 100.

------------------------------------------------------------------------

### Method [`get()`](https://rdrr.io/r/base/get.html)

Get vocabulary details.

#### Usage

    VocabulariesResource$get(vocabulary_id)

#### Arguments

- `vocabulary_id`:

  The vocabulary ID.

------------------------------------------------------------------------

### Method `stats()`

Get vocabulary statistics.

#### Usage

    VocabulariesResource$stats(vocabulary_id)

#### Arguments

- `vocabulary_id`:

  The vocabulary ID.

------------------------------------------------------------------------

### Method `domain_stats()`

Get statistics for a specific domain within a vocabulary.

#### Usage

    VocabulariesResource$domain_stats(vocabulary_id, domain_id)

#### Arguments

- `vocabulary_id`:

  The vocabulary ID (e.g., "SNOMED", "ICD10CM").

- `domain_id`:

  The domain ID (e.g., "Condition", "Drug", "Procedure").

------------------------------------------------------------------------

### Method `domains()`

Get all standard OHDSI domains.

#### Usage

    VocabulariesResource$domains()

------------------------------------------------------------------------

### Method `concept_classes()`

Get all concept classes.

#### Usage

    VocabulariesResource$concept_classes()

------------------------------------------------------------------------

### Method `concepts()`

Get concepts in a vocabulary.

#### Usage

    VocabulariesResource$concepts(
      vocabulary_id,
      search = NULL,
      standard_concept = "all",
      include_invalid = FALSE,
      include_relationships = FALSE,
      include_synonyms = FALSE,
      sort_by = "name",
      sort_order = "asc",
      page = 1,
      page_size = 20
    )

#### Arguments

- `vocabulary_id`:

  The vocabulary ID.

- `search`:

  Search term to filter concepts by name or code.

- `standard_concept`:

  Filter by standard concept status ('S', 'C', 'all'). Default "all".

- `include_invalid`:

  Include invalid or deprecated concepts. Default `FALSE`.

- `include_relationships`:

  Include concept relationships. Default `FALSE`.

- `include_synonyms`:

  Include concept synonyms. Default `FALSE`.

- `sort_by`:

  Sort field ('name', 'concept_id', 'concept_code'). Default "name".

- `sort_order`:

  Sort order ('asc' or 'desc'). Default "asc".

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page (max 1000). Default 20.

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print resource information.

#### Usage

    VocabulariesResource$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    VocabulariesResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
