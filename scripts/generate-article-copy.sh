#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP="$ROOT/book/paper/.original_article.body.md"
SANITIZED="$ROOT/book/paper/.original_article.sanitized.md"

pandoc "$ROOT/sources/paper.tex" \
  --from=latex \
  --to=markdown \
  --bibliography="$ROOT/sources/bibliography.bib" \
  --output="$TEMP"

python3 "$ROOT/scripts/sanitize-article-markdown.py" "$TEMP" "$SANITIZED"

{
  cat <<'EOF'
# Finding the complement of an elliptic curve inside a Jacobian

Andrea Gallese, Davide Lombardo, Francesco Naccarato, and Umberto Zannier

:::{note}
This text-friendly copy was generated from the exact arXiv TeX source archived
in `sources/paper.tex`. The original PDF is available at
`sources/arxiv-2606.02429.pdf`. Computation links are added from the project
claim ledger and do not modify the archived source.
:::

EOF
  cat "$ROOT/reconstruction/ARTICLE_EVIDENCE_TABLE.md"
  cat <<'EOF'

## Abstract

This note gives a simple algorithm for the following effectivity problem:
given a genus 2 curve \(X\) together with a nonconstant map
\(\pi:X\to E\) to an elliptic curve, determine an elliptic curve \(E'\) and
a map \(\pi':X\to E'\) independent of \(\pi\). Equivalently, the paper
computes the complementary elliptic factor in the decomposition of
\(\operatorname{Jac}(X)\) up to isogeny.

EOF
  cat "$SANITIZED"
} > "$ROOT/book/paper/original_article.md"

rm -f "$TEMP" "$SANITIZED"
