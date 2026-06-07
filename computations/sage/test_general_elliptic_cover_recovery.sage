"""
Regression tests for the degree-independent elliptic-cover recovery library.

The tests cover:

* an infinity-to-origin degree-7 map;
* an infinity-to-finite-point degree-7 map;
* a finite-source-to-finite-target degree-3 map.
* a quintic source over a quadratic field and a non-short target.

Run from the repository root:

    HOME=/tmp/sagehome sage \
        computations/sage/test_general_elliptic_cover_recovery.sage
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

R.<x> = PolynomialRing(QQ)

# Degree 7: Kumar's Y_-(49) specialization.
F1 = x^3 + 23*x^2 + 552*x + 17940
F2 = (
    x^3
    - QQ(46)/5*x^2
    + QQ(3013)/4*x
    - QQ(25645)/4
)
F7 = F1*F2
E1 = EllipticCurve(
    [0, 0, 0, -7876003275, -272222678576250]
)
E2_original = EllipticCurve(
    [1, -1, 1, -15705, 762297]
)
E2 = E2_original.short_weierstrass_model()
E2_isomorphism = E2_original.isomorphism_to(E2)
E2_center = E2_isomorphism(-7*E2_original.gens()[0])

degree7_first = recover_elliptic_cover(
    F7,
    E1,
    eigenform=1,
    differential_scale=QQ(49)/12,
    cover_degree=7,
)
degree7_second = recover_elliptic_cover(
    F7,
    E2,
    eigenform=x,
    differential_scale=-QQ(49)/60,
    cover_degree=7,
    target_center=E2_center,
)

expected_degree7_first = (
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
expected_degree7_second = (
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
assert degree7_first["x_coordinate"] == expected_degree7_first
assert degree7_second["x_coordinate"] == expected_degree7_second
assert degree7_first["degree_bounds"] == (7, 3)
assert degree7_second["degree_bounds"] == (7, 7)

# Degree 3: recover the complementary map using a finite source point and a
# target with nonzero a1, a2, and a3.
F3 = (
    x^6
    + QQ(19)/5*x^5
    + QQ(42)/5*x^4
    + QQ(309)/20*x^3
    + QQ(63)/4*x^2
    + 15*x
    + QQ(25)/4
)
E3 = EllipticCurve([2, -1, 2, 23, 374])
degree3_denominator = (
    x^3 + QQ(4)/5*x^2 + 2*x + QQ(5)/4
)
expected_degree3 = (
    -6*x^3 - 6*x^2 - QQ(35)/4*x + QQ(25)/4
) / degree3_denominator
degree3 = recover_elliptic_cover(
    F3,
    E3,
    eigenform=x + QQ(15)/4,
    differential_scale=-QQ(1)/5,
    cover_degree=3,
    source_point=(QQ(0), QQ(5)/2),
    target_center=E3(QQ(5), QQ(19)),
)
assert degree3["x_coordinate"] == expected_degree3
assert degree3["degree"] == 3
assert degree3["source_center"] == "finite"
assert degree3["y_offset"] == -expected_degree3-1

# Degree 5: odd-degree source model over a number field.
Q.<u> = PolynomialRing(QQ)
K.<z> = NumberField(u^2 + u - 5)
RK.<v> = PolynomialRing(K)
alpha = K((283 - 39*z)/289)
elliptic_rhs = v*(v - 1)*(v - alpha)
E5 = EllipticCurve(
    K,
    [
        0,
        elliptic_rhs[2],
        0,
        elliptic_rhs[1],
        elliptic_rhs[0],
    ],
)
degree5_F1 = v^2 + 65*v + 15
degree5_F2 = 15*v^2 + 65*v + 1
degree5_source = (
    v
    * (v - 1)
    * (
        v^3
        + (8197*z - 24949)/289*v^2
        + (176575*z + 493478)/289*v
        - (1064*z + 2987)/289
    )
)
expected_degree5 = v*degree5_F1^2/degree5_F2^2
degree5 = recover_elliptic_cover(
    degree5_source,
    E5,
    eigenform=v-z-3,
    differential_scale=K(15)/2,
    cover_degree=5,
)
assert degree5["x_coordinate"] == expected_degree5
assert degree5["degree_bounds"] == (5, 4)
assert degree5["degree"] == 5

elapsed = perf_counter()-started
cases = [
    ("degree7_origin", degree7_first),
    ("degree7_finite_target", degree7_second),
    ("degree3_finite_source", degree3),
    ("degree5_quintic_number_field", degree5),
]
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B010",
    "verified": True,
    "library": (
        "computations/sage/lib/elliptic_cover_recovery.sage"
    ),
    "cases": [
        {
            "label": label,
            "degree": int(case["degree"]),
            "source_center": case["source_center"],
            "target_center": str(case["target_center"]),
            "degree_bounds": [
                int(value) for value in case["degree_bounds"]
            ],
            "x_coordinate": str(case["x_coordinate"]),
            "identity_residual": str(case["identity_residual"]),
        }
        for label, case in cases
    ],
}

output = root / "results" / "sage_general_map_recovery.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
