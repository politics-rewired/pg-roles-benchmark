# PostgreSQL Roles Benchmark

These benchmarks seek to answer the question: are PostgreSQL roles and row-level security a viable approach for managing application users and authorization in production?

- How many database roles is it feasible to use with row level security?
- How many levels of role inheritance are feasible?

## Definitions

- **User Role** - role mapped to application user. Will not have any child roles.
- **Group Role** - role without login capability with many child **User Roles**.

## Approach

1. Determine **User Role** count behavior characteristics for tables of 1 million and 10 million records.
2. Determine **Group Role** inheritence depth characteristics for a table of 1 million records and 100,000 **User Roles**.
3. Increase complexity of queries to include nested views and joins.
