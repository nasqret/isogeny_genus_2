#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$ROOT/scripts/generate-article-copy.sh"
python3 "$ROOT/scripts/generate-claim-index.py"
jupyter-book clean --all "$ROOT/book"
jupyter-book build --all "$ROOT/book"
