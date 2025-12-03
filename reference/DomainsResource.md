# Domains Resource

R6 class providing access to domain operations.

## Value

Domain list with summary.

Paginated concepts.

## Methods

### Public methods

- [`DomainsResource$new()`](#method-DomainsResource-new)

- [`DomainsResource$list()`](#method-DomainsResource-list)

- [`DomainsResource$concepts()`](#method-DomainsResource-concepts)

- [`DomainsResource$print()`](#method-DomainsResource-print)

- [`DomainsResource$clone()`](#method-DomainsResource-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new DomainsResource.

#### Usage

    DomainsResource$new(base_req)

#### Arguments

- `base_req`:

  Base httr2 request object.

------------------------------------------------------------------------

### Method [`list()`](https://rdrr.io/r/base/list.html)

List all domains.

#### Usage

    DomainsResource$list(
      vocabulary_ids = NULL,
      include_concept_counts = TRUE,
      include_statistics = FALSE,
      include_examples = FALSE,
      standard_only = FALSE,
      active_only = TRUE,
      sort_by = "domain_id",
      sort_order = "asc"
    )

#### Arguments

- `vocabulary_ids`:

  Filter by vocabularies.

- `include_concept_counts`:

  Include concept counts. Default `TRUE`.

- `include_statistics`:

  Include detailed statistics. Default `FALSE`.

- `include_examples`:

  Include example concepts. Default `FALSE`.

- `standard_only`:

  Only standard concepts. Default `FALSE`.

- `active_only`:

  Only active domains. Default `TRUE`.

- `sort_by`:

  Sort field. Default "domain_id".

- `sort_order`:

  Sort order. Default "asc".

------------------------------------------------------------------------

### Method `concepts()`

Get concepts in a domain.

#### Usage

    DomainsResource$concepts(
      domain_id,
      vocabulary_ids = NULL,
      concept_class_ids = NULL,
      standard_only = FALSE,
      page = 1,
      page_size = 50
    )

#### Arguments

- `domain_id`:

  The domain ID.

- `vocabulary_ids`:

  Filter by vocabularies.

- `concept_class_ids`:

  Filter by concept classes.

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

    DomainsResource$print()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    DomainsResource$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
