# Domains Resource

R6 class providing access to domain operations.

## Value

Domain list.

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

    DomainsResource$list(include_stats = FALSE)

#### Arguments

- `include_stats`:

  Include concept counts and vocabulary coverage. Default `FALSE`.

------------------------------------------------------------------------

### Method `concepts()`

Get concepts in a domain.

#### Usage

    DomainsResource$concepts(
      domain_id,
      vocabulary_ids = NULL,
      standard_only = FALSE,
      include_invalid = FALSE,
      page = 1,
      page_size = 50
    )

#### Arguments

- `domain_id`:

  The domain ID.

- `vocabulary_ids`:

  Filter by vocabularies.

- `standard_only`:

  Only standard concepts. Default `FALSE`.

- `include_invalid`:

  Include invalid/deprecated concepts. Default `FALSE`.

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
