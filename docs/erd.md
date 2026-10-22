# Entity-relationship diagram

```mermaid
erDiagram
    CATEGORY ||--o{ PRODUCT : classifies
    PRODUCT ||--o{ SUPPLIER_OFFER : has
    SUPPLIER ||--o{ SUPPLIER_OFFER : publishes
    SUPPLIER ||--o{ IMPORT_BATCH : imports
    IMPORT_BATCH ||--o{ PRICE_OBSERVATION : records
    SUPPLIER_OFFER ||--o{ PRICE_OBSERVATION : tracks

    CATEGORY {
        bigint id PK
        text name UK
    }
    PRODUCT {
        bigint id PK
        text sku UK
        text name
        text brand
        bigint category_id FK
    }
    SUPPLIER {
        bigint id PK
        text name UK
        boolean active
    }
    SUPPLIER_OFFER {
        bigint id PK
        bigint supplier_id FK
        bigint product_id FK
        text supplier_sku
        char currency
        text source_url
    }
    IMPORT_BATCH {
        bigint id PK
        bigint supplier_id FK
        text source_file
        timestamptz started_at
        text status
    }
    PRICE_OBSERVATION {
        bigint id PK
        bigint offer_id FK
        bigint batch_id FK
        timestamptz observed_at
        numeric price
        boolean available
    }
```

One supplier offer is one supplier's listing of one catalog product. A price observation belongs to both an offer and an import batch. A composite foreign key ensures both refer to the same supplier.
