# Design notes

## Logical model

`product` represents the merchant's canonical item. `supplier_offer` is the intersection between a supplier and a product and stores the supplier-specific SKU, source URL, and currency. `price_observation` holds facts that change over time. `import_batch` records provenance. `category` is a controlled classification.

This separation prevents product names and supplier attributes from being repeated for every price point. A price correction creates a new observation; the historical row is not overwritten. The model is in third normal form for the stated requirements. An offer's supplier is repeated in `price_observation` only as a constrained key component that enables PostgreSQL to enforce agreement between the offer and the batch.

## Physical model and indexing

- `bigint GENERATED ALWAYS AS IDENTITY` provides stable surrogate keys. Business identifiers remain unique (`product.sku`, supplier name, and `(supplier_id, supplier_sku)`).
- `numeric(14,2)` avoids floating-point errors for money. A check rejects negative values; an ISO-style uppercase three-letter code is required.
- Timestamp columns use `timestamptz`. Import timestamps and observation timestamps are distinct.
- `price_observation(offer_id, observed_at DESC, id DESC)` supports latest-price and history queries. `supplier_offer(product_id)` supports catalog lookup. Foreign-key and status indexes support joins and operational filtering.
- `(batch_id, offer_id)` is unique to prevent duplicated observations within one import.
- The schema does not cache a mutable "current price" field; a view derives it from immutable observations. This avoids disagreement between current and historical data.

## Security and operations

The application reader receives only `SELECT` on the catalog tables and the latest-state view. The importer gets `INSERT` and `UPDATE` on its operational tables plus sequence usage. The role script is intentionally separate from the migration, because role names and permissions should be reviewed per deployment. Connections should use TLS, secrets should be kept outside SQL files, and backups/retention should be configured by the operator.

## Performance validation

Run the queries in `003_queries.sql` with `EXPLAIN (ANALYZE, BUFFERS)` on representative production-scale data. The tiny seed set is useful for correctness, not meaningful timing. Revisit index choices after observing actual filters, cardinality, and write volume. Partitioning history would be considered only if measured growth justifies it.
