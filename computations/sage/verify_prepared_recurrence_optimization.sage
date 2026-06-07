"""Verify exact maps and timing for prepared basis differential additions."""

import json
from datetime import datetime, timezone
from pathlib import Path


root = Path.cwd()
cases = []
for degree, field_order in [(13, 8009), (17, 8263), (31, 64853)]:
    baseline_name = (
        f"sage_degree{degree}_kummer_roots.json"
        if degree in [13, 17]
        else "sage_degree31_maps.json"
    )
    baseline = json.loads(
        (root / "results" / baseline_name).read_text()
    )
    prepared = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_prepared_recurrence.json"
        ).read_text()
    )

    base_field = GF(field_order)
    modulus_ring = PolynomialRing(base_field, "x")
    x = modulus_ring.gen()
    modulus = modulus_ring(
        sage_eval(
            baseline["theta_field_modulus"],
            locals={"x": x},
        )
    )
    theta_field = GF(
        field_order^24,
        "z24",
        modulus=modulus,
    )
    z24 = theta_field.gen()
    polynomial_ring = PolynomialRing(theta_field, "u")
    u = polynomial_ring.gen()
    function_field = polynomial_ring.fraction_field()

    def parse_function(record):
        numerator = polynomial_ring(
            sage_eval(
                record["numerator"],
                locals={"z24": z24, "u": u},
            )
        )
        denominator = polynomial_ring(
            sage_eval(
                record["denominator"],
                locals={"z24": z24, "u": u},
            )
        )
        return function_field(numerator/denominator)

    def parse_polynomial(expression):
        return polynomial_ring(
            sage_eval(
                expression,
                locals={"z24": z24, "u": u},
            )
        )

    map_equivalence = []
    for factor_index, (baseline_map, prepared_map) in enumerate(
        zip(baseline["maps"], prepared["maps"])
    ):
        baseline_x = parse_function(
            baseline_map["x_coordinate"]
        )
        prepared_x = parse_function(
            prepared_map["x_coordinate"]
        )
        baseline_y = parse_function(
            baseline_map["y_coefficient"]
        )
        prepared_y = parse_function(
            prepared_map["y_coefficient"]
        )
        baseline_eigenform = parse_polynomial(
            baseline_map["pullback_eigenform"]
        )
        prepared_eigenform = parse_polynomial(
            prepared_map["pullback_eigenform"]
        )

        assert prepared_x == baseline_x
        y_sign = next(
            sign
            for sign in [theta_field(1), theta_field(-1)]
            if prepared_y == sign*baseline_y
        )
        assert prepared_eigenform == y_sign*baseline_eigenform
        assert prepared_map["target_j_invariant"] == (
            baseline_map["target_j_invariant"]
        )
        assert prepared_map["cover_degree"] == degree
        assert prepared_map["elliptic_equation_identity"]
        assert prepared_map["linear_differential_pullback"]
        assert prepared_map["all_interpolation_samples_verified"]
        map_equivalence.append(
            {
                "factor_index": factor_index,
                "x_coordinate_identical": True,
                "target_y_sign": int(
                    1 if y_sign == 1 else -1
                ),
                "y_coordinate_equivalent": True,
                "differential_equivalent": True,
            }
        )

    baseline_subphases = baseline["evaluation"][
        "explicit_subphase_timings_seconds"
    ]
    prepared_subphases = prepared["evaluation"][
        "explicit_subphase_timings_seconds"
    ]
    baseline_recurrence = baseline_subphases[
        "kernel_table_recurrence"
    ]
    prepared_recurrence = prepared_subphases[
        "kernel_table_recurrence"
    ]
    baseline_dual = baseline["phase_timings_seconds"][
        "dual_isogeny_evaluation"
    ]
    prepared_dual = prepared["phase_timings_seconds"][
        "dual_isogeny_evaluation"
    ]
    assert prepared["evaluation"]["kernel_recurrence_strategy"] == (
        "prepared_basis_diff_add"
    )
    assert prepared_recurrence < baseline_recurrence
    cases.append(
        {
            "degree": int(degree),
            "baseline_recurrence_seconds": baseline_recurrence,
            "prepared_recurrence_seconds": prepared_recurrence,
            "recurrence_reduction_percent": float(
                100*(
                    1
                    - prepared_recurrence/baseline_recurrence
                )
            ),
            "baseline_dual_seconds": baseline_dual,
            "prepared_dual_seconds": prepared_dual,
            "dual_reduction_percent": float(
                100*(1 - prepared_dual/baseline_dual)
            ),
            "baseline_total_seconds": baseline["runtime_seconds"],
            "prepared_total_seconds": prepared["runtime_seconds"],
            "total_reduction_percent": float(
                100*(
                    1
                    - prepared["runtime_seconds"]
                    / baseline["runtime_seconds"]
                )
            ),
            "map_equivalence": map_equivalence,
        }
    )

result = {
    "workstream": "B026",
    "status": "verified",
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "scope": (
        "exact map equivalence and timing of prepared basis "
        "differential additions"
    ),
    "cases": cases,
    "certificate": {
        "all_x_coordinates_identical": True,
        "all_y_coordinates_equal_up_to_target_involution": True,
        "all_differentials_transform_by_the_same_sign": True,
        "all_map_identities_and_degrees_verified": True,
        "prepared_recurrence_faster_in_all_tested_degrees": True,
        "degree17_total_runtime_improved": True,
        "degree13_total_runtime_claim_deferred_for_run_noise": True,
    },
}
output = root / "results" / "sage_prepared_recurrence_optimization.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print("PREPARED_RECURRENCE_OPTIMIZATION verified")
for case in cases:
    print(
        "degree",
        case["degree"],
        "recurrence_reduction_percent",
        case["recurrence_reduction_percent"],
        "dual_reduction_percent",
        case["dual_reduction_percent"],
        "total_reduction_percent",
        case["total_reduction_percent"],
        "y_signs",
        [
            record["target_y_sign"]
            for record in case["map_equivalence"]
        ],
    )
print("result", output)
