#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPOSITORY_URL = "https://github.com/nasqret/isogeny_genus_2/blob/main"
claims = json.loads(
    (ROOT / "research/data/claims.json").read_text(encoding="utf-8")
)

lines = [
    "# Claim Evidence Index",
    "",
    "This table is generated from `research/data/claims.json`.",
    "",
    "| Claim | Computational statement | Source | Engine | Location | Status | Progress | Evidence |",
    "|---|---|---|---|---|---|---:|---|",
]

for claim in claims:
    evidence = "<br>".join(
        f"[{Path(path).name}]({REPOSITORY_URL}/{path})"
        for path in claim["artifacts"]
    ) or "pending"
    lines.append(
        f"| {claim['id']} | {claim['title']} | "
        f"[{claim['lines']}]({REPOSITORY_URL}/{claim['source']}) | "
        f"{claim['engine']} | "
        f"{claim['location']} | {claim['status']} | {claim['progress']}% | {evidence} |"
    )

(ROOT / "book/claims/index.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
(ROOT / "reconstruction/CLAIM_EVIDENCE_INDEX.md").write_text(
    "\n".join(lines) + "\n", encoding="utf-8"
)
print(f"Generated claim index for {len(claims)} claims.")
