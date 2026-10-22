# Requirements and assumptions

## Illustrative requirements

1. A catalog product has a stable internal SKU, name, optional brand, and category.
2. A supplier may publish several offers, but its own offer SKU is unique within that supplier.
3. Different suppliers may sell the same catalog product.
4. An import batch identifies the supplier, file name, start time, and outcome.
5. Every observed price and availability state is traceable to a batch.
6. Historical observations are retained so users can calculate price changes.
7. Readers can query the latest offer state without modifying import data.

## Assumptions to validate with a real client

- Money is stored as `numeric(14,2)` in an offer's ISO 4217 currency. Cross-currency comparisons require an exchange-rate source and are not implemented.
- Product identity is assigned by a catalog manager or matching pipeline; supplier SKUs alone do not prove two offers refer to the same product.
- One feed observation per offer per batch is sufficient. A repeated import is a new batch.
- `observed_at` is supplied by the import process in UTC. Equal timestamps are ordered by observation ID.
- The sample retains all history. Production retention and privacy rules need agreement.
- Imports and role administration are done by separate trusted processes. No end-user accounts are modeled.

These are **sample** requirements, not a representation of the LaborX customer's undisclosed project.
