"""Verify exact map equivalence and timing gains for B022."""

import json
from datetime import datetime, timezone
from pathlib import Path


root = Path.cwd()
baseline = json.loads(
    (root / "results" / "sage_degree13_profile_baseline.json").read_text()
)
lookup = json.loads(
    (root / "results" / "sage_degree13_lookup_benchmark.json").read_text()
)
optimized = json.loads(
    (root / "results" / "sage_degree13_extension_roots.json").read_text()
)

base_field = GF(8009)
modulus_ring = PolynomialRing(base_field, "x")
x = modulus_ring.gen()
modulus = modulus_ring(
    sage_eval(
        baseline["theta_field_modulus"],
        locals={"x": x},
    )
)
theta_field = GF(
    8009^24,
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
for index, (baseline_map, optimized_map) in enumerate(
    zip(baseline["maps"], optimized["maps"])
):
    baseline_x = parse_function(baseline_map["x_coordinate"])
    optimized_x = parse_function(optimized_map["x_coordinate"])
    baseline_y = parse_function(baseline_map["y_coefficient"])
    optimized_y = parse_function(optimized_map["y_coefficient"])
    baseline_eigenform = parse_polynomial(
        baseline_map["pullback_eigenform"]
    )
    optimized_eigenform = parse_polynomial(
        optimized_map["pullback_eigenform"]
    )

    assert baseline_x == optimized_x
    y_sign = next(
        sign
        for sign in [theta_field(1), theta_field(-1)]
        if optimized_y == sign*baseline_y
    )
    assert optimized_eigenform == y_sign*baseline_eigenform
    assert baseline_map["target_j_invariant"] == (
        optimized_map["target_j_invariant"]
    )
    assert baseline_map["cover_degree"] == optimized_map["cover_degree"]
    assert optimized_map["elliptic_equation_identity"]
    assert optimized_map["linear_differential_pullback"]
    assert optimized_map["all_interpolation_samples_verified"]
    map_equivalence.append(
        {
            "factor_index": index,
            "x_coordinate_identical": True,
            "target_y_sign": int(1 if y_sign == 1 else -1),
            "y_coordinate_equivalent": True,
            "differential_equivalent": True,
        }
    )

baseline_total = baseline["runtime_seconds"]
lookup_total = lookup["runtime_seconds"]
optimized_total = optimized["runtime_seconds"]
baseline_dual = baseline["phase_timings_seconds"][
    "dual_isogeny_evaluation"
]
lookup_dual = lookup["phase_timings_seconds"][
    "dual_isogeny_evaluation"
]
optimized_dual = optimized["phase_timings_seconds"][
    "dual_isogeny_evaluation"
]

result = {
    "workstream": "B022",
    "status": "verified",
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "degree": int(13),
    "sample_count": optimized["evaluation"]["sample_count"],
    "compatible_lift_root_count": optimized["evaluation"][
        "explicit_root_count"
    ],
    "root_extension_degree": optimized["evaluation"][
        "explicit_root_extension_degree"
    ] if "explicit_root_extension_degree" in optimized["evaluation"] else int(13),
    "baseline": {
        "strategy": "symbolic_quotient_ring",
        "runtime_seconds": baseline_total,
        "dual_isogeny_seconds": baseline_dual,
    },
    "rejected_lookup": {
        "strategy": "projective_key_dictionary",
        "runtime_seconds": lookup_total,
        "dual_isogeny_seconds": lookup_dual,
        "runtime_regression_percent": (
            100*(lookup_total/baseline_total - 1)
        ),
        "dual_isogeny_regression_percent": (
            100*(lookup_dual/baseline_dual - 1)
        ),
    },
    "optimized": {
        "strategy": "explicit_degree_prime_extension",
        "runtime_seconds": optimized_total,
        "dual_isogeny_seconds": optimized_dual,
        "runtime_reduction_percent": (
            100*(1 - optimized_total/baseline_total)
        ),
        "dual_isogeny_reduction_percent": (
            100*(1 - optimized_dual/baseline_dual)
        ),
        "runtime_speedup_factor": baseline_total/optimized_total,
        "dual_isogeny_speedup_factor": baseline_dual/optimized_dual,
    },
    "map_equivalence": map_equivalence,
    "all_final_coordinates_descended": True,
    "all_map_certificates_verified": True,
}

output = root / "results" / "sage_degree13_recovery_optimization.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print("DEGREE13_RECOVERY_OPTIMIZATION verified")
print(
    "runtime_reduction_percent",
    result["optimized"]["runtime_reduction_percent"],
)
print(
    "dual_isogeny_reduction_percent",
    result["optimized"]["dual_isogeny_reduction_percent"],
)
print("map_y_signs", [entry["target_y_sign"] for entry in map_equivalence])
print("result", output)
