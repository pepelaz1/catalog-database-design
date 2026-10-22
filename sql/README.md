# SQL Server scripts

Run on a **fresh disposable database** in this order: `001_schema.sql`, `002_seed.sql`, `003_queries.sql`, `005_checks.sql`. The scripts use T-SQL and `GO` batch separators, so use `sqlcmd` or SQL Server Management Studio.

`004_roles.sql` is optional and must be reviewed by an administrator before production use. It does not contain passwords.

The checks are designed to run inside a transaction and roll back their deliberate invalid-data attempt. They do not replace a real integration test against the target SQL Server version and production-like data volume.
