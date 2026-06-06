#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m json.tool "$ROOT/research/data/claims.json" >/dev/null
python3 -m json.tool "$ROOT/research/data/environments.json" >/dev/null
python3 "$ROOT/scripts/update-dashboard.py"
python3 "$ROOT/scripts/generate-claim-index.py"
"$ROOT/scripts/build-book.sh"
git -C "$ROOT" diff --check
