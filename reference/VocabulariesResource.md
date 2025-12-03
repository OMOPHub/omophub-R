# Vocabularies Resource

R6 class providing access to vocabulary operations.

## Value

Paginated vocabulary list.

Vocabulary details.

Vocabulary statistics.

Domain statistics for vocabularies.

Paginated concepts.

## Methods

### Public methods

- [`VocabulariesResource$new()`](#method-VocabulariesResource-new)

- [`VocabulariesResource$list()`](#method-VocabulariesResource-list)

- [`VocabulariesResource$get()`](#method-VocabulariesResource-get)

- [`VocabulariesResource$stats()`](#method-VocabulariesResource-stats)

- [`VocabulariesResource$domains()`](#method-VocabulariesResource-domains)

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

    VocabulariesResource$get(
      vocabulary_id,
      include_stats = FALSE,
      include_domains = FALSE
    )

#### Arguments

- `vocabulary_id`:

  The vocabulary ID.

- `include_stats`:

  Include statistics. Default `FALSE`.

- `include_domains`:

  Include domain breakdown. Default `FALSE`.

------------------------------------------------------------------------

### Method `stats()`

Get vocabulary statistics.

#### Usage

    VocabulariesResource$stats(vocabulary_id)

#### Arguments

- `vocabulary_id`:

  The vocabulary ID.

------------------------------------------------------------------------

### Method `domains()`

Get vocabulary domains.

#### Usage

    VocabulariesResource$domains(vocabulary_ids = NULL, page = 1, page_size = 50)

#### Arguments

- `vocabulary_ids`:

  Filter by vocabulary IDs (optional).

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 50.

------------------------------------------------------------------------

### Method `concepts()`

Get concepts in a vocabulary.

#### Usage

    VocabulariesResource$concepts(
      vocabulary_id,
      domain_id = NULL,
      concept_class_id = NULL,
      standard_only = FALSE,
      page = 1,
      page_size = 50
    )

#### Arguments

- `vocabulary_id`:

  The vocabulary ID.

- `domain_id`:

  Filter by domain.

- `concept_class_id`:

  Filter by concept class.

- `standard_only`:

  Only standard concepts. Default `FALSE`.

- `page`:

  Page number. Default 1.

- `page_size`:

  Results per page. Default 50.

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
