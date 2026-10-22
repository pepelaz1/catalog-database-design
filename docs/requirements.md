# Illustrative requirements and assumptions

1. A catalog product has a stable internal SKU, name, optional brand and category.
2. A supplier can publish multiple offers. Its offer SKU is unique within that supplier.
3. Different suppliers may sell the same catalog product.
4. An import batch records supplier, file name, start time and outcome.
5. Each observed price and availability state is linked to its offer and import batch.
6. Historical observations remain available for price-change reports.
7. A read-only query exposes the most recent observation per offer.

## Assumptions to confirm for a real implementation

- The catalog manager or a matching process decides whether two supplier offers refer to the same product.
- `decimal(14,2)` represents money; cross-currency comparison requires exchange-rate data.
- One offer is observed at most once in each import batch.
- Timestamps are represented with `datetimeoffset`; imports should supply a consistent timezone.
- History retention, privacy rules, source validation and expected data volume need agreement.

These requirements are fictional and use no client data.
