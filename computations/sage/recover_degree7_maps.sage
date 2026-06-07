"""
Reconstruct both degree-7 x-coordinates by formal integration and Pade.

This is an executable B010 benchmark.  It starts from the source curve,
elliptic targets, eigenforms, target points, and differential scales.  It does
not insert either rational map into the reconstruction step.

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

R.<x> = PolynomialRing(QQ)
F1 = x^3 + 23*x^2 + 552*x + 17940
F2 = (
    x^3
    - QQ(46)/5*x^2
    + QQ(3013)/4*x
    - QQ(25645)/4
)
source_polynomial = F1*F2

E1 = EllipticCurve(
    [0, 0, 0, -7876003275, -272222678576250]
)
E2_original = EllipticCurve(
    [1, -1, 1, -15705, 762297]
)
E2 = E2_original.short_weierstrass_model()


# First map: the chosen infinity maps to the elliptic origin.
c1 = QQ(49)/12
recovery_1 = recover_elliptic_cover(
    source_polynomial,
    E1,
    eigenform=1,
    differential_scale=c1,
    cover_degree=7,
)
recovered_X1 = recovery_1["x_coordinate"]

# Second map: translate the formal point by the finite image of infinity.
c2 = -QQ(49)/60
generator = E2_original.gens()[0]
isomorphism = E2_original.isomorphism_to(E2)
infinity_image = isomorphism(-7*generator)
recovery_2 = recover_elliptic_cover(
    source_polynomial,
    E2,
    eigenform=x,
    differential_scale=c2,
    cover_degree=7,
    target_center=infinity_image,
)
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
        "degree-independent formal integration plus exact linear "
        "rational reconstruction"
    ),
    "library": (
        "computations/sage/lib/elliptic_cover_recovery.sage"
    ),
    "maps": [
        {
            "label": "f1",
            "eigenform": "dx/y",
            "target_center": "elliptic origin",
            "differential_scale": str(c1),
            "pade_degrees": [int(7), int(3)],
            "recovered_x_coordinate": str(recovered_X1),
        },
        {
            "label": "f2",
            "eigenform": "x dx/y",
            "target_center": "-7*(29,-590)",
            "target_center_short": [
                str(point_x),
                str(point_y),
            ],
            "differential_scale": str(c2),
            "pade_degrees": [int(7), int(7)],
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
