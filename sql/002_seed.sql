BEGIN;

INSERT INTO catalog.category (id, name) VALUES
    (1, 'Audio'),
    (2, 'Cameras');

INSERT INTO catalog.product (id, sku, name, brand, category_id) VALUES
    (1, 'MIC-100', 'USB microphone', 'DemoSound', 1),
    (2, 'CAM-200', 'Compact camera', 'DemoOptics', 2),
    (3, 'HEAD-300', 'Studio headphones', 'DemoSound', 1);

INSERT INTO catalog.supplier (id, name) VALUES
    (1, 'North Supply'),
    (2, 'East Trading');

INSERT INTO catalog.supplier_offer
    (id, supplier_id, product_id, supplier_sku, currency, source_url) VALUES
    (1, 1, 1, 'NS-MIC', 'RUB', 'https://example.invalid/north/mic'),
    (2, 1, 2, 'NS-CAM', 'RUB', 'https://example.invalid/north/cam'),
    (3, 2, 1, 'ET-MIC', 'RUB', 'https://example.invalid/east/mic'),
    (4, 2, 3, 'ET-HEAD', 'RUB', 'https://example.invalid/east/head');

INSERT INTO catalog.import_batch
    (id, supplier_id, source_file, started_at, status) VALUES
    (1, 1, 'north-2026-10-20.csv', '2026-10-20 09:00:00+00', 'completed'),
    (2, 2, 'east-2026-10-20.csv', '2026-10-20 09:30:00+00', 'completed'),
    (3, 1, 'north-2026-10-21.csv', '2026-10-21 09:00:00+00', 'completed');

INSERT INTO catalog.price_observation
    (id, offer_id, supplier_id, batch_id, observed_at, price, available) VALUES
    (1, 1, 1, 1, '2026-10-20 09:05:00+00', 4200.00, true),
    (2, 2, 1, 1, '2026-10-20 09:05:00+00', 18500.00, true),
    (3, 3, 2, 2, '2026-10-20 09:35:00+00', 3990.00, true),
    (4, 4, 2, 2, '2026-10-20 09:35:00+00', 7100.00, false),
    (5, 1, 1, 3, '2026-10-21 09:05:00+00', 4050.00, true),
    (6, 2, 1, 3, '2026-10-21 09:05:00+00', 18500.00, false);

SELECT setval(pg_get_serial_sequence('catalog.category', 'id'), 2);
SELECT setval(pg_get_serial_sequence('catalog.product', 'id'), 3);
SELECT setval(pg_get_serial_sequence('catalog.supplier', 'id'), 2);
SELECT setval(pg_get_serial_sequence('catalog.supplier_offer', 'id'), 4);
SELECT setval(pg_get_serial_sequence('catalog.import_batch', 'id'), 3);
SELECT setval(pg_get_serial_sequence('catalog.price_observation', 'id'), 6);

COMMIT;
