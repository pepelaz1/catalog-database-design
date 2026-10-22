-- Optional deployment template: run as a database administrator, not as the app.
-- Do not add passwords here; provide credentials through your secret manager.
CREATE ROLE catalog_reader NOLOGIN;
CREATE ROLE catalog_importer NOLOGIN;

REVOKE ALL ON SCHEMA catalog FROM PUBLIC;
GRANT USAGE ON SCHEMA catalog TO catalog_reader, catalog_importer;

GRANT SELECT ON ALL TABLES IN SCHEMA catalog TO catalog_reader;

GRANT SELECT ON catalog.category, catalog.product, catalog.supplier,
    catalog.supplier_offer, catalog.import_batch, catalog.price_observation,
    catalog.latest_offer_state TO catalog_importer;
GRANT INSERT, UPDATE ON catalog.import_batch TO catalog_importer;
GRANT INSERT ON catalog.price_observation TO catalog_importer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA catalog TO catalog_importer;

-- Create separate LOGIN roles outside this file and grant only the appropriate
-- group role. A production importer must not receive DELETE on history.
