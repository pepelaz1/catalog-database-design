# Catalog Database Design — SQL Server

An independent portfolio example showing how a multi-supplier product catalog moves from requirements and an ER diagram to C# entities and a Microsoft SQL Server database. All suppliers, products and prices are fictional.

![ER diagram of the catalog](docs/er-diagram.png)

## What is included

- [Requirements and assumptions](docs/requirements.md)
- [ER diagram and editable Mermaid source](docs/erd.md)
- [Mapping from ER entities to C# and SQL Server](docs/design.md)
- [Diagram tools and regeneration](docs/tooling.md)
- [C# entity classes](CatalogModel/Entities.cs)
- [T-SQL schema, sample data, queries, roles and checks](sql/README.md)

The C# classes are a transparent domain model; they do **not** create database tables by themselves. The checked-in T-SQL scripts are the physical database implementation. In an application using EF Core, a `DbContext` and migration would map these same classes to the tables, or database-first scaffolding would generate classes from the SQL Server schema.

## Build the model

```powershell
dotnet build CatalogModel/CatalogModel.csproj
```

## Create and test the database

Use a disposable SQL Server database. From an account permitted to create databases:

```powershell
sqlcmd -S . -E -b -Q "CREATE DATABASE CatalogDesignDemo"
sqlcmd -S . -E -b -d CatalogDesignDemo -i sql/001_schema.sql
sqlcmd -S . -E -b -d CatalogDesignDemo -i sql/002_seed.sql
sqlcmd -S . -E -b -d CatalogDesignDemo -i sql/003_queries.sql
sqlcmd -S . -E -b -d CatalogDesignDemo -i sql/005_checks.sql
```

`004_roles.sql` is an optional administrator-reviewed role template. It is not required for the data checks. Replace `.` with your SQL Server instance name when needed. The scripts assume a **fresh empty database** and intentionally do not delete or replace existing tables.

## Verification status

The C# model can be built locally without third-party packages. The SQL Server scripts are provided with repeatable data and assertions, but database execution must be confirmed on a working SQL Server instance. On the development machine used to prepare this sample, SQL Server connectivity failed during Windows authentication and LocalDB would not start; therefore no successful SQL Server integration run is claimed.

## Scope

Products, suppliers, supplier offers, import batches and price observations are separated so that a change of price never overwrites history. One currency is stored per offer; currency conversion, orders, authentication, retention and real supplier feeds are outside this focused example.
