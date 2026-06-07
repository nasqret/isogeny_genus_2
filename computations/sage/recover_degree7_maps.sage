"""
Discover and reconstruct both degree-7 maps from their candidate j-values.

This is an executable B010 benchmark.  It starts from the source curve,
the two Hilbert-modular j-invariants, and the degree.  It discovers the
rational target twists, eigenform lines, differential scales, target centers,
and maps.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/recover_degree7_maps.sage
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
    / "elliptic_cover_recovery.sage"
))
load(str(
    root
    / "computations"
    / "sage"
    / "lib"
    / "elliptic_factor_discovery.sage"
))

R.<x> = PolynomialRing(QQ)
F1 = x^3 + 23*x^2 + 552*x + 17940
F2 = (
    x^3
    - QQ(46)/5*x^2
    + QQ(3013)/4*x
    - QQ(25645)/4
)
source_polynomial = F1*F2

j1 = -QQ(20285403817)/279936
j2 = -QQ(97967097)/128
full_discovery = discover_covers_from_j_invariants(
    source_polynomial,
    [j1, j2],
    7,
    prime_bound=80,
    eigenform_height_bound=1,
    mordell_weil_bound=7,
    symbolic_precision=20,
)
assert len(full_discovery["covers"]) == 2
covers_by_j = {
    cover["twist_data"]["j_invariant"]: cover
    for cover in full_discovery["covers"]
}
cover_1 = covers_by_j[j1]
cover_2 = covers_by_j[j2]

assert cover_1["twist_data"]["twist_square_class"] == -115
assert cover_2["twist_data"]["twist_square_class"] == 5
assert cover_1["map_data"]["eigenform_coefficients"] == (1, 0)
assert cover_2["map_data"]["eigenform_coefficients"] == (0, 1)

E1 = cover_1["short_curve"]
E2 = cover_2["short_curve"]
assert E1 == EllipticCurve(
    [0, 0, 0, -7876003275, -272222678576250]
)
assert E2 == EllipticCurve(
    [0, 0, 0, -20353275, 35382561750]
)

recovery_1 = cover_1["map_data"]["maps"][0]
recovery_2 = cover_2["map_data"]["maps"][0]
c1 = recovery_1["differential_scale"]
recovered_X1 = recovery_1["x_coordinate"]
c2 = recovery_2["differential_scale"]
infinity_image = recovery_2["target_center"]
point_x = infinity_image[0]
point_y = infinity_image[1]
recovered_X2 = recovery_2["x_coordinate"]

# Compare against compact factorizations only after reconstruction.
expected_X1 = (
    QQ(576)/2401
    * (
        x^7
        + QQ(2415)/2*x^5
        + QQ(7245)/2*x^4
        + QQ(41306965)/192*x^3
        + QQ(393877001)/96*x^2
        - QQ(90651235955)/768*x
        + QQ(1179635972075)/768
    )
    / F2
)
quadratic_pole_factor = (
    x^2 - QQ(115)/24*x + QQ(7475)/24
)
expected_X2 = (
    (
        QQ(10465)/4*x^7
        + QQ(197225)/8*x^6
        + QQ(164727955)/64*x^5
        + QQ(1305770375)/64*x^4
        + QQ(36305600625)/64*x^3
        - QQ(1306013384375)/64*x^2
        - QQ(232046932796875)/16
    )
    / (F1*quadratic_pole_factor^2)
)
assert recovered_X1 == expected_X1
assert recovered_X2 == expected_X2
assert recovery_1["degree_bounds"] == (7, 3)
assert recovery_2["degree_bounds"] == (7, 7)
assert c1 == QQ(49)/12
assert c2 == -QQ(49)/60
assert infinity_image == E2(QQ(10465)/4, -QQ(51175)/8)

E2_original = cover_2["twist_data"]["curve"]
E2_isomorphism = E2_original.isomorphism_to(E2)
assert infinity_image == E2_isomorphism(-7*E2_original.gens()[0])

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B010",
    "verified": True,
    "method": (
        "Frobenius twist filtering, bounded eigenform and Mordell-Weil "
        "search, symbolic scale solving, and exact map reconstruction"
    ),
    "libraries": [
        "computations/sage/lib/elliptic_cover_recovery.sage",
        "computations/sage/lib/elliptic_factor_discovery.sage",
    ],
    "target_discovery": {
        "input_j_invariants": [str(j1), str(j2)],
        "bad_prime_support": [
            int(value)
            for value in full_discovery[
                "target_search"
            ]["bad_prime_support"]
        ],
        "twist_class_count": int(
            full_discovery["target_search"]["twist_class_count"]
        ),
        "frobenius_prime_count": int(
            len(full_discovery["target_search"]["frobenius_data"])
        ),
        "frobenius_primes": [
            int(certificate["prime"])
            for certificate in full_discovery[
                "target_search"
            ]["frobenius_data"]
        ],
        "compatible_twists_per_j": [
            {
                "j": str(target["j_invariant"]),
                "count": int(len(target["compatible_twists"])),
                "square_classes": [
                    int(candidate["twist_square_class"])
                    for candidate in target["compatible_twists"]
                ],
            }
            for target in full_discovery[
                "target_search"
            ]["targets"]
        ],
    },
    "maps": [
        {
            "label": "f1",
            "target_j": str(j1),
            "twist_square_class": int(-115),
            "eigenform_coefficients": [int(1), int(0)],
            "eigenform": "dx/y",
            "target_center": "elliptic origin",
            "search_attempt_count": int(
                len(cover_1["map_data"]["attempted"])
            ),
            "search_attempts": [
                {
                    "center": str(attempt["center"]),
                    "eigenform_coefficients": [
                        int(value)
                        for value in attempt[
                            "eigenform_coefficients"
                        ]
                    ],
                    "success": bool(attempt["success"]),
                }
                for attempt in cover_1["map_data"]["attempted"]
            ],
            "scale_polynomial": str(
                recovery_1["scale_polynomial"]
            ),
            "differential_scale": str(c1),
            "degree_bounds": [int(7), int(3)],
            "recovered_x_coordinate": str(recovered_X1),
        },
        {
            "label": "f2",
            "target_j": str(j2),
            "twist_square_class": int(5),
            "eigenform_coefficients": [int(0), int(1)],
            "eigenform": "x dx/y",
            "target_center": "-7*(29,-590)",
            "target_center_short": [
                str(point_x),
                str(point_y),
            ],
            "search_attempt_count": int(
                len(cover_2["map_data"]["attempted"])
            ),
            "search_attempts": [
                {
                    "center": str(attempt["center"]),
                    "eigenform_coefficients": [
                        int(value)
                        for value in attempt[
                            "eigenform_coefficients"
                        ]
                    ],
                    "success": bool(attempt["success"]),
                }
                for attempt in cover_2["map_data"]["attempted"]
            ],
            "scale_polynomial": str(
                recovery_2["scale_polynomial"]
            ),
            "differential_scale": str(c2),
            "degree_bounds": [int(7), int(7)],
            "recovered_x_coordinate": str(recovered_X2),
        },
    ],
}

output = root / "results" / "sage_degree7_recovery.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
