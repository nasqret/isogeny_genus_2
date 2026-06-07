#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SAGE_HOME="${SAGE_HOME:-/tmp/sagehome}"

json_results=(
  results/sage_degree13_prepared_recurrence.json
  results/sage_degree17_prepared_recurrence.json
  results/sage_degree31_prepared_recurrence.json
  results/sage_prepared_recurrence_optimization.json
  results/sage_degree13_row_major_power_sums.json
  results/sage_degree17_row_major_power_sums.json
  results/sage_degree31_optimized_recovery.json
  results/sage_row_major_power_sums.json
  results/prime_degree_scaling.json
)

for result in "${json_results[@]}"; do
  python3 -m json.tool "$ROOT/$result" >/dev/null
done

HOME="$SAGE_HOME" sage \
  "$ROOT/computations/sage/verify_prepared_recurrence_optimization.sage" \
  >/dev/null
HOME="$SAGE_HOME" sage \
  "$ROOT/computations/sage/verify_row_major_power_sums.sage" \
  >/dev/null
python3 "$ROOT/computations/sage/compare_prime_degree_scaling.py" >/dev/null

printf 'B026_VALIDATION_OK\n'
