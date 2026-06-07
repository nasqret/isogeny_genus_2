"""
Recover and certify both primitive degree-6 elliptic maps.

The second map is the first regression case requiring the full quadratic
function field: its elliptic X-coordinate is A(x)+y*B(x), not a rational
function of x alone.  Its differential scale is discovered modulo good
primes and reconstructed by CRT before exact characteristic-zero recovery.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/recover_degree6_maps.sage
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

parameter_r = QQ(-9)
parameter_s = QQ(9)/2
parameter_z = QQ(39366)
specialization = specialize_kumar_family(
    6,
    parameter_r,
    parameter_s,
    z_value=parameter_z,
)
assert specialization["surface_value"] == parameter_z^2
assert specialization["coefficient_field"] is QQ

raw_source = specialization["source_polynomial"]
assert raw_source.discriminant() != 0
assert raw_source.discriminant() == 2^27*3^472

R.<x> = PolynomialRing(QQ)
source_polynomial = R(raw_source(3^16*x)/3^96)
expected_source = (
    x^6
    - 6*x^5
    + 7*x^4
    + QQ(28)/9*x^3
    - QQ(16)/3*x^2
    - QQ(16)/9*x
    + QQ(16)/81
)
assert source_polynomial == expected_source
assert source_polynomial.discriminant() != 0

j_roots = sorted(
    root_value
    for root_value, multiplicity
    in specialization["j_polynomial"].roots(QQ)
    for _ in range(multiplicity)
)
assert j_roots == [-972, 1296]

target_search = discover_target_twists_from_j(
    source_polynomial,
    j_roots,
    prime_bound=80,
)
assert target_search["bad_prime_support"] == [2, 3]
assert all(
    len(target["compatible_twists"]) == 1
    for target in target_search["targets"]
)
assert all(
    target["compatible_twists"][0]["twist_square_class"] == -1
    for target in target_search["targets"]
)

E1 = EllipticCurve([0, 0, 0, -27, 90])
E2 = EllipticCurve([0, 0, 0, 81, -162])
assert E1.j_invariant() == -972
assert E2.j_invariant() == 1296
assert E1.isogenies_prime_degree([2, 3]) == []
assert E2.isogenies_prime_degree([2, 3]) == []
assert {
    target["j_invariant"]:
    target["compatible_twists"][0]["curve"].short_weierstrass_model()
    for target in target_search["targets"]
} == {
    QQ(-972): E1,
    QQ(1296): E2,
}

# The Hasse-Witt matrices identify the two rational differential lines.
# In the basis (dx/y, x dx/y), the first diagonal entry matches E2 and the
# second matches E1.
hasse_witt_certificates = []
for prime in [5, 13, 17, 23, 31, 41]:
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
    trace_1 = E1.change_ring(finite_field).trace_of_frobenius()
    trace_2 = E2.change_ring(finite_field).trace_of_frobenius()
    assert matrix_value[0, 1] == 0
    assert matrix_value[1, 0] == 0
    assert matrix_value[0, 0] == finite_field(trace_2)
    assert matrix_value[1, 1] == finite_field(trace_1)
    hasse_witt_certificates.append({
        "prime": int(prime),
        "matrix": [
            [int(matrix_value[row, column]) for column in range(2)]
            for row in range(2)
        ],
        "target_traces": {
            "-972": int(trace_1),
            "1296": int(trace_2),
        },
    })

# The first map is invariant under the hyperelliptic involution.
first_discovery = discover_elliptic_cover(
    source_polynomial,
    E1,
    x,
    6,
    degree_bounds=(6, 6),
    target_centers=[E1(3, -6)],
    symbolic_precision=18,
)
assert len(first_discovery["maps"]) == 1
first_map = first_discovery["maps"][0]
assert first_map["differential_scale"] == -1
assert first_map["degree"] == 6
assert first_map["identity_residual"] == 0

# The complementary map requires X=A(x)+y*B(x).  Its scale square is found
# independently modulo two good primes and reconstructed as 4/9.
second_scale = discover_general_scale_by_crt(
    source_polynomial,
    E2,
    1,
    6,
    (12, 9, 8),
    [101, 103],
    precision=44,
)
assert second_scale["scale_square"] == QQ(4)/9
assert second_scale["scale"] == QQ(2)/3
second_map = recover_general_elliptic_cover(
    source_polynomial,
    E2,
    1,
    second_scale["scale"],
    6,
    (12, 9, 8),
    precision=48,
)
assert second_map["x_coordinate_degree"] == 12
assert second_map["cover_degree"] == 6

second_X0, second_X1 = second_map["x_coordinate"]
second_Y0, second_Y1 = second_map["y_coordinate"]
expected_denominator_factorization = (
    (x+QQ(1)/2)^2
    * (x^3+QQ(3)/2*x^2+QQ(2)/5*x-QQ(2)/45)^2
)
assert (
    second_X0.denominator().monic()
    == expected_denominator_factorization.monic()
)

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
        "Exact recovery of both primitive degree-6 maps for a rational "
        "Y_-(36) specialization"
    ),
    "specialization": {
        "parameters": {
            "r": str(parameter_r),
            "s": str(parameter_s),
            "z": str(parameter_z),
        },
        "surface_value": str(specialization["surface_value"]),
        "raw_sextic_discriminant_factorization": "2^27 * 3^472",
        "normalization": {
            "raw_x": "3^16*x",
            "raw_y": "3^48*y",
        },
        "normalized_source_polynomial": str(source_polynomial),
        "j_invariants": [str(value) for value in j_roots],
    },
    "target_discovery": {
        "bad_prime_support": [
            int(value) for value in target_search["bad_prime_support"]
        ],
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
                    ][0]["curve"].short_weierstrass_model()
                ),
            }
            for target in target_search["targets"]
        ],
    },
    "hasse_witt_certificates": hasse_witt_certificates,
    "maps": [
        {
            "label": "degree6_quotient",
            "target_j": "-972",
            "target_curve": str(E1),
            "eigenform": "x dx/y",
            "differential_scale": str(
                first_map["differential_scale"]
            ),
            "target_center": [str(E1(3, -6)[0]), str(E1(3, -6)[1])],
            "degree_bounds": [int(value) for value in (6, 6)],
            "cover_degree": int(first_map["degree"]),
            "primitive_over_Q": True,
            "primitivity_reason": (
                "The target has no rational prime-degree isogeny of "
                "degree 2 or 3."
            ),
            "x_coordinate": str(first_map["x_coordinate"]),
            "y_multiplier": str(first_map["y_multiplier"]),
            "y_offset": str(first_map["y_offset"]),
        },
        {
            "label": "degree6_complement",
            "target_j": "1296",
            "target_curve": str(E2),
            "eigenform": "dx/y",
            "differential_scale": str(
                second_map["differential_scale"]
            ),
            "target_center": "elliptic origin",
            "degree_bounds": [int(value) for value in (12, 9, 8)],
            "cover_degree": int(second_map["cover_degree"]),
            "primitive_over_Q": True,
            "primitivity_reason": (
                "The target has no rational prime-degree isogeny of "
                "degree 2 or 3."
            ),
            "x_coordinate_degree": int(
                second_map["x_coordinate_degree"]
            ),
            "x_coordinate": {
                "rational_part": str(second_X0),
                "y_part": str(second_X1),
            },
            "y_coordinate": {
                "rational_part": str(second_Y0),
                "y_part": str(second_Y1),
            },
            "denominator_factorization": (
                "(x + 1/2)^2 * "
                "(x^3 + 3/2*x^2 + 2/5*x - 2/45)^2"
            ),
            "crt_scale_discovery": {
                "scale_square": str(second_scale["scale_square"]),
                "crt_modulus": int(second_scale["crt_modulus"]),
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
                    for certificate in second_scale["certificates"]
                ],
            },
        },
    ],
}

output = root / "results" / "sage_degree6_recovery.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
