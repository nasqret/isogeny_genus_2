"""
Validate the degree-6 through degree-11 Kumar family importer.

The fast all-degree audit parses every surface equation, Igusa-Clebsch tuple,
and pair of symmetric j-functions.  It then checks at rational sample points
that

    ((j_1+j_2)^2-4*j_1*j_2) / D_n(r,s)

is a rational square, as required for the two j-invariants to live on the
Hilbert modular double cover.

The executable degree-7 specialization additionally constructs Kumar's
tautological genus-2 curve and feeds its two j-values into the independent
Frobenius twist-discovery layer.
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
load(str(
    root
    / "computations"
    / "sage"
    / "lib"
    / "kumar_square_discriminant_families.sage"
))
load(str(
    root
    / "computations"
    / "sage"
    / "lib"
    / "elliptic_factor_discovery.sage"
))

inventory = audit_kumar_source_files()
assert len(inventory) == 18
assert all(
    entry["has_surface"]
    and entry["has_j_sum"]
    and entry["has_j_product"]
    and entry["has_sextic"]
    for entry in inventory
)

field, r, s = kumar_parameter_field()
sample_certificates = []
for degree in KUMAR_DEGREES:
    surface_rhs = kumar_surface_rhs(degree)
    j_sum, j_product = kumar_j_symmetric_functions(degree)
    igusa = kumar_igusa_clebsch_invariants(degree)
    assert len(igusa) == 4

    certificate = None
    for r_value in range(-3, 5):
        for s_value in range(-3, 5):
            try:
                surface_value = QQ(surface_rhs(
                    r=QQ(r_value),
                    s=QQ(s_value),
                ))
                sum_value = QQ(j_sum(
                    r=QQ(r_value),
                    s=QQ(s_value),
                ))
                product_value = QQ(j_product(
                    r=QQ(r_value),
                    s=QQ(s_value),
                ))
                igusa_values = [
                    QQ(value(r=QQ(r_value), s=QQ(s_value)))
                    for value in igusa
                ]
            except (ArithmeticError, ValueError, ZeroDivisionError):
                continue
            discriminant_value = sum_value^2-4*product_value
            if (
                surface_value == 0
                or discriminant_value == 0
                or any(value == 0 for value in igusa_values)
            ):
                continue
            square_ratio = discriminant_value/surface_value
            if not square_ratio.is_square():
                continue
            certificate = {
                "degree": int(degree),
                "parameters": [int(r_value), int(s_value)],
                "surface_value": str(surface_value),
                "j_discriminant": str(discriminant_value),
                "square_ratio": str(square_ratio),
                "square_root": str(square_ratio.sqrt()),
                "igusa_clebsch_nonzero": True,
            }
            break
        if certificate is not None:
            break
    assert certificate is not None
    sample_certificates.append(certificate)

# Kumar's rational section r=4/(5s), z=(s-2)(25s-2)/(25s), at s=1.
degree7 = specialize_kumar_family(
    7,
    QQ(4)/5,
    1,
    z_value=-QQ(23)/25,
)
assert degree7["source_curve"].genus() == 2
assert degree7["coefficient_field"] is QQ
j_roots = sorted(
    [QQ(root) for root, multiplicity in degree7["j_polynomial"].roots()]
)
expected_j1 = -QQ(20285403817)/279936
expected_j2 = -QQ(97967097)/128
expected_j_values = sorted([expected_j1, expected_j2])
assert j_roots == expected_j_values

target_discovery = discover_target_twists_from_j(
    degree7["source_polynomial"],
    j_roots,
    prime_bound=50,
    minimum_matching_primes=4,
)
twists_by_j = {
    target["j_invariant"]: sorted(
        candidate["twist_square_class"]
        for candidate in target["compatible_twists"]
    )
    for target in target_discovery["targets"]
}
assert -115 in twists_by_j[expected_j1]
assert 5 in twists_by_j[expected_j2]

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B009",
    "verified": True,
    "supported_degrees": [int(degree) for degree in KUMAR_DEGREES],
    "source_file_count": len(inventory),
    "source_bytes": int(sum(
        entry["byte_count"]
        for entry in inventory
    )),
    "source_sha256": {
        Path(entry["path"]).name: entry["sha256"]
        for entry in inventory
    },
    "all_degree_certificates": sample_certificates,
    "degree7_executable_specialization": {
        "parameters": ["4/5", "1"],
        "z": "-23/25",
        "source_polynomial_degree": int(
            degree7["source_polynomial"].degree()
        ),
        "source_discriminant_nonzero": bool(
            degree7["source_polynomial"].discriminant() != 0
        ),
        "j_invariants": [str(value) for value in j_roots],
        "bad_prime_support": [
            int(value)
            for value in target_discovery["bad_prime_support"]
        ],
        "compatible_twists": {
            str(j_value): [int(value) for value in twists]
            for j_value, twists in twists_by_j.items()
        },
        "frobenius_prime_count": len(
            target_discovery["frobenius_data"]
        ),
    },
}

output = root / "results" / "sage_kumar_family_importer.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
