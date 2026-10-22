-- Optional deployment template: review before running as a database administrator.
-- SQL Server login creation and credential management are environment-specific.
CREATE ROLE catalog_reader;
CREATE ROLE catalog_importer;
GO
GRANT SELECT ON SCHEMA::catalog TO catalog_reader;
GRANT SELECT ON SCHEMA::catalog TO catalog_importer;
GRANT INSERT, UPDATE ON OBJECT::catalog.import_batch TO catalog_importer;
GRANT INSERT ON OBJECT::catalog.price_observation TO catalog_importer;
-- Neither role receives DELETE on historical observations.
GO
