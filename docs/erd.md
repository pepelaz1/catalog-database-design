# Entity-relationship diagram

The PNG below is useful in proposals. The Mermaid definition is editable in Markdown and rendered directly by GitHub.

![Catalog ER diagram](er-diagram.png)

```mermaid
erDiagram
    CATEGORY ||--o{ PRODUCT : classifies
    PRODUCT ||--o{ SUPPLIER_OFFER : has
    SUPPLIER ||--o{ SUPPLIER_OFFER : publishes
    SUPPLIER ||--o{ IMPORT_BATCH : imports
    SUPPLIER_OFFER ||--o{ PRICE_OBSERVATION : tracks
    IMPORT_BATCH ||--o{ PRICE_OBSERVATION : records

    CATEGORY {
        bigint Id PK
        nvarchar Name UK
    }
    PRODUCT {
        bigint Id PK
        nvarchar Sku UK
        nvarchar Name
        nvarchar Brand
        bigint CategoryId FK
    }
    SUPPLIER {
        bigint Id PK
        nvarchar Name UK
        bit Active
    }
    SUPPLIER_OFFER {
        bigint Id PK
        bigint SupplierId FK
        bigint ProductId FK
        nvarchar SupplierSku
        varchar Currency
    }
    IMPORT_BATCH {
        bigint Id PK
        bigint SupplierId FK
        nvarchar SourceFile
        datetimeoffset StartedAt
        nvarchar Status
    }
    PRICE_OBSERVATION {
        bigint Id PK
        bigint OfferId FK
        bigint SupplierId FK
        bigint BatchId FK
        datetimeoffset ObservedAt
        decimal Price
        bit Available
    }
```

The observation's `SupplierId` participates in two composite foreign keys. This prevents attaching an offer from one supplier to an import batch from another supplier.
