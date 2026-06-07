"""
Recover both degree-8 elliptic maps and their local primitivity inputs.

The compact quotient has X in QQ(x).  Its complement requires the full
quadratic function field X=A(x)+y*B(x); the differential scale is discovered
modulo two good primes and reconstructed by CRT.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/recover_degree8_maps.sage
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
    / "elliptic_cover_recovery.sage"
))
load(str(
    root
    / "computations"
    / "sage"
    / "lib"
    / "elliptic_factor_discovery.sage"
))

parameter_r = QQ(4)
parameter_s = QQ(-2)
parameter_z = QQ(-1280)
specialization = specialize_kumar_family(
    8,
    parameter_r,
    parameter_s,
    z_value=parameter_z,
)
assert specialization["surface_value"] == parameter_z^2
assert specialization["coefficient_field"] is QQ

raw_source = specialization["source_polynomial"]
assert raw_source.discriminant() == -(2^438)*(3^8)*(5^42)

R.<x> = PolynomialRing(QQ)
source_polynomial = R(
    raw_source(81920*x+40960)/81920^6
)
expected_source = (
    x^6 + 8*x^4 + 20*x^3 + 68*x^2 + 240*x + 396
)
assert source_polynomial == expected_source
assert source_polynomial.discriminant() != 0

j_roots = sorted(
    root_value
    for root_value, multiplicity
    in specialization["j_polynomial"].roots(QQ)
    for _ in range(multiplicity)
)
assert j_roots == [-QQ(8780800)/2187, QQ(5120)/3]

target_search = discover_target_twists_from_j(
    source_polynomial,
    j_roots,
    prime_bound=100,
)
assert target_search["bad_prime_support"] == [2, 3, 5]
assert target_search["twist_class_count"] == 16
assert all(
    len(target["compatible_twists"]) == 1
    for target in target_search["targets"]
)

E_rank_zero = EllipticCurve([0, -1, 0, -5833, 207037])
E_rank_one = EllipticCurve([0, -1, 0, 7, -3])
assert E_rank_zero.j_invariant() == -QQ(8780800)/2187
assert E_rank_one.j_invariant() == QQ(5120)/3
assert E_rank_zero.rank() == 0
assert E_rank_one.rank() == 1
assert E_rank_zero.isogenies_prime_degree([2]) == []
assert E_rank_one.isogenies_prime_degree([2]) == []

targets_by_j = {
    target["j_invariant"]:
    target["compatible_twists"][0]
    for target in target_search["targets"]
}
assert (
    targets_by_j[-QQ(8780800)/2187]["twist_square_class"]
    == 5
)
assert (
    targets_by_j[QQ(5120)/3]["twist_square_class"]
    == 1
)
assert (
    targets_by_j[-QQ(8780800)/2187][
        "curve"
    ].short_weierstrass_model().j_invariant()
    == E_rank_zero.j_invariant()
)
assert (
    targets_by_j[QQ(5120)/3][
        "curve"
    ].short_weierstrass_model().j_invariant()
    == E_rank_one.j_invariant()
)

# In the basis (dx/y, x dx/y), right Hasse-Witt eigenvectors distinguish
# the two quotient lines: (1,0) for the rank-zero target and (1,2) for the
# rank-one target.
hasse_witt_certificates = []
for prime in [7, 11, 17, 19, 23, 29]:
    finite_field = GF(prime)
    finite_source = source_polynomial.change_ring(finite_field)
    power = finite_source^((prime-1)//2)

    def coefficient(index):
        if 0 <= index <= power.degree():
            return power[index]
        return finite_field(0)

    matrix_value = matrix(finite_field, [
        [coefficient(prime-1), coefficient(prime-2)],
        [coefficient(2*prime-1), coefficient(2*prime-2)],
    ])
    trace_rank_zero = (
        E_rank_zero
        .change_ring(finite_field)
        .trace_of_frobenius()
    )
    trace_rank_one = (
        E_rank_one
        .change_ring(finite_field)
        .trace_of_frobenius()
    )
    vector_rank_zero = vector(finite_field, [1, 0])
    vector_rank_one = vector(finite_field, [1, 2])
    assert (
        matrix_value*vector_rank_zero
        == finite_field(trace_rank_zero)*vector_rank_zero
    )
    assert (
        matrix_value*vector_rank_one
        == finite_field(trace_rank_one)*vector_rank_one
    )
    hasse_witt_certificates.append({
        "prime": int(prime),
        "matrix": [
            [int(matrix_value[row, column]) for column in range(2)]
            for row in range(2)
        ],
        "target_traces": {
            str(E_rank_zero.j_invariant()): int(trace_rank_zero),
            str(E_rank_one.j_invariant()): int(trace_rank_one),
        },
        "eigenvectors": {
            str(E_rank_zero.j_invariant()): [
                int(value) for value in (1, 0)
            ],
            str(E_rank_one.j_invariant()): [
                int(value) for value in (1, 2)
            ],
        },
    })

compact_discovery = discover_elliptic_cover(
    source_polynomial,
    E_rank_zero,
    1,
    8,
    target_centers=[E_rank_zero(0)],
    symbolic_precision=26,
)
compact_maps = [
    candidate
    for candidate in compact_discovery["maps"]
    if candidate["differential_scale"] > 0
]
assert len(compact_maps) == 1
compact_map = compact_maps[0]
assert compact_map["differential_scale"] == 2
assert compact_map["degree_bounds"] == (8, 4)
assert compact_map["degree"] == 8
assert compact_map["identity_residual"] == 0

complement_scale = discover_general_scale_by_crt(
    source_polynomial,
    E_rank_one,
    1+2*x,
    8,
    (16, 13, 14),
    [61, 67],
    precision=58,
)
assert complement_scale["scale_square"] == 4
assert complement_scale["scale"] == 2
complement_map = recover_general_elliptic_cover(
    source_polynomial,
    E_rank_one,
    1+2*x,
    complement_scale["scale"],
    8,
    (16, 13, 14),
    precision=64,
)
assert complement_map["x_coordinate_degree"] == 16
assert complement_map["cover_degree"] == 8

complement_X0, complement_X1 = complement_map["x_coordinate"]
complement_Y0, complement_Y1 = complement_map["y_coordinate"]
pole_polynomial = (
    x^7
    - QQ(4357)/12*x^6
    + 314*x^5
    - QQ(25905)/8*x^4
    - QQ(3285)/2*x^3
    - QQ(69039)/2*x^2
    - 35073*x
    - 87723
)
assert complement_X0.denominator() == pole_polynomial^2
assert complement_X1.denominator() == pole_polynomial^2

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstreams": ["B004", "B010", "B012"],
    "verified": True,
    "scope": (
        "Exact recovery of both degree-8 maps for a rational "
        "Y_-(64) specialization"
    ),
    "specialization": {
        "parameters": {
            "r": str(parameter_r),
            "s": str(parameter_s),
            "z": str(parameter_z),
        },
        "surface_value": str(specialization["surface_value"]),
        "raw_sextic_discriminant_factorization": (
            "-2^438 * 3^8 * 5^42"
        ),
        "normalization": {
            "raw_x": "81920*x + 40960",
            "raw_y": "81920^3*y",
        },
        "normalized_source_polynomial": str(source_polynomial),
        "j_invariants": [str(value) for value in j_roots],
    },
    "target_discovery": {
        "bad_prime_support": [
            int(value) for value in target_search["bad_prime_support"]
        ],
        "twist_class_count": int(target_search["twist_class_count"]),
        "frobenius_primes": [
            int(item["prime"])
            for item in target_search["frobenius_data"]
        ],
        "targets": [
            {
                "j": str(target["j_invariant"]),
                "twist_square_class": int(
                    target[
                        "compatible_twists"
                    ][0]["twist_square_class"]
                ),
                "curve": str(
                    target[
                        "compatible_twists"
                    ][0]["curve"]
                ),
            }
            for target in target_search["targets"]
        ],
    },
    "hasse_witt_certificates": hasse_witt_certificates,
    "maps": [
        {
            "label": "degree8_quotient",
            "target_j": str(E_rank_zero.j_invariant()),
            "target_curve": str(E_rank_zero),
            "eigenform": "dx/y",
            "differential_scale": str(
                compact_map["differential_scale"]
            ),
            "target_center": "elliptic origin",
            "degree_bounds": [int(value) for value in (8, 4)],
            "cover_degree": int(compact_map["degree"]),
            "primitive_over_Q": True,
            "primitivity_reason": (
                "The target has no rational 2-isogeny; the companion "
                "Magma certificate proves that the source has no "
                "non-hyperelliptic rational involution, and the compact "
                "map also has S8 monodromy."
            ),
            "primitivity_dependency": (
                "results/magma_degree8_maps.json and "
                "results/magma_degree8_monodromy.json"
            ),
            "x_coordinate": str(compact_map["x_coordinate"]),
            "y_multiplier": str(compact_map["y_multiplier"]),
            "y_offset": str(compact_map["y_offset"]),
        },
        {
            "label": "degree8_complement",
            "target_j": str(E_rank_one.j_invariant()),
            "target_curve": str(E_rank_one),
            "eigenform": "(1 + 2*x) dx/y",
            "differential_scale": str(
                complement_map["differential_scale"]
            ),
            "target_center": "elliptic origin",
            "degree_bounds": [
                int(value) for value in (16, 13, 14)
            ],
            "cover_degree": int(complement_map["cover_degree"]),
            "x_coordinate_degree": int(
                complement_map["x_coordinate_degree"]
            ),
            "primitive_over_Q": True,
            "primitivity_reason": (
                "The target has no rational 2-isogeny; the companion "
                "Magma certificate proves that the source has no "
                "non-hyperelliptic rational involution."
            ),
            "primitivity_dependency": (
                "results/magma_degree8_maps.json"
            ),
            "x_coordinate": {
                "rational_part": str(complement_X0),
                "y_part": str(complement_X1),
            },
            "y_coordinate": {
                "rational_part": str(complement_Y0),
                "y_part": str(complement_Y1),
            },
            "denominator_factorization": (
                "(x^7 - 4357/12*x^6 + 314*x^5 - 25905/8*x^4 "
                "- 3285/2*x^3 - 69039/2*x^2 - 35073*x - 87723)^2"
            ),
            "crt_scale_discovery": {
                "scale_square": str(
                    complement_scale["scale_square"]
                ),
                "crt_modulus": int(
                    complement_scale["crt_modulus"]
                ),
                "certificates": [
                    {
                        "prime": int(certificate["prime"]),
                        "scale_roots": [
                            int(value)
                            for value in certificate["scale_roots"]
                        ],
                        "scale_square": int(
                            certificate["scale_square"]
                        ),
                    }
                    for certificate
                    in complement_scale["certificates"]
                ],
            },
        },
    ],
}

output = root / "results" / "sage_degree8_recovery.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
