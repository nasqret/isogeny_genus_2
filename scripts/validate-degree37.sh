#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAGE_HOME="${SAGE_HOME:-/tmp/sagehome}"

json_results=(
  results/sage_degree37_anti_isometry.json
  results/sage_degree37_theta.json
  results/sage_degree37_maps.json
  results/sage_degree37_descended_maps.json
  results/magma_degree37_anti_isometry.json
  results/magma_degree37_curve.json
  results/magma_degree37_maps.json
  results/prime_degree_scaling.json
  results/sage_prime_degree_descent_cocycles.json
)

for result in "${json_results[@]}"; do
  python3 -m json.tool "$ROOT/$result" >/dev/null
done

rg -q "B027_DEGREE37_ANTI_ISOMETRY_VERIFIED" \
  "$ROOT/results/remote/magma_degree37_anti_isometry.log"
rg -q "B027_DEGREE37_CURVE_RECONSTRUCTED" \
  "$ROOT/results/remote/magma_degree37_curve.log"
rg -q "B027_DEGREE37_MAPS_MAGMA_VERIFIED" \
  "$ROOT/results/remote/magma_degree37_maps.log"

HOME="$SAGE_HOME" sage \
  "$ROOT/computations/sage/verify_prime_degree_descent_cocycles.sage" \
  >/dev/null
python3 "$ROOT/computations/sage/compare_prime_degree_scaling.py" >/dev/null

if [[ "${FULL_RECOMPUTE:-0}" == "1" ]]; then
  HOME="$SAGE_HOME" sage \
    "$ROOT/computations/sage/verify_degree37_anti_isometry.sage" \
    >/dev/null
  HOME="$SAGE_HOME" sage \
    "$ROOT/computations/sage/reconstruct_degree37_theta.sage" \
    >/dev/null
  HOME="$SAGE_HOME" sage \
    "$ROOT/computations/sage/recover_degree37_maps.sage" \
    >/dev/null
  HOME="$SAGE_HOME" sage \
    "$ROOT/computations/sage/descend_degree37_maps.sage" \
    >/dev/null
fi

printf 'DEGREE37_VALIDATION_OK\n'
