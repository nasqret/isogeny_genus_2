"""Verify exact equivalence and speedups for Kummer-class roots."""

import json
from datetime import datetime, timezone
from pathlib import Path


root = Path.cwd()
cases = []
for degree, field_order in [(13, 8009), (17, 8263)]:
    individual = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_extension_roots.json"
        ).read_text()
    )
    kummer = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_kummer_roots.json"
        ).read_text()
    )

    base_field = GF(field_order)
    modulus_ring = PolynomialRing(base_field, "x")
    x = modulus_ring.gen()
    modulus = modulus_ring(
        sage_eval(
            individual["theta_field_modulus"],
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
    for factor_index, (individual_map, kummer_map) in enumerate(
        zip(individual["maps"], kummer["maps"])
    ):
        individual_x = parse_function(
            individual_map["x_coordinate"]
        )
        kummer_x = parse_function(kummer_map["x_coordinate"])
        individual_y = parse_function(
            individual_map["y_coefficient"]
        )
        kummer_y = parse_function(kummer_map["y_coefficient"])
        individual_eigenform = parse_polynomial(
            individual_map["pullback_eigenform"]
        )
        kummer_eigenform = parse_polynomial(
            kummer_map["pullback_eigenform"]
        )

        assert individual_x == kummer_x
        y_sign = next(
            sign
            for sign in [theta_field(1), theta_field(-1)]
            if kummer_y == sign*individual_y
        )
        assert kummer_eigenform == y_sign*individual_eigenform
        assert individual_map["target_j_invariant"] == (
            kummer_map["target_j_invariant"]
        )
        assert kummer_map["cover_degree"] == degree
        assert kummer_map["elliptic_equation_identity"]
        assert kummer_map["linear_differential_pullback"]
        assert kummer_map["all_interpolation_samples_verified"]
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

    individual_total = individual["runtime_seconds"]
    kummer_total = kummer["runtime_seconds"]
    individual_dual = individual["phase_timings_seconds"][
        "dual_isogeny_evaluation"
    ]
    kummer_dual = kummer["phase_timings_seconds"][
        "dual_isogeny_evaluation"
    ]
    assert kummer["evaluation"][
        "explicit_root_extraction_strategy"
    ] == "kummer_class"
    assert (
        individual["evaluation"]["explicit_root_count"]
        == kummer["evaluation"]["explicit_root_count"]
    )
    cases.append(
        {
            "degree": int(degree),
            "root_count": kummer["evaluation"][
                "explicit_root_count"
            ],
            "individual_runtime_seconds": individual_total,
            "kummer_runtime_seconds": kummer_total,
            "runtime_reduction_percent": (
                100*(1 - kummer_total/individual_total)
            ),
            "individual_dual_seconds": individual_dual,
            "kummer_dual_seconds": kummer_dual,
            "dual_reduction_percent": (
                100*(1 - kummer_dual/individual_dual)
            ),
            "kummer_subphase_timings_seconds": kummer[
                "evaluation"
            ]["explicit_subphase_timings_seconds"],
            "map_equivalence": map_equivalence,
        }
    )

result = {
    "workstream": "B025",
    "status": "verified",
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "scope": (
        "exact equivalence and timing of Kummer-class batched "
        "root extraction"
    ),
    "cases": cases,
    "certificate": {
        "one_independent_nth_root_call_per_degree": True,
        "all_x_coordinates_identical": True,
        "all_y_coordinates_equal_up_to_target_involution": True,
        "all_differentials_transform_by_the_same_sign": True,
        "all_map_identities_and_degrees_verified": True,
    },
}
output = root / "results" / "sage_kummer_root_optimization.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print("KUMMER_ROOT_OPTIMIZATION verified")
for case in cases:
    print(
        "degree",
        case["degree"],
        "runtime_reduction_percent",
        case["runtime_reduction_percent"],
        "dual_reduction_percent",
        case["dual_reduction_percent"],
        "y_signs",
        [
            record["target_y_sign"]
            for record in case["map_equivalence"]
        ],
    )
print("result", output)
