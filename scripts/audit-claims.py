#!/usr/bin/env python3
"""Strict final audit of the computational claim ledger."""

from __future__ import annotations

import json
import re
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CLAIMS_PATH = ROOT / "research" / "data" / "claims.json"
RESULT_PATH = ROOT / "results" / "claim_audit.json"
TERMINAL_STATUSES = {"verified", "disproved"}
RANGE_RE = re.compile(r"^(\d+)-(\d+)$")


def fail(message: str) -> None:
    raise SystemExit(f"CLAIM_AUDIT_FAILED: {message}")


claims = json.loads(CLAIMS_PATH.read_text())
if not isinstance(claims, list):
    fail("claims.json must contain a top-level array")

expected_ids = [f"C{number:03d}" for number in range(1, 41)]
actual_ids = [claim.get("id") for claim in claims]
if actual_ids != expected_ids:
    fail(f"expected ordered IDs C001-C040, found {actual_ids}")

checked_artifacts: set[str] = set()
checked_sources: set[str] = set()
source_ranges: dict[str, list[tuple[int, int, str]]] = {}

for claim in claims:
    claim_id = claim["id"]
    status = claim.get("status")
    if status not in TERMINAL_STATUSES:
        fail(f"{claim_id} has nonterminal status {status!r}")
    if claim.get("progress") != 100:
        fail(f"{claim_id} does not have progress 100")
    if not claim.get("notes"):
        fail(f"{claim_id} has no notes")
    if not claim.get("result_note") and status == "disproved":
        fail(f"{claim_id} is disproved but has no result_note")

    source = claim.get("source")
    if not source:
        fail(f"{claim_id} has no source")
    source_path = ROOT / source
    if not source_path.is_file():
        fail(f"{claim_id} source does not exist: {source}")
    checked_sources.add(source)
    line_count = sum(1 for _ in source_path.open())

    ranges = []
    for item in claim.get("lines", "").split(","):
        match = RANGE_RE.match(item.strip())
        if not match:
            fail(f"{claim_id} has malformed source range {item!r}")
        start, end = map(int, match.groups())
        if start < 1 or end < start or end > line_count:
            fail(
                f"{claim_id} range {start}-{end} is outside "
                f"{source} (1-{line_count})"
            )
        ranges.append((start, end, claim_id))
    source_ranges.setdefault(source, []).extend(ranges)

    artifacts = claim.get("artifacts")
    if not artifacts:
        fail(f"{claim_id} has no artifacts")
    for artifact in artifacts:
        artifact_path = ROOT / artifact
        # This audit creates its own result after all other checks pass.
        if artifact_path != RESULT_PATH and not artifact_path.exists():
            fail(f"{claim_id} artifact does not exist: {artifact}")
        checked_artifacts.add(artifact)
        if artifact_path.suffix == ".json" and artifact_path.exists():
            try:
                json.loads(artifact_path.read_text())
            except json.JSONDecodeError as exc:
                fail(f"{claim_id} artifact is invalid JSON: {artifact}: {exc}")

status_counts = {
    status: sum(claim["status"] == status for claim in claims)
    for status in sorted(TERMINAL_STATUSES)
}

output = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "claim_count": len(claims),
    "expected_id_range": "C001-C040",
    "all_claims_terminal": True,
    "status_counts": status_counts,
    "source_files_checked": sorted(checked_sources),
    "artifact_count": len(checked_artifacts),
    "all_artifacts_present": True,
    "all_json_artifacts_valid": True,
    "all_source_ranges_valid": True,
    "disproved_claims": [
        claim["id"] for claim in claims if claim["status"] == "disproved"
    ],
    "verified": True,
}
RESULT_PATH.write_text(json.dumps(output, indent=2) + "\n")
print(json.dumps(output, indent=2))
