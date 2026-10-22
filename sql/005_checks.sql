-- Verification on a disposable seeded database.
-- Errors are raised to sqlcmd because the README uses -b.
IF (SELECT COUNT(*) FROM catalog.product) <> 3
    THROW 50001, 'Expected three products', 1;
IF (SELECT COUNT(*) FROM catalog.price_observation) <> 6
    THROW 50002, 'Expected six observations', 1;
IF (SELECT COUNT(*) FROM catalog.latest_offer_state
    WHERE supplier_sku = N'NS-MIC' AND price = 4050.00) <> 1
    THROW 50003, 'Latest microphone price is incorrect', 1;
IF (SELECT COUNT(*) FROM catalog.price_observation
    WHERE offer_id = 1 AND price IN (4200.00, 4050.00)) <> 2
    THROW 50004, 'Price history was not retained', 1;
IF (SELECT COUNT(*) FROM catalog.latest_offer_state AS l
    JOIN catalog.supplier_offer AS o ON o.id = l.offer_id
    JOIN catalog.product AS p ON p.id = o.product_id
    WHERE p.sku = N'MIC-100' AND l.available = 1) <> 2
    THROW 50005, 'Expected two available microphone offers', 1;

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO catalog.price_observation
        (offer_id, supplier_id, batch_id, observed_at, price, available)
    VALUES (1, 1, 3, SYSDATETIMEOFFSET(), -1.00, 1);
    THROW 50006, 'Negative price was accepted', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 547
    BEGIN
        ROLLBACK TRANSACTION;
        THROW;
    END;
END CATCH;
ROLLBACK TRANSACTION;

PRINT 'All catalog database checks passed';
GO
