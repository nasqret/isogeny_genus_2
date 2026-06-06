#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HTML_ROOT = ROOT / "book" / "_build" / "html"
MARKERS = (
    "const THEBE_JS_URL =",
    "var togglebuttonSelector =",
)

changed_files = 0
removed_lines = 0

for path in HTML_ROOT.rglob("*.html"):
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    seen = set()
    output = []
    changed = False

    for line in lines:
        marker = next((value for value in MARKERS if value in line), None)
        if marker is not None:
            if marker in seen:
                removed_lines += 1
                changed = True
                continue
            seen.add(marker)
        output.append(line)

    if changed:
        path.write_text("".join(output), encoding="utf-8")
        changed_files += 1

for path in HTML_ROOT.rglob("*.html"):
    text = path.read_text(encoding="utf-8")
    for marker in MARKERS:
        if text.count(marker) > 1:
            raise RuntimeError(f"Duplicate generated declaration remains in {path}: {marker}")

print(
    f"Sanitized {changed_files} HTML files; "
    f"removed {removed_lines} duplicate declarations."
)
