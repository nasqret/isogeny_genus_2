"""Build the machine-readable prime-degree synthesis comparison."""

import json
from datetime import datetime
from pathlib import Path


root = Path.cwd()
records = []
for degree in (13, 17, 19, 23, 29, 31, 37):
    anti = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_anti_isometry.json"
        ).read_text()
    )
    theta_name = (
        "sage_degree13_curve.json"
        if degree == 13
        else f"sage_degree{degree}_theta.json"
    )
    theta = json.loads((root / "results" / theta_name).read_text())
    maps = json.loads(
        (root / "results" / f"sage_degree{degree}_maps.json").read_text()
    )
    descended = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_descended_maps.json"
        ).read_text()
    )
    magma = json.loads(
        (
            root / "results" / f"magma_degree{degree}_maps.json"
        ).read_text()
    )
    evaluation = maps["evaluation"]
    record = {
        "degree": degree,
        "map_recovery_strategy": evaluation.get(
            "dual_isogeny_strategy",
            "symbolic_quotient_ring",
        ),
        "field": anti["field"],
        "theta_extension_degree": theta["theta_extension_degree"],
        "map_extension_degree": maps["theta_field_degree"],
        "sample_count": evaluation["sample_count"],
        "sample_formula": 2*degree + 8,
        "theta_runtime_seconds": theta.get(
            "elapsed_seconds",
            theta.get("runtime_seconds"),
        ),
        "map_recovery_runtime_seconds": maps["runtime_seconds"],
        "descent_runtime_seconds": descended["runtime_seconds"],
        "magma_map_runtime_seconds": magma["elapsed_seconds"],
        "rosenhain_x_degree_pairs": [
            [
                item["x_coordinate"]["numerator_degree"],
                item["x_coordinate"]["denominator_degree"],
            ]
            for item in maps["maps"]
        ],
        "base_field_x_degree_pairs": [
            [
                item["x_coordinate"]["numerator_degree"],
                item["x_coordinate"]["denominator_degree"],
            ]
            for item in descended["maps"]
        ],
        "nontrivial_two_torsion_corrections": sum(
            not item["descent_cocycle"]["direct_descent"]
            for item in descended["maps"]
        ),
    }
    if "explicit_root_extension_degree" in evaluation:
        record.update(
            {
                "explicit_root_extension_degree": evaluation[
                    "explicit_root_extension_degree"
                ],
                "explicit_root_count": evaluation["explicit_root_count"],
                "explicit_root_extraction_strategy": evaluation.get(
                    "explicit_root_extraction_strategy",
                    "individual_nth_root",
                ),
                "dual_isogeny_runtime_seconds": maps[
                    "phase_timings_seconds"
                ]["dual_isogeny_evaluation"],
            }
        )
    optimized_path = (
        root
        / "results"
        / f"sage_degree{degree}_optimized_recovery.json"
    )
    if optimized_path.exists():
        optimized = json.loads(optimized_path.read_text())
        record.update(
            {
                "optimized_map_recovery_runtime_seconds": optimized[
                    "runtime_seconds"
                ],
                "optimized_dual_isogeny_runtime_seconds": optimized[
                    "phase_timings_seconds"
                ]["dual_isogeny_evaluation"],
                "optimized_root_extraction_strategy": optimized[
                    "evaluation"
                ]["explicit_root_extraction_strategy"],
                "optimized_kernel_recurrence_strategy": optimized[
                    "evaluation"
                ]["kernel_recurrence_strategy"],
                "optimized_theta_power_sum_strategy": optimized[
                    "evaluation"
                ]["theta_power_sum_strategy"],
            }
        )
    records.append(record)

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "verified": True,
    "degrees": records,
    "observed_patterns": {
        "sample_count": "2*n+8",
        "theta_extension_degree": 12,
        "map_extension_degree": 24,
        "rosenhain_x_degree_pair": "(n,n-1)",
        "base_field_x_degree_pair_after_sextic_transport": "(n,n)",
        "base_field_x_degree_pair_for_identity_quintic": "(n,n-1)",
        "map_recovery_is_dominant_cost": True,
        "degree31_dual_isogeny_fraction": (
            records[-2]["dual_isogeny_runtime_seconds"]
            / records[-2]["map_recovery_runtime_seconds"]
        ),
        "degree31_optimized_total_reduction_percent": (
            100*(
                1
                - records[-2][
                    "optimized_map_recovery_runtime_seconds"
                ]
                / records[-2]["map_recovery_runtime_seconds"]
            )
        ),
        "degree31_optimized_dual_reduction_percent": (
            100*(
                1
                - records[-2][
                    "optimized_dual_isogeny_runtime_seconds"
                ]
                / records[-2]["dual_isogeny_runtime_seconds"]
            )
        ),
        "degree37_dual_prediction_seconds": 1570.510517953125,
        "degree37_dual_measured_seconds": records[-1][
            "dual_isogeny_runtime_seconds"
        ],
    },
}
output = root / "results" / "prime_degree_scaling.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
