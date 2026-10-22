"""Render the catalog ER model as shareable SVG and PNG images."""

from __future__ import annotations

from html import escape
from pathlib import Path

import cairosvg

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs"
WIDTH, HEIGHT = 1900, 1100
CARD_WIDTH = 460
CARD_HEIGHT = 310

# Keep names and SQL Server types in sync with docs/erd.md and sql/001_schema.sql.
ENTITIES = [
    ("CATEGORY", 80, 170, [
        ("id", "BIGINT", "PK"),
        ("name", "NVARCHAR(120)", "UQ"),
    ]),
    ("PRODUCT", 720, 170, [
        ("id", "BIGINT", "PK"),
        ("sku", "NVARCHAR(80)", "UQ"),
        ("name", "NVARCHAR(240)", ""),
        ("brand", "NVARCHAR(120)", ""),
        ("category_id", "BIGINT", "FK"),
    ]),
    ("SUPPLIER_OFFER", 1360, 170, [
        ("id", "BIGINT", "PK"),
        ("supplier_id", "BIGINT", "FK"),
        ("product_id", "BIGINT", "FK"),
        ("supplier_sku", "NVARCHAR(100)", "UQ*"),
        ("currency", "VARCHAR(3)", ""),
    ]),
    ("SUPPLIER", 80, 690, [
        ("id", "BIGINT", "PK"),
        ("name", "NVARCHAR(160)", "UQ"),
        ("active", "BIT", ""),
    ]),
    ("IMPORT_BATCH", 720, 690, [
        ("id", "BIGINT", "PK"),
        ("supplier_id", "BIGINT", "FK"),
        ("source_file", "NVARCHAR(260)", ""),
        ("started_at", "DATETIMEOFFSET", ""),
        ("status", "NVARCHAR(16)", ""),
    ]),
    ("PRICE_OBSERVATION", 1360, 690, [
        ("id", "BIGINT", "PK"),
        ("offer_id", "BIGINT", "FK"),
        ("supplier_id", "BIGINT", "FK"),
        ("batch_id", "BIGINT", "FK"),
        ("observed_at", "DATETIMEOFFSET", ""),
        ("price", "DECIMAL(14,2)", ""),
        ("available", "BIT", ""),
    ]),
]

svg: list[str] = []


def add(fragment: str) -> None:
    svg.append(fragment)


def text(x: int, y: int, value: str, cls: str, anchor: str = "start") -> None:
    add(
        f'<text x="{x}" y="{y}" class="{cls}" text-anchor="{anchor}">'
        f"{escape(value)}</text>"
    )


add(
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" '
    f'viewBox="0 0 {WIDTH} {HEIGHT}">'
)
add(
    "<style>"
    ".title{font:700 52px Arial,sans-serif;fill:#102858}"
    ".subtitle{font:24px Arial,sans-serif;fill:#526685}"
    ".entity{font:700 27px Arial,sans-serif;fill:#fff}"
    ".field{font:23px Arial,sans-serif;fill:#122c52}"
    ".type{font:21px Arial,sans-serif;fill:#536a8e}"
    ".badge{font:700 17px Arial,sans-serif;fill:#1255d8}"
    ".rel{font:700 19px Arial,sans-serif;fill:#40577c}"
    ".footer{font:20px Arial,sans-serif;fill:#526685}"
    "</style>"
)
add('<rect width="1900" height="1100" fill="#f3f7ff"/>')
add('<rect x="0" y="0" width="1900" height="12" fill="#155df5"/>')
text(80, 83, "Catalog data model", "title")
text(80, 125, "Microsoft SQL Server  ·  six entities  ·  supplier prices with history", "subtitle")

# Relationships are placed behind the entity cards.
relations = [
    ("M540 310 H720", 630, 298, "1 : many"),
    ("M1180 310 H1360", 1270, 298, "1 : many"),
    ("M540 845 H720", 630, 833, "1 : many"),
    ("M1180 845 H1360", 1270, 833, "1 : many"),
    ("M1590 480 V690", 1660, 595, "1 : many"),
    ("M540 755 H610 V570 H1280 V385 H1360", 940, 556, "1 : many"),
]
for path, lx, ly, label in relations:
    add(
        f'<path d="{path}" fill="none" stroke="#7498da" '
        'stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>'
    )
    add(
        f'<rect x="{lx - 54}" y="{ly - 24}" width="108" height="31" rx="15" '
        'fill="#fff" stroke="#d7e4fb"/>'
    )
    text(lx, ly - 3, label, "rel", "middle")

for name, x, y, fields in ENTITIES:
    add(
        f'<rect x="{x}" y="{y}" width="{CARD_WIDTH}" height="{CARD_HEIGHT}" '
        'rx="26" fill="#fff" stroke="#d4e2fb" stroke-width="2"/>'
    )
    add(
        f'<path d="M{x + 26} {y} H{x + CARD_WIDTH - 26} '
        f'Q{x + CARD_WIDTH} {y} {x + CARD_WIDTH} {y + 26} '
        f'V{y + 68} H{x} V{y + 26} Q{x} {y} {x + 26} {y}" '
        'fill="#155df5"/>'
    )
    text(x + 25, y + 43, name, "entity")
    for index, (field, kind, marker) in enumerate(fields):
        line_y = y + 104 + index * 32
        if marker:
            badge_x = x + 24
            add(
                f'<rect x="{badge_x}" y="{line_y - 22}" width="42" height="27" '
                'rx="8" fill="#e9f0ff"/>'
            )
            text(badge_x + 21, line_y - 3, marker, "badge", "middle")
        text(x + 79, line_y, field, "field")
        text(x + CARD_WIDTH - 24, line_y, kind, "type", "end")

text(
    80,
    1054,
    "PK = primary key   ·   FK = foreign key   ·   UQ = unique   ·   UQ* = unique within supplier",
    "footer",
)
text(
    1820,
    1054,
    "Synthetic portfolio example",
    "footer",
    "end",
)
add("</svg>")

OUT.mkdir(parents=True, exist_ok=True)
source = "\n".join(svg)
(OUT / "er-diagram.svg").write_text(source, encoding="utf-8")
cairosvg.svg2png(bytestring=source.encode("utf-8"), write_to=str(OUT / "er-diagram.png"))
print(f"Rendered {OUT / 'er-diagram.svg'} and {OUT / 'er-diagram.png'}")
