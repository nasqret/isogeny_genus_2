#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAGE_HOME="${SAGE_HOME:-/tmp/sagehome}"

mkdir -p "$SAGE_HOME"

run_sage() {
  printf 'Validating %s\n' "$1"
  HOME="$SAGE_HOME" sage "$ROOT/$1" >/dev/null
}

run_sage computations/sage/verify_degree5_family_structure.sage
run_sage computations/sage/census_degree5_family.sage
run_sage computations/sage/verify_degree7_kumar_specialization.sage
run_sage computations/sage/test_general_elliptic_cover_recovery.sage
run_sage computations/sage/recover_degree7_maps.sage
run_sage computations/sage/verify_degree7_maps.sage
run_sage computations/sage/verify_composed_high_degree_maps.sage

python3 -m json.tool "$ROOT/results/sage_degree5_family_structure.json" >/dev/null
python3 -m json.tool "$ROOT/results/sage_degree5_family_census.json" >/dev/null
python3 -m json.tool "$ROOT/results/sage_degree7_kumar_specialization.json" >/dev/null
python3 -m json.tool "$ROOT/results/sage_general_map_recovery.json" >/dev/null
python3 -m json.tool "$ROOT/results/sage_degree7_recovery.json" >/dev/null
python3 -m json.tool "$ROOT/results/sage_degree7_maps.json" >/dev/null
python3 -m json.tool "$ROOT/results/sage_composed_high_degree_maps.json" >/dev/null

printf 'BEYOND_PAPER_VALIDATION_OK\n'
