# Diagram and database tools

## Used in this example

- **Mermaid**: the editable ER source in `erd.md`; GitHub renders it without a separate service.
- **Python + CairoSVG**: `tools/render_er.py` produces the SVG and PNG image versions from a declared node/relationship model.
- **SQL Server / sqlcmd**: the target database and command-line runner for T-SQL scripts. This machine has the tools installed, but its SQL Server instance currently rejects Windows-authenticated connections, so the scripts have not been executed successfully here.
- **.NET SDK**: builds the C# entity model.

Regenerate the images:

```powershell
python tools/render_er.py
```

For an existing SQL Server database, **SQL Server Management Studio (SSMS)** is convenient for table design, query plans and data checks. **DBeaver** can inspect the schema across database engines. **dbdiagram.io** is useful for quick conceptual diagrams. These GUI tools are options for later design work, not tools claimed as used to generate this sample.
