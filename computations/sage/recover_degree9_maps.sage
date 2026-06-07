"""
Recover and certify both primitive degree-9 elliptic maps.

The input is the rational point (r,s,z)=(3,-7,-29280) on Kumar's
Y_-(81).  The script independently rediscovers the elliptic twists and
Hasse-Witt eigenlines, reconstructs the two finite images of infinity by
modular search and CRT, and verifies the characteristic-zero maps.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/recover_degree9_maps.sage
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

parameter_r = QQ(3)
parameter_s = QQ(-7)
parameter_z = QQ(-29280)
specialization = specialize_kumar_family(
    9,
    parameter_r,
    parameter_s,
    z_value=parameter_z,
)
assert specialization["surface_value"] == parameter_z^2
assert specialization["coefficient_field"] is QQ

R.<x> = PolynomialRing(QQ)
raw_source = specialization["source_polynomial"]
normalization_scale = QQ(1319374656)/25
normalization_shift = QQ(33927572681856)/25
source_polynomial = R(
    raw_source(
        normalization_scale*x+normalization_shift
    )/normalization_scale^6
)
expected_source = (
    x^6
    - 9038618392*x^4
    - 64880615814700*x^3
    + 23434251437448181208*x^2
    + 276514602725620514127600*x
    - 12176183106883876734347363424
)
assert source_polynomial == expected_source
assert source_polynomial.discriminant() == (
    -2^24
    * 3^15
    * 5^6
    * 13^3
    * 29^12
    * 61^10
    * 79^20
    * 157^20
)

j_roots = sorted(
    root_value
    for root_value, multiplicity
    in specialization["j_polynomial"].roots(QQ)
    for _ in range(multiplicity)
)
j1 = -QQ(121929728)/4804839
j2 = QQ(598116032039544946688)/43441281
assert j_roots == [j1, j2]

target_search = discover_target_twists_from_j(
    source_polynomial,
    j_roots,
    prime_bound=120,
)
assert target_search["bad_prime_support"] == [
    2, 3, 5, 13, 29, 61, 79, 157,
]
assert target_search["twist_class_count"] == 512
assert all(
    len(target["compatible_twists"]) == 1
    for target in target_search["targets"]
)

E1 = EllipticCurve(QQ, [
    0,
    -1,
    1,
    -1604677999942163,
    -205661103401997979787347,
])
E2 = EllipticCurve(QQ, [
    0,
    -1,
    1,
    -6547160054952023739513,
    203904847526895684592439318144228,
])
assert E1.j_invariant() == j1
assert E2.j_invariant() == j2
assert E1.isogenies_prime_degree([3]) == []
assert E2.isogenies_prime_degree([3]) == []

targets_by_j = {
    target["j_invariant"]: target["compatible_twists"][0]
    for target in target_search["targets"]
}
assert targets_by_j[j1]["twist_square_class"] == -359687
assert targets_by_j[j2]["twist_square_class"] == -21940907
assert targets_by_j[j1]["curve"] == E1
assert targets_by_j[j2]["curve"] == E2

# In the basis (dx/y, x dx/y), these vectors give the two quotient lines.
eigenvector_1 = vector(ZZ, [231434, 9])
eigenvector_2 = vector(ZZ, [1, 0])
hasse_witt_certificates = []
for prime in [11, 17, 19, 23, 31, 37]:
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
    trace1 = E1.change_ring(finite_field).trace_of_frobenius()
    trace2 = E2.change_ring(finite_field).trace_of_frobenius()
    vector1 = eigenvector_1.change_ring(finite_field)
    vector2 = eigenvector_2.change_ring(finite_field)
    assert matrix_value*vector1 == finite_field(trace1)*vector1
    assert matrix_value*vector2 == finite_field(trace2)*vector2
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
        "eigenvectors": {
            str(j1): [int(value) for value in eigenvector_1],
            str(j2): [int(value) for value in eigenvector_2],
        },
    })

# These prime lists contain only reductions with a unique certified center.
# The CRT helper stops as soon as the lift lies on E and the full map identity
# certifies over QQ.
partial_center_search_1 = discover_center_by_crt(
    source_polynomial,
    E1,
    231434+9*x,
    1,
    9,
    (9, 9),
    [
        97, 113, 139, 163, 173, 199, 239, 263,
    ],
    precision=74,
    allow_partial=True,
)
assert not partial_center_search_1["verified"]
assert partial_center_search_1["crt_modulus"].nbits() == 59
center_search_1 = discover_center_by_crt(
    source_polynomial,
    E1,
    231434+9*x,
    1,
    9,
    (9, 9),
    [281, 307, 347, 359, 401, 457, 461, 463],
    precision=74,
    initial_state=partial_center_search_1,
)

partial_center_search_2 = discover_center_by_crt(
    source_polynomial,
    E2,
    1,
    -24806,
    9,
    (9, 9),
    [
        89, 101, 139, 149, 151, 179, 181, 191,
        229, 239, 269, 271,
    ],
    precision=74,
    allow_partial=True,
)
assert not partial_center_search_2["verified"]
assert partial_center_search_2["crt_modulus"].nbits() == 90
center_search_2 = discover_center_by_crt(
    source_polynomial,
    E2,
    1,
    -24806,
    9,
    (9, 9),
    [311, 331, 349, 379, 389, 401, 409, 419, 431, 449, 461],
    precision=74,
    initial_state=partial_center_search_2,
)

expected_center_1 = E1(
    QQ(1162836225963)/5041,
    -QQ(1224177442475117122)/357911,
)
expected_center_2 = E2(
    QQ(14623882010512642188)/314743081,
    -QQ(528607451220336034930422397)/5583857000021,
)
assert center_search_1["target_center"] == expected_center_1
assert center_search_2["target_center"] == expected_center_2
assert center_search_1["crt_modulus"].nbits() == 128
assert center_search_2["crt_modulus"].nbits() == 184

map1 = center_search_1["map"]
map2 = center_search_2["map"]
assert map1["degree"] == 9
assert map2["degree"] == 9
assert map1["degree_bounds"] == (9, 9)
assert map2["degree_bounds"] == (9, 9)
assert map1["identity_residual"] == 0
assert map2["identity_residual"] == 0
assert map1["y_offset"] == -QQ(1)/2
assert map2["y_offset"] == -QQ(1)/2

# Compact integer-polynomial forms used by the independent Magma verifier.
N1 = (
    1162836225963*x^9
    - 256545765846466281*x^8
    + 12652488352380857709336*x^7
    + 818827565449711168023412677*x^6
    - 60886103685147745340670731299508*x^5
    - 3146599524765592448018557306442895716*x^4
    + 279436442970809306335577972418159506755232*x^3
    + 1746202059537274010678006676413547682896124208*x^2
    - 533062849190004836422732749143975255871828802923584*x
    + 11229668661977555866970270104041120158473185041800892736
)
D1 = (
    5041*x^9
    - 2457565316*x^8
    + 413733513750033*x^7
    - 21565635256056602542*x^6
    - 1340101343350854652279676*x^5
    + 187261747469204952946806060248*x^4
    - 4426121358811994618001199054583248*x^3
    - 211440669630409945327261004278658031136*x^2
    + 11125625311906705351796300739141028282480064*x
    - 125204069316651023422344999259625249073639005568
)
assert map1["x_coordinate"] == N1/D1

N2 = (
    14623882010512642188*x^9
    + 3384463509220982832137592*x^8
    + 178856499577300957311717209853*x^7
    - 17022584952287967888714561574613646*x^6
    - 2313249245969335679166633038134865083581*x^5
    - 62431672986547178971714121604929781708248634*x^4
    + 3697559044088190594025055308856161428571355304729*x^3
    + 299756144028914927211565025024065043926712695292722806*x^2
    + 7849032852706801941974637788387627323461563862301047337548*x
    + 74629926505611061320237111105931623494351139367283074730716488
)
D2 = (
    12769*x^9
    + 2955180746*x^8
    + 156815844034306*x^7
    - 14714093641283509920*x^6
    - 2007463277217180951534735*x^5
    - 54218427470464734080369490582*x^4
    + 3210498614367019535202998071722972*x^3
    + 260309406646421654557698868144646030652*x^2
    + 6816334370249433937458457042977237639545520*x
    + 64811221989420997965837372828207053918006422800
)
assert map2["x_coordinate"] == N2/(24649*D2)

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstreams": ["B004", "B010", "B012", "B016"],
    "verified": True,
    "scope": (
        "Exact recovery of both primitive degree-9 maps for a rational "
        "Y_-(81) specialization"
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
                "1319374656/25*x + 33927572681856/25"
            ),
            "raw_y": "(1319374656/25)^3*y",
        },
        "normalized_source_polynomial": str(source_polynomial),
        "normalized_discriminant_factorization": (
            "-2^24 * 3^15 * 5^6 * 13^3 * 29^12 * "
            "61^10 * 79^20 * 157^20"
        ),
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
            "label": "degree9_map_1",
            "target_j": str(j1),
            "target_curve": str(E1),
            "eigenform": "(231434 + 9*x) dx/y",
            "differential_scale": "1",
            "target_center": [
                str(expected_center_1[0]),
                str(expected_center_1[1]),
            ],
            "degree_bounds": [int(9), int(9)],
            "cover_degree": int(9),
            "primitive_over_Q": True,
            "primitivity_reason": (
                "A nontrivial factorization of a degree-9 map from a "
                "genus-2 curve to an elliptic curve would induce a "
                "rational 3-isogeny of the target; none exists."
            ),
            "x_coordinate": str(map1["x_coordinate"]),
            "y_multiplier": str(map1["y_multiplier"]),
            "y_offset": str(map1["y_offset"]),
            "crt_center_discovery": {
                "modulus": int(center_search_1["crt_modulus"]),
                "modulus_bits": int(
                    center_search_1["crt_modulus"].nbits()
                ),
                "certificates": [
                    {
                        "prime": int(certificate["prime"]),
                        "center_x": int(certificate["center_x"]),
                        "center_y": int(certificate["center_y"]),
                    }
                    for certificate in center_search_1["certificates"]
                ],
            },
        },
        {
            "label": "degree9_map_2",
            "target_j": str(j2),
            "target_curve": str(E2),
            "eigenform": "dx/y",
            "differential_scale": "-24806",
            "target_center": [
                str(expected_center_2[0]),
                str(expected_center_2[1]),
            ],
            "degree_bounds": [int(9), int(9)],
            "cover_degree": int(9),
            "primitive_over_Q": True,
            "primitivity_reason": (
                "A nontrivial factorization of a degree-9 map from a "
                "genus-2 curve to an elliptic curve would induce a "
                "rational 3-isogeny of the target; none exists."
            ),
            "x_coordinate": str(map2["x_coordinate"]),
            "y_multiplier": str(map2["y_multiplier"]),
            "y_offset": str(map2["y_offset"]),
            "crt_center_discovery": {
                "modulus": int(center_search_2["crt_modulus"]),
                "modulus_bits": int(
                    center_search_2["crt_modulus"].nbits()
                ),
                "certificates": [
                    {
                        "prime": int(certificate["prime"]),
                        "center_x": int(certificate["center_x"]),
                        "center_y": int(certificate["center_y"]),
                    }
                    for certificate in center_search_2["certificates"]
                ],
            },
        },
    ],
}

output = root / "results" / "sage_degree9_recovery.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
