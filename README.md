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

## Background

### RLS with Traditional Application Users

A number of companies have written about how to use traditional application users with row level security. We recently saw a talk by Bennie Swart of Quant Engineering Solutions and found a [blog post by 2nd Quadrant](https://blog.2ndquadrant.com/application-users-vs-row-level-security/) on the subject.

The problem with this approach, from our perspective, is that it does not allow leveraging the robust permission structure offered out of the box by inherited roles. Some would argue that this is exactly the point -- that complex permissions make it difficult to audit.

## Process

### Creating the Test Database

We need to create a large table, many user, and an assortment of row level permissions.

To create the users, we follow [the approach presented by Hans-Jürgen Schönig](https://www.cybertec-postgresql.com/en/creating-1-million-users-in-postgresql/) at CyberTec:

```sql
create user big_group;

select 'create user xy' || id || ' in role big_group;'
    from generate_series(1, (10^4)::int) as id;
\gexec
```

Next we create the table:

```sql
create table big_table as
select id
from generate_series(1, (10^6)::int) _(id);

alter table big_table enable row level security;

grant select on big_table to big_group;
```

And now we create to create semi-complex RLS policies.

```sql
create policy view_own on big_table for select using (('xy' || mod(id, (10^4)::int)) = current_user);
```

### Creating a Workload

```sql
set role xy20;
select id from big_table where id between 10 and 20;
```
