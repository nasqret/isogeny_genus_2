#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 "$ROOT/scripts/generate-claim-index.py"
"$ROOT/scripts/generate-article-copy.sh"
jupyter-book clean --all "$ROOT/book"
jupyter-book build --all "$ROOT/book"
python3 "$ROOT/scripts/sanitize-book-html.py"
