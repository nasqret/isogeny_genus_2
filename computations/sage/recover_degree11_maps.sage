"""
Recover and certify both primitive degree-11 elliptic maps.

The benchmark is the rational point

    (r,s,z)=(3/2,1/2,3/8)

on Kumar's Y_-(121).  Both maps require the full quadratic function field.
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
load(str(
    root / "computations" / "sage" / "lib"
    / "kumar_square_discriminant_families.sage"
))
load(str(
    root / "computations" / "sage" / "lib"
    / "elliptic_cover_recovery.sage"
))
load(str(
    root / "computations" / "sage" / "lib"
    / "elliptic_factor_discovery.sage"
))

parameter_r = QQ(3)/2
parameter_s = QQ(1)/2
parameter_z = QQ(3)/8
specialization = specialize_kumar_family(
    11,
    parameter_r,
    parameter_s,
    z_value=parameter_z,
)
assert specialization["surface_value"] == parameter_z^2
assert specialization["coefficient_field"] is QQ

raw_source = specialization["source_polynomial"]
R.<x> = PolynomialRing(QQ)
normalization_scale = QQ(7835835)/2^28
source_polynomial = R(
    raw_source(normalization_scale*(x-1))
    / normalization_scale^6
)
expected_source = (
    x^6
    - QQ(10582594539)/811835150*x^4
    + QQ(547886661498)/17663213335*x^3
    - QQ(1271815959321705116)/42369191406997875*x^2
    + QQ(21306650215214418058598)/1613206962821444090625*x
    - QQ(68855573531199446296282901)
      / 31588896913419334500281250
)
assert source_polynomial == expected_source
assert source_polynomial.is_squarefree()

j_roots = sorted(
    root_value
    for root_value, multiplicity
    in specialization["j_polynomial"].roots(QQ)
    for _ in range(multiplicity)
)
j1 = QQ(3245297195502)/1977326743
j2 = QQ(2304)
assert j_roots == [j1, j2]

target_search = discover_target_twists_from_j(
    raw_source,
    j_roots,
    prime_bound=110,
)
assert target_search["bad_prime_support"] == [2, 3, 7, 11, 71, 311]
assert target_search["twist_class_count"] == 128
assert all(
    len(target["compatible_twists"]) == 1
    for target in target_search["targets"]
)

E1 = EllipticCurve([
    0,
    0,
    0,
    3368911697438868,
    -17302825474991342749008,
])
E2 = EllipticCurve([
    0,
    0,
    0,
    -2580223408812,
    -797634783259688808,
])
assert E1.j_invariant() == j1
assert E2.j_invariant() == j2

targets_by_j = {
    target["j_invariant"]: target["compatible_twists"][0]
    for target in target_search["targets"]
}
assert targets_by_j[j1]["twist_square_class"] == 927402
assert targets_by_j[j2]["twist_square_class"] == 927402
assert targets_by_j[j1]["curve"] == E1
assert targets_by_j[j2]["curve"] == E2

# In Kumar's raw coordinate the eigenform lines are x dx/y and dx/y.
hasse_witt_certificates = []
for prime in [13, 19, 29, 31, 41, 43]:
    finite_field = GF(prime)
    finite_source = raw_source.change_ring(finite_field)
    power = finite_source^((prime-1)//2)

    def coefficient(index):
        if 0 <= index <= power.degree():
            return power[index]
        return finite_field(0)

    matrix_value = matrix(finite_field, [
        [coefficient(prime-1), coefficient(prime-2)],
        [coefficient(2*prime-1), coefficient(2*prime-2)],
    ])
    trace1 = E1.change_ring(finite_field).trace_of_frobenius()
    trace2 = E2.change_ring(finite_field).trace_of_frobenius()
    assert matrix_value*vector(finite_field, [0, 1]) == (
        finite_field(trace1)*vector(finite_field, [0, 1])
    )
    assert matrix_value*vector(finite_field, [1, 0]) == (
        finite_field(trace2)*vector(finite_field, [1, 0])
    )
    hasse_witt_certificates.append({
        "prime": int(prime),
        "matrix": [
            [
                int(matrix_value[row, column])
                for column in range(2)
            ]
            for row in range(2)
        ],
        "target_traces": {
            str(j1): int(trace1),
            str(j2): int(trace2),
        },
    })

scale_search_1 = discover_general_scale_by_crt(
    raw_source,
    E1,
    raw_source.parent().gen(),
    11,
    (22, 19, 20),
    list(prime_range(83, 180)),
    precision=76,
)
scale_search_2_partial = discover_general_scale_by_crt(
    raw_source,
    E2,
    1,
    11,
    (22, 19, 18),
    list(prime_range(211, 300)),
    precision=76,
    allow_partial=True,
)
assert not scale_search_2_partial["verified"]
scale_search_2 = discover_general_scale_by_crt(
    raw_source,
    E2,
    1,
    11,
    (22, 19, 18),
    list(prime_range(301, 384)),
    precision=76,
    initial_state=scale_search_2_partial,
)
scale_search_2["resume_checkpoint"] = {
    "crt_modulus_bits": int(
        scale_search_2_partial["crt_modulus"].nbits()
    ),
    "certificate_count": len(
        scale_search_2_partial["certificates"]
    ),
}
assert scale_search_1["scale"] == QQ(5929)/2^30
assert scale_search_2["scale"] == QQ(44904959407)/2^57

# Transport T=(7835835/2^28)*(x-1).
eigenform_1 = x-1
eigenform_2 = R(1)
normalized_scale_1 = QQ(121)/639660
normalized_scale_2 = QQ(2671801)/7306516350
assert (
    normalized_scale_1
    == scale_search_1["scale"]/normalization_scale
)
assert (
    normalized_scale_2
    == scale_search_2["scale"]/normalization_scale^2
)

map1 = recover_general_elliptic_cover(
    source_polynomial,
    E1,
    eigenform_1,
    normalized_scale_1,
    11,
    (22, 19, 20),
    precision=80,
)
map2 = recover_general_elliptic_cover(
    source_polynomial,
    E2,
    eigenform_2,
    normalized_scale_2,
    11,
    (22, 19, 18),
    precision=80,
)
assert map1["x_coordinate_degree"] == 22
assert map2["x_coordinate_degree"] == 22
assert map1["cover_degree"] == 11
assert map2["cover_degree"] == 11
assert general_elliptic_cover_identity(
    source_polynomial,
    E1,
    eigenform_1,
    normalized_scale_1,
    map1["x_coordinate"],
) == (0, 0)
assert general_elliptic_cover_identity(
    source_polynomial,
    E2,
    eigenform_2,
    normalized_scale_2,
    map2["x_coordinate"],
) == (0, 0)


def scale_certificate_json(search):
    answer = {
        "scale": str(search["scale"]),
        "scale_square": str(search["scale_square"]),
        "crt_modulus_bits": int(search["crt_modulus"].nbits()),
        "primes": [
            int(certificate["prime"])
            for certificate in search["certificates"]
        ],
        "failures": [
            {
                "prime": int(failure["prime"]),
                "reason": failure["reason"],
            }
            for failure in search["failures"]
        ],
    }
    if "resume_checkpoint" in search:
        answer["resume_checkpoint"] = search["resume_checkpoint"]
    return answer


def map_json(label, target, eigenform, scale, answer):
    return {
        "label": label,
        "target_curve": str(target),
        "target_j": str(target.j_invariant()),
        "eigenform": str(eigenform),
        "differential_scale": str(scale),
        "degree_bounds": [
            int(value) for value in answer["degree_bounds"]
        ],
        "cover_degree": int(answer["cover_degree"]),
        "x_coordinate_degree": int(answer["x_coordinate_degree"]),
        "primitive_over_Q": True,
        "primitivity_reason": (
            "The cover degree 11 is prime, so no nontrivial factorization "
            "through another elliptic curve is possible."
        ),
        "x_coordinate": {
            "rational_part": str(answer["x_coordinate"][0]),
            "y_part": str(answer["x_coordinate"][1]),
        },
        "y_coordinate": {
            "rational_part": str(answer["y_coordinate"][0]),
            "y_part": str(answer["y_coordinate"][1]),
        },
    }


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
        "Exact recovery of both primitive degree-11 maps for a rational "
        "Y_-(121) specialization"
    ),
    "specialization": {
        "parameters": {
            "r": str(parameter_r),
            "s": str(parameter_s),
            "z": str(parameter_z),
        },
        "surface_value": str(specialization["surface_value"]),
        "normalization": {
            "raw_x": f"{normalization_scale}*(x-1)",
            "raw_y": f"{normalization_scale}^3*y",
        },
        "normalized_source_polynomial": str(source_polynomial),
        "j_invariants": [str(value) for value in j_roots],
    },
    "target_discovery": {
        "bad_prime_support": [
            int(value) for value in target_search["bad_prime_support"]
        ],
        "twist_class_count": int(target_search["twist_class_count"]),
        "targets": [
            {
                "j": str(target["j_invariant"]),
                "twist_square_class": int(
                    target["compatible_twists"][0][
                        "twist_square_class"
                    ]
                ),
                "curve": str(
                    target["compatible_twists"][0]["curve"]
                ),
            }
            for target in target_search["targets"]
        ],
    },
    "hasse_witt_certificates": hasse_witt_certificates,
    "raw_scale_discovery": [
        scale_certificate_json(scale_search_1),
        scale_certificate_json(scale_search_2),
    ],
    "maps": [
        map_json(
            "degree11_quotient",
            E1,
            eigenform_1,
            normalized_scale_1,
            map1,
        ),
        map_json(
            "degree11_complement",
            E2,
            eigenform_2,
            normalized_scale_2,
            map2,
        ),
    ],
}

output = root / "results" / "sage_degree11_recovery.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
