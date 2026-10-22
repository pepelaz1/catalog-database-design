-- Fictional data. Run only after 001_schema.sql in a disposable database.
SET IDENTITY_INSERT catalog.category ON;
INSERT INTO catalog.category (id, name) VALUES
    (1, N'Audio'), (2, N'Cameras');
SET IDENTITY_INSERT catalog.category OFF;

SET IDENTITY_INSERT catalog.product ON;
INSERT INTO catalog.product (id, sku, name, brand, category_id) VALUES
    (1, N'MIC-100', N'USB microphone', N'DemoSound', 1),
    (2, N'CAM-200', N'Compact camera', N'DemoOptics', 2),
    (3, N'HEAD-300', N'Studio headphones', N'DemoSound', 1);
SET IDENTITY_INSERT catalog.product OFF;

SET IDENTITY_INSERT catalog.supplier ON;
INSERT INTO catalog.supplier (id, name, active) VALUES
    (1, N'North Supply', 1), (2, N'East Trading', 1);
SET IDENTITY_INSERT catalog.supplier OFF;

SET IDENTITY_INSERT catalog.supplier_offer ON;
INSERT INTO catalog.supplier_offer
    (id, supplier_id, product_id, supplier_sku, currency, source_url) VALUES
    (1, 1, 1, N'NS-MIC', 'RUB', N'https://example.invalid/north/mic'),
    (2, 1, 2, N'NS-CAM', 'RUB', N'https://example.invalid/north/cam'),
    (3, 2, 1, N'ET-MIC', 'RUB', N'https://example.invalid/east/mic'),
    (4, 2, 3, N'ET-HEAD', 'RUB', N'https://example.invalid/east/head');
SET IDENTITY_INSERT catalog.supplier_offer OFF;

SET IDENTITY_INSERT catalog.import_batch ON;
INSERT INTO catalog.import_batch
    (id, supplier_id, source_file, started_at, status) VALUES
    (1, 1, N'north-2026-10-20.csv', '2026-10-20T09:00:00+00:00', N'completed'),
    (2, 2, N'east-2026-10-20.csv', '2026-10-20T09:30:00+00:00', N'completed'),
    (3, 1, N'north-2026-10-21.csv', '2026-10-21T09:00:00+00:00', N'completed');
SET IDENTITY_INSERT catalog.import_batch OFF;

SET IDENTITY_INSERT catalog.price_observation ON;
INSERT INTO catalog.price_observation
    (id, offer_id, supplier_id, batch_id, observed_at, price, available) VALUES
    (1, 1, 1, 1, '2026-10-20T09:05:00+00:00', 4200.00, 1),
    (2, 2, 1, 1, '2026-10-20T09:05:00+00:00', 18500.00, 1),
    (3, 3, 2, 2, '2026-10-20T09:35:00+00:00', 3990.00, 1),
    (4, 4, 2, 2, '2026-10-20T09:35:00+00:00', 7100.00, 0),
    (5, 1, 1, 3, '2026-10-21T09:05:00+00:00', 4050.00, 1),
    (6, 2, 1, 3, '2026-10-21T09:05:00+00:00', 18500.00, 0);
SET IDENTITY_INSERT catalog.price_observation OFF;
GO
