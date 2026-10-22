namespace CatalogModel;

// Each class corresponds to an ER entity and a table in sql/001_schema.sql.
// These POCO classes do not create tables without an ORM mapping/migration.
public sealed class Category
{
    public long Id { get; set; }
    public required string Name { get; set; }
    public ICollection<Product> Products { get; } = new List<Product>();
}

public sealed class Product
{
    public long Id { get; set; }
    public required string Sku { get; set; }
    public required string Name { get; set; }
    public string? Brand { get; set; }
    public long CategoryId { get; set; }
    public Category? Category { get; set; }
    public ICollection<SupplierOffer> Offers { get; } = new List<SupplierOffer>();
}

public sealed class Supplier
{
    public long Id { get; set; }
    public required string Name { get; set; }
    public bool Active { get; set; } = true;
    public ICollection<SupplierOffer> Offers { get; } = new List<SupplierOffer>();
    public ICollection<ImportBatch> ImportBatches { get; } = new List<ImportBatch>();
}

public sealed class SupplierOffer
{
    public long Id { get; set; }
    public long SupplierId { get; set; }
    public Supplier? Supplier { get; set; }
    public long ProductId { get; set; }
    public Product? Product { get; set; }
    public required string SupplierSku { get; set; }
    public required string Currency { get; set; }
    public string? SourceUrl { get; set; }
    public ICollection<PriceObservation> Observations { get; } = new List<PriceObservation>();
}

public sealed class ImportBatch
{
    public long Id { get; set; }
    public long SupplierId { get; set; }
    public Supplier? Supplier { get; set; }
    public required string SourceFile { get; set; }
    public DateTimeOffset StartedAt { get; set; }
    public required string Status { get; set; }
    public ICollection<PriceObservation> Observations { get; } = new List<PriceObservation>();
}

public sealed class PriceObservation
{
    public long Id { get; set; }
    public long OfferId { get; set; }
    public SupplierOffer? Offer { get; set; }
    public long SupplierId { get; set; }
    public long BatchId { get; set; }
    public ImportBatch? Batch { get; set; }
    public DateTimeOffset ObservedAt { get; set; }
    public decimal Price { get; set; }
    public bool Available { get; set; }
}
