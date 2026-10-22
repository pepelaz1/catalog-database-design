-- Run in an empty Microsoft SQL Server database.
CREATE SCHEMA catalog;
GO

CREATE TABLE catalog.category (
    id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_category PRIMARY KEY,
    name NVARCHAR(120) NOT NULL,
    CONSTRAINT uq_category_name UNIQUE (name),
    CONSTRAINT ck_category_name CHECK (LEN(LTRIM(RTRIM(name))) > 0)
);

CREATE TABLE catalog.product (
    id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_product PRIMARY KEY,
    sku NVARCHAR(80) NOT NULL,
    name NVARCHAR(240) NOT NULL,
    brand NVARCHAR(120) NULL,
    category_id BIGINT NOT NULL,
    CONSTRAINT uq_product_sku UNIQUE (sku),
    CONSTRAINT ck_product_sku CHECK (LEN(LTRIM(RTRIM(sku))) > 0),
    CONSTRAINT ck_product_name CHECK (LEN(LTRIM(RTRIM(name))) > 0),
    CONSTRAINT fk_product_category FOREIGN KEY (category_id)
        REFERENCES catalog.category(id)
);

CREATE TABLE catalog.supplier (
    id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_supplier PRIMARY KEY,
    name NVARCHAR(160) NOT NULL,
    active BIT NOT NULL CONSTRAINT df_supplier_active DEFAULT (1),
    CONSTRAINT uq_supplier_name UNIQUE (name),
    CONSTRAINT ck_supplier_name CHECK (LEN(LTRIM(RTRIM(name))) > 0)
);

CREATE TABLE catalog.supplier_offer (
    id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_supplier_offer PRIMARY KEY,
    supplier_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    supplier_sku NVARCHAR(100) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    source_url NVARCHAR(500) NULL,
    CONSTRAINT fk_offer_supplier FOREIGN KEY (supplier_id)
        REFERENCES catalog.supplier(id),
    CONSTRAINT fk_offer_product FOREIGN KEY (product_id)
        REFERENCES catalog.product(id),
    CONSTRAINT uq_offer_supplier_sku UNIQUE (supplier_id, supplier_sku),
    CONSTRAINT uq_offer_id_supplier UNIQUE (id, supplier_id),
    CONSTRAINT ck_offer_sku CHECK (LEN(LTRIM(RTRIM(supplier_sku))) > 0),
    CONSTRAINT ck_offer_currency CHECK (
        currency COLLATE Latin1_General_100_BIN2 LIKE '[A-Z][A-Z][A-Z]'
    )
);

CREATE TABLE catalog.import_batch (
    id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_import_batch PRIMARY KEY,
    supplier_id BIGINT NOT NULL,
    source_file NVARCHAR(260) NOT NULL,
    started_at DATETIMEOFFSET(0) NOT NULL
        CONSTRAINT df_import_batch_started DEFAULT (SYSDATETIMEOFFSET()),
    status NVARCHAR(16) NOT NULL,
    CONSTRAINT fk_batch_supplier FOREIGN KEY (supplier_id)
        REFERENCES catalog.supplier(id),
    CONSTRAINT uq_batch_id_supplier UNIQUE (id, supplier_id),
    CONSTRAINT ck_batch_file CHECK (LEN(LTRIM(RTRIM(source_file))) > 0),
    CONSTRAINT ck_batch_status CHECK (status IN (N'started', N'completed', N'failed'))
);

CREATE TABLE catalog.price_observation (
    id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT pk_price_observation PRIMARY KEY,
    offer_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    batch_id BIGINT NOT NULL,
    observed_at DATETIMEOFFSET(0) NOT NULL,
    price DECIMAL(14,2) NOT NULL,
    available BIT NOT NULL,
    CONSTRAINT fk_observation_offer FOREIGN KEY (offer_id, supplier_id)
        REFERENCES catalog.supplier_offer(id, supplier_id),
    CONSTRAINT fk_observation_batch FOREIGN KEY (batch_id, supplier_id)
        REFERENCES catalog.import_batch(id, supplier_id),
    CONSTRAINT uq_observation_batch_offer UNIQUE (batch_id, offer_id),
    CONSTRAINT ck_observation_price CHECK (price >= 0)
);

CREATE INDEX ix_product_category ON catalog.product(category_id);
CREATE INDEX ix_offer_product ON catalog.supplier_offer(product_id);
CREATE INDEX ix_batch_supplier_started
    ON catalog.import_batch(supplier_id, started_at DESC);
CREATE INDEX ix_batch_unfinished ON catalog.import_batch(status)
    WHERE status <> N'completed';
CREATE INDEX ix_observation_offer_time
    ON catalog.price_observation(offer_id, observed_at DESC, id DESC)
    INCLUDE (price, available, batch_id);
GO

CREATE VIEW catalog.latest_offer_state AS
WITH ranked AS (
    SELECT o.id AS offer_id, o.supplier_id, o.product_id,
           o.supplier_sku, o.currency,
           p.price, p.available, p.observed_at, p.batch_id,
           ROW_NUMBER() OVER (
               PARTITION BY o.id ORDER BY p.observed_at DESC, p.id DESC
           ) AS rn
    FROM catalog.supplier_offer AS o
    JOIN catalog.price_observation AS p ON p.offer_id = o.id
)
SELECT offer_id, supplier_id, product_id, supplier_sku, currency,
       price, available, observed_at, batch_id
FROM ranked WHERE rn = 1;
GO
