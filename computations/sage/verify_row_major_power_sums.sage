"""Verify exact maps and timing for row-major theta power sums."""

import json
from datetime import datetime, timezone
from pathlib import Path


root = Path.cwd()
cases = []
for degree, field_order in [(13, 8009), (17, 8263), (31, 64853)]:
    baseline = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_prepared_recurrence.json"
        ).read_text()
    )
    optimized_name = (
        f"sage_degree{degree}_row_major_power_sums.json"
        if degree in [13, 17]
        else "sage_degree31_optimized_recovery.json"
    )
    optimized = json.loads(
        (
            root
            / "results"
            / optimized_name
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
    for factor_index, (baseline_map, optimized_map) in enumerate(
        zip(baseline["maps"], optimized["maps"])
    ):
        baseline_x = parse_function(
            baseline_map["x_coordinate"]
        )
        optimized_x = parse_function(
            optimized_map["x_coordinate"]
        )
        baseline_y = parse_function(
            baseline_map["y_coefficient"]
        )
        optimized_y = parse_function(
            optimized_map["y_coefficient"]
        )
        baseline_eigenform = parse_polynomial(
            baseline_map["pullback_eigenform"]
        )
        optimized_eigenform = parse_polynomial(
            optimized_map["pullback_eigenform"]
        )

        assert optimized_x == baseline_x
        y_sign = next(
            sign
            for sign in [theta_field(1), theta_field(-1)]
            if optimized_y == sign*baseline_y
        )
        assert optimized_eigenform == y_sign*baseline_eigenform
        assert optimized_map["target_j_invariant"] == (
            baseline_map["target_j_invariant"]
        )
        assert optimized_map["cover_degree"] == degree
        assert optimized_map["elliptic_equation_identity"]
        assert optimized_map["linear_differential_pullback"]
        assert optimized_map["all_interpolation_samples_verified"]
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

    baseline_seconds = baseline["evaluation"][
        "explicit_subphase_timings_seconds"
    ]["theta_power_sums"]
    optimized_seconds = optimized["evaluation"][
        "explicit_subphase_timings_seconds"
    ]["theta_power_sums"]
    assert optimized["evaluation"]["theta_power_sum_strategy"] == (
        "row_major"
    )
    assert optimized_seconds < baseline_seconds
    cases.append(
        {
            "degree": int(degree),
            "baseline_power_sum_seconds": baseline_seconds,
            "row_major_power_sum_seconds": optimized_seconds,
            "power_sum_reduction_percent": float(
                100*(1 - optimized_seconds/baseline_seconds)
            ),
            "map_equivalence": map_equivalence,
        }
    )

result = {
    "workstream": "B026",
    "status": "verified",
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "scope": (
        "exact map equivalence and isolated timing of row-major "
        "theta power sums"
    ),
    "cases": cases,
    "certificate": {
        "all_x_coordinates_identical": True,
        "all_y_coordinates_equal_up_to_target_involution": True,
        "all_differentials_transform_by_the_same_sign": True,
        "all_map_identities_and_degrees_verified": True,
        "row_major_power_sums_faster_in_all_tested_degrees": True,
    },
}
output = root / "results" / "sage_row_major_power_sums.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print("ROW_MAJOR_POWER_SUMS verified")
for case in cases:
    print(
        "degree",
        case["degree"],
        "power_sum_reduction_percent",
        case["power_sum_reduction_percent"],
        "y_signs",
        [
            record["target_y_sign"]
            for record in case["map_equivalence"]
        ],
    )
print("result", output)
