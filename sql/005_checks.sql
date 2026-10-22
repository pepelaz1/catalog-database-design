DO $$
DECLARE
    n integer;
BEGIN
    SELECT count(*) INTO n FROM catalog.product;
    IF n <> 3 THEN RAISE EXCEPTION 'expected 3 products, got %', n; END IF;

    SELECT count(*) INTO n FROM catalog.price_observation;
    IF n <> 6 THEN RAISE EXCEPTION 'expected 6 observations, got %', n; END IF;

    SELECT count(*) INTO n
    FROM catalog.latest_offer_state AS l
    JOIN catalog.supplier_offer AS o ON o.id = l.offer_id
    JOIN catalog.product AS p ON p.id = o.product_id
    WHERE p.sku = 'MIC-100' AND l.available;
    IF n <> 2 THEN RAISE EXCEPTION 'expected two available microphone offers'; END IF;

    SELECT count(*) INTO n FROM catalog.latest_offer_state
    WHERE supplier_sku = 'NS-MIC' AND price = 4050.00;
    IF n <> 1 THEN RAISE EXCEPTION 'latest microphone price is incorrect'; END IF;

    SELECT count(*) INTO n FROM catalog.price_observation
    WHERE offer_id = 1 AND price IN (4200.00, 4050.00);
    IF n <> 2 THEN RAISE EXCEPTION 'price history was not retained'; END IF;

    BEGIN
        INSERT INTO catalog.price_observation
            (offer_id, supplier_id, batch_id, observed_at, price, available)
        VALUES (1, 1, 3, now(), -1.00, true);
        RAISE EXCEPTION 'negative price was accepted';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;

    RAISE NOTICE 'All catalog database checks passed';
END $$;
