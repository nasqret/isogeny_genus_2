#!/usr/bin/env python3
import json
from collections import Counter
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_json(relative_path):
    return json.loads((ROOT / relative_path).read_text(encoding="utf-8"))


claims = load_json("research/data/claims.json")
environments = load_json("research/data/environments.json")
remote_jobs = load_json("research/data/remote_jobs.json")
recent_results = load_json("research/data/recent_results.json")
beyond_paper = load_json("research/data/beyond_paper.json")

computational_claims = [
    claim for claim in claims if claim["category"] != "completeness"
]
counts = Counter(claim["status"] for claim in claims)
overall_progress = round(
    sum(claim["progress"] for claim in computational_claims)
    / len(computational_claims)
)
ready_count = sum(item["status"] == "ready" for item in environments)
setup_readiness = round(100 * ready_count / len(environments))

payload = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "summary": {
        "total": len(claims),
        "computational_total": len(computational_claims),
        "counts": dict(counts),
        "overall_progress": overall_progress,
        "setup_readiness": setup_readiness,
    },
    "current_efforts": [
        claim for claim in claims if claim["status"] == "in_progress"
    ],
    "environments": environments,
    "remote_jobs": remote_jobs,
    "recent_results": recent_results,
    "claims": claims,
    "beyond_paper": beyond_paper,
    "beyond_summary": {
        "total": len(beyond_paper),
        "completed": sum(item["status"] == "completed" for item in beyond_paper),
        "in_progress": sum(
            item["status"] == "in_progress" for item in beyond_paper
        ),
        "planned": sum(item["status"] == "planned" for item in beyond_paper),
        "overall_progress": round(
            sum(item["progress"] for item in beyond_paper) / len(beyond_paper)
        ),
    },
}

(ROOT / "dashboard/status.json").write_text(
    json.dumps(payload, indent=2) + "\n", encoding="utf-8"
)
print(
    json.dumps(
        {
            "claims": len(claims),
            "formal_verification": overall_progress,
            "setup_readiness": setup_readiness,
        }
    )
)
