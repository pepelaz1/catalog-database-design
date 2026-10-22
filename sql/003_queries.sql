-- Current supplier offers for one product.
SELECT p.sku, p.name, s.name AS supplier, o.supplier_sku,
       l.price, l.currency, l.available, l.observed_at
FROM catalog.product AS p
JOIN catalog.supplier_offer AS o ON o.product_id = p.id
JOIN catalog.supplier AS s ON s.id = o.supplier_id
JOIN catalog.latest_offer_state AS l ON l.offer_id = o.id
WHERE p.sku = N'MIC-100'
ORDER BY l.price, s.name;

-- Latest change for each offer with at least two observations.
;WITH ordered AS (
    SELECT offer_id, price, observed_at,
           LAG(price) OVER (
               PARTITION BY offer_id ORDER BY observed_at, id
           ) AS previous_price,
           ROW_NUMBER() OVER (
               PARTITION BY offer_id ORDER BY observed_at DESC, id DESC
           ) AS newest_first
    FROM catalog.price_observation
)
SELECT o.supplier_sku, ordered.previous_price,
       ordered.price AS current_price,
       ordered.price - ordered.previous_price AS price_change,
       ordered.observed_at
FROM ordered
JOIN catalog.supplier_offer AS o ON o.id = ordered.offer_id
WHERE ordered.newest_first = 1 AND ordered.previous_price IS NOT NULL
ORDER BY o.supplier_sku;

-- Trace the current observation back to its source file.
SELECT o.supplier_sku, l.price, b.source_file, b.started_at
FROM catalog.latest_offer_state AS l
JOIN catalog.supplier_offer AS o ON o.id = l.offer_id
JOIN catalog.import_batch AS b ON b.id = l.batch_id
ORDER BY o.supplier_sku;
GO
