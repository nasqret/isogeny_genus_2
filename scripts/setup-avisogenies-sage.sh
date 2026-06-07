#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${AVISOGENIES_SAGE:-$ROOT/.deps/avisogenies-sage}"
REPOSITORY="https://gitlab.inria.fr/roberdam/avisogenies.git"
COMMIT="e488a54304a5b5bcd0ae8c58d0ab82aeb02d6746"

mkdir -p "$(dirname "$TARGET")"

if [[ ! -d "$TARGET/.git" ]]; then
  git clone --branch sage "$REPOSITORY" "$TARGET"
fi

git -C "$TARGET" fetch origin "$COMMIT"
git -C "$TARGET" checkout --detach "$COMMIT"

actual="$(git -C "$TARGET" rev-parse HEAD)"
if [[ "$actual" != "$COMMIT" ]]; then
  printf 'Expected AVIsogenies %s, found %s\n' "$COMMIT" "$actual" >&2
  exit 1
fi

printf 'AVISOGENIES_SAGE_READY %s\n' "$actual"
