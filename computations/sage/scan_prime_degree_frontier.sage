"""Scan minimal arithmetic inputs for future prime-degree synthesis."""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
load(
    str(
        root
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_synthesis.sage"
    )
)

degrees = [ZZ(value) for value in sys.argv[1:]]
if not degrees:
    degrees = [ZZ(31), ZZ(37), ZZ(41)]
assert all(degree.is_prime() and degree > 2 for degree in degrees)

max_field_order = ZZ(
    os.environ.get("PRIME_FRONTIER_MAX_Q", "2000000")
)
degree29_samples = ZZ(66)
degree29_rows = degree29_samples + 1
degree29_cells = degree29_rows*ZZ(29)^2
degree29_dual_seconds = RR("1862.473316625008")


def first_arithmetic_candidate(degree):
    tested_prime_fields = 0
    for multiplier in range(1, max_field_order//degree + 1):
        field_order = ZZ(1 + degree*multiplier)
        if field_order > max_field_order or not field_order.is_prime():
            continue
        tested_prime_fields += 1
        traces = admissible_full_torsion_traces(degree, field_order)
        squareclasses = [
            ZZ(trace^2 - 4*field_order).squarefree_part()
            for trace in traces
        ]
        if (
            len(traces) >= 2
            and len(set(squareclasses)) >= 2
        ):
            samples = 2*degree + 8
            roots = 2*samples + 3
            kernel_rows = samples + 1
            kernel_cells = kernel_rows*degree^2
            cell_ratio = RR(kernel_cells)/RR(degree29_cells)
            extension_weighted_ratio = cell_ratio*RR(degree)/RR(29)
            return {
                "degree": int(degree),
                "field_order": int(field_order),
                "field": f"GF({field_order})",
                "tested_prime_fields_congruent_to_1": int(
                    tested_prime_fields
                ),
                "admissible_traces": [
                    int(value) for value in traces
                ],
                "cm_squareclasses": [
                    int(value) for value in squareclasses
                ],
                "distinct_cm_squareclasses": True,
                "sample_count": int(samples),
                "explicit_root_count": int(roots),
                "kernel_rows": int(kernel_rows),
                "kernel_table_cells": int(kernel_cells),
                "kernel_cell_ratio_to_degree29": float(cell_ratio),
                "extension_weighted_ratio_to_degree29": float(
                    extension_weighted_ratio
                ),
                "predicted_dual_isogeny_seconds": float(
                    degree29_dual_seconds*extension_weighted_ratio
                ),
            }
    raise RuntimeError(
        f"No candidate found for degree {degree} below "
        f"{max_field_order}."
    )


candidates = [first_arithmetic_candidate(degree) for degree in degrees]
selected = min(
    candidates,
    key=lambda item: (
        item["predicted_dual_isogeny_seconds"],
        item["field_order"],
    ),
)
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "workstream": "B025",
    "status": "verified",
    "scope": (
        "minimal arithmetic frontier for future odd-prime "
        "Frey-Kani synthesis"
    ),
    "search_bound": int(max_field_order),
    "degrees": [int(value) for value in degrees],
    "candidates": candidates,
    "selected_next_target": selected,
    "cost_model": {
        "baseline_degree": int(29),
        "baseline_dual_isogeny_seconds": float(degree29_dual_seconds),
        "baseline_kernel_table_cells": int(degree29_cells),
        "formula": (
            "degree29_seconds * cell_ratio * "
            "(candidate_degree/29)"
        ),
        "interpretation": (
            "heuristic planning estimate, not a runtime certificate"
        ),
    },
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
}
output = root / "results" / "sage_prime_degree_frontier.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
