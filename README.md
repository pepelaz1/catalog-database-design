# Catalog Database Design

A focused PostgreSQL database design sample for a multi-supplier product catalog. It demonstrates the deliverables requested in database-design projects: requirements, an ER diagram, logical and physical schema, executable DDL, indexes, access roles, sample data, and verification queries.

This is an **independent portfolio example using synthetic data**. It is not the LaborX client's database and does not claim to model requirements the client has not supplied.

## Scenario

An online merchant imports product offers from multiple suppliers. One product can have several supplier offers. Every import batch is traceable; prices and availability are recorded as an append-only history. Staff can inspect the latest and previous observed prices without overwriting historical observations.

## Deliverables

- [Requirements and assumptions](docs/requirements.md)
- [ER diagram](docs/erd.md)
- [Logical and physical design decisions](docs/design.md)
- [Schema migration](sql/001_schema.sql)
- [Synthetic seed data](sql/002_seed.sql)
- [Practical queries](sql/003_queries.sql)
- [Least-privilege role template](sql/004_roles.sql)
- [Database checks](sql/005_checks.sql)

## Run with PostgreSQL 14+

Create a disposable database, then run in order:

```sh
createdb catalog_design_demo
psql -v ON_ERROR_STOP=1 -d catalog_design_demo -f sql/001_schema.sql
psql -v ON_ERROR_STOP=1 -d catalog_design_demo -f sql/002_seed.sql
psql -v ON_ERROR_STOP=1 -d catalog_design_demo -f sql/003_queries.sql
psql -v ON_ERROR_STOP=1 -d catalog_design_demo -f sql/005_checks.sql
```

`004_roles.sql` is an optional deployment template. It creates database roles and grants privileges, so run it only as a database administrator after replacing its example role names according to the deployment environment. No credentials are stored in this repository.

The schema, seed, queries, role grants, and checks were run successfully against PostgreSQL 14 on 22 October 2026.

## What the checks cover

`005_checks.sql` verifies seed counts, referential integrity, latest-price selection, price-change history, and rejection of an invalid negative price. The final negative-price test uses a savepoint so the check does not alter data.

## Scope

The schema separates products, suppliers, offers, import batches, and observations. It supports one currency per offer and records a new observation when a feed reports a price or availability change. Exchange rates, customer orders, authentication, and retention rules are deliberately outside this sample. Real requirements would determine whether those entities and controls belong in the final design.
