# From ER diagram to C# entities and SQL Server

An ER diagram is a design specification, not an executable database. Each entity becomes a C# class and a SQL table. A one-to-many relationship becomes a foreign-key column on the “many” side plus navigation properties in C#.

| ER element | C# domain model | SQL Server |
| --- | --- | --- |
| `PRODUCT` | `Product` with `Id`, `Sku`, `Name` | `catalog.product` with `BIGINT IDENTITY` primary key |
| `CATEGORY 1 → many PRODUCT` | `Product.CategoryId`, `Category`, `Category.Products` | Foreign key `product.category_id → category.id` |
| `SUPPLIER 1 → many SUPPLIER_OFFER` | `SupplierOffer.SupplierId`, `Supplier.Offers` | Foreign key and unique `(supplier_id, supplier_sku)` |
| `IMPORT_BATCH 1 → many PRICE_OBSERVATION` | `PriceObservation.BatchId`, `ImportBatch.Observations` | Foreign key and unique `(batch_id, offer_id)` |
| Price, availability, time | `decimal`, `bool`, `DateTimeOffset` | `DECIMAL(14,2)`, `BIT`, `DATETIMEOFFSET(0)` |

The class model is in [`CatalogModel/Entities.cs`](../CatalogModel/Entities.cs), and the physical schema is in [`sql/001_schema.sql`](../sql/001_schema.sql). Neither is generated blindly from the picture. The diagram helps review cardinality and ownership; the code and DDL express exact types and constraints.

## Logical design

`Product` is the canonical item. `SupplierOffer` connects a supplier to one product and carries the supplier-specific SKU and currency. `ImportBatch` records provenance. `PriceObservation` is append-only history. The model avoids repeating product or supplier details for every price point.

## Physical design

- `BIGINT IDENTITY` is used for stable surrogate IDs; business identifiers have separate unique constraints.
- `DECIMAL(14,2)` avoids floating-point money errors; check constraints reject negative prices and blank identifiers.
- SQL Server `DATETIMEOFFSET(0)` preserves timezone context.
- A composite key on `(id, supplier_id)` lets two foreign keys enforce that offer and batch have the same supplier.
- The latest-state view uses `ROW_NUMBER()` rather than a mutable current-price column.
- An index on `(offer_id, observed_at DESC, id DESC)` supports history and latest-state lookups. Indexes should be reviewed with actual query plans and realistic data volumes.
- Separate reader and importer roles illustrate least privilege.

## Testing

Build the C# project to catch type and syntax errors. Create a disposable SQL Server database, run schema then seed, and execute `005_checks.sql`. It asserts row counts, current price, retained history and rejection of invalid data. Inspect `003_queries.sql` results; on representative volumes run `SET STATISTICS IO, TIME ON` and view the actual execution plan in SSMS.
