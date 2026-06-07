"""
Recover and certify both primitive degree-10 elliptic maps.

The benchmark is the rational point

    (r,s,z)=(-4/5,1/5,18/125)

on Kumar's Y_-(100).  Modular full-map identities reconstruct both
differential scales before characteristic-zero recovery.
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

parameter_r = -QQ(4)/5
parameter_s = QQ(1)/5
parameter_z = QQ(18)/125
specialization = specialize_kumar_family(
    10,
    parameter_r,
    parameter_s,
    z_value=parameter_z,
)
assert specialization["surface_value"] == parameter_z^2
assert specialization["coefficient_field"] is QQ

raw_source = specialization["source_polynomial"]
R.<x> = PolynomialRing(QQ)
normalization_scale = QQ(1631)/1953125
normalization_shift = QQ(3689)/18750
source_polynomial = R(
    raw_source(
        normalization_scale*(x+normalization_shift)
    )/normalization_scale^6
)
expected_source = (
    x^6
    + QQ(2121088693)/525000000*x^4
    + QQ(6263586727)/2109375000*x^3
    + QQ(19281661640110871)/4725000000000000*x^2
    + QQ(55337189906371920107)/9228515625000000000*x
    + QQ(58585142040574417351408159)
      / 26578125000000000000000000
)
assert source_polynomial == expected_source
assert source_polynomial.is_squarefree()

j_roots = sorted(
    root_value
    for root_value, multiplicity
    in specialization["j_polynomial"].roots(QQ)
    for _ in range(multiplicity)
)
j1 = -QQ(1604507735596990464)/1942017336875
j2 = QQ(884736)/171875
assert j_roots == [j1, j2]

target_search = discover_target_twists_from_j(
    raw_source,
    j_roots,
    prime_bound=110,
)
assert target_search["bad_prime_support"] == [
    2, 3, 5, 7, 11, 13, 233, 15193,
]
assert target_search["twist_class_count"] == 512
assert all(
    len(target["compatible_twists"]) == 1
    for target in target_search["targets"]
)

E1 = EllipticCurve([
    0,
    0,
    0,
    -806858835275202528,
    279253187015570073126859402,
])
E2 = EllipticCurve([
    0,
    0,
    0,
    1238639330931912,
    -306965070990450656294238,
])
assert E1.j_invariant() == j1
assert E2.j_invariant() == j2
assert E1.isogenies_prime_degree([2, 5]) == []
assert E2.isogenies_prime_degree([2, 5]) == []

targets_by_j = {
    target["j_invariant"]: target["compatible_twists"][0]
    for target in target_search["targets"]
}
assert targets_by_j[j1]["twist_square_class"] == 8295378
assert targets_by_j[j2]["twist_square_class"] == -2765126
assert targets_by_j[j1]["curve"] == E1
assert targets_by_j[j2]["curve"] == E2

# In Kumar's raw coordinate the eigenform lines are x dx/y and dx/y.
hasse_witt_certificates = []
for prime in [17, 19, 23, 31, 37, 41]:
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
    10,
    (20, 17, 18),
    list(prime_range(83, 180)),
    precision=72,
)
scale_search_2_partial = discover_general_scale_by_crt(
    raw_source,
    E2,
    1,
    10,
    (20, 17, 16),
    list(prime_range(83, 180)),
    precision=72,
    allow_partial=True,
)
assert not scale_search_2_partial["verified"]
scale_search_2 = discover_general_scale_by_crt(
    raw_source,
    E2,
    1,
    10,
    (20, 17, 16),
    list(prime_range(181, 284)),
    precision=72,
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
assert scale_search_1["scale"] == QQ(233)/2929687500
assert (
    scale_search_2["scale"]
    == QQ(75057962707)/429153442382812500000
)

# Transport the raw differentials through
# T=(1631/5^9)*(x+3689/18750), y_raw=(1631/5^9)^3*y.
eigenform_1 = x+normalization_shift
eigenform_2 = R(1)
normalized_scale_1 = QQ(1)/10500
normalized_scale_2 = QQ(197509)/787500000
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
    10,
    (20, 17, 18),
    precision=76,
)
map2 = recover_general_elliptic_cover(
    source_polynomial,
    E2,
    eigenform_2,
    normalized_scale_2,
    10,
    (20, 17, 16),
    precision=76,
)
assert map1["x_coordinate_degree"] == 20
assert map2["x_coordinate_degree"] == 20
assert map1["cover_degree"] == 10
assert map2["cover_degree"] == 10
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
            "No rational 2- or 5-isogeny leaves the target, so a "
            "nontrivial factorization of a degree-10 elliptic cover is "
            "impossible over Q."
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
        "Exact recovery of both primitive degree-10 maps for a rational "
        "Y_-(100) specialization"
    ),
    "specialization": {
        "parameters": {
            "r": str(parameter_r),
            "s": str(parameter_s),
            "z": str(parameter_z),
        },
        "surface_value": str(specialization["surface_value"]),
        "normalization": {
            "raw_x": (
                f"{normalization_scale}*(x+{normalization_shift})"
            ),
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
            "degree10_quotient",
            E1,
            eigenform_1,
            normalized_scale_1,
            map1,
        ),
        map_json(
            "degree10_complement",
            E2,
            eigenform_2,
            normalized_scale_2,
            map2,
        ),
    ],
}

output = root / "results" / "sage_degree10_recovery.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
