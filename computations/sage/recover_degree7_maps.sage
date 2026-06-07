"""
Discover and reconstruct both degree-7 x-coordinates by formal integration.

This is an executable B010 benchmark.  It starts from the source curve,
elliptic targets, eigenforms, and degree.  It discovers the differential
scales and target centers, and does not insert either rational map into the
reconstruction step.

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


# The first search discovers that infinity maps to the origin and derives
# scale^2=(49/12)^2.  Select the positive normalization.
discovery_1 = discover_elliptic_cover(
    source_polynomial,
    E1,
    eigenform=1,
    cover_degree=7,
)
recovery_1 = next(
    answer
    for answer in discovery_1["maps"]
    if answer["differential_scale"] > 0
)
c1 = recovery_1["differential_scale"]
recovered_X1 = recovery_1["x_coordinate"]

# The second search enumerates a bounded Mordell-Weil box and discovers both
# the finite center -7*G and the scale -49/60.
discovery_2 = discover_elliptic_cover(
    source_polynomial,
    E2,
    eigenform=x,
    cover_degree=7,
    mordell_weil_bound=7,
)
assert len(discovery_2["maps"]) == 1
recovery_2 = discovery_2["maps"][0]
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
assert len(discovery_1["attempted_centers"]) == 1
assert len(discovery_2["attempted_centers"]) == 4

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
        "exact symbolic scale solving, bounded Mordell-Weil center search, "
        "formal integration, and linear rational reconstruction"
    ),
    "library": (
        "computations/sage/lib/elliptic_cover_recovery.sage"
    ),
    "maps": [
        {
            "label": "f1",
            "eigenform": "dx/y",
            "target_center": "elliptic origin",
            "centers_attempted": int(
                len(discovery_1["attempted_centers"])
            ),
            "attempted_centers": [
                str(attempt["center"])
                for attempt in discovery_1["attempted_centers"]
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
            "eigenform": "x dx/y",
            "target_center": "-7*(29,-590)",
            "target_center_short": [
                str(point_x),
                str(point_y),
            ],
            "centers_attempted": int(
                len(discovery_2["attempted_centers"])
            ),
            "attempted_centers": [
                str(attempt["center"])
                for attempt in discovery_2["attempted_centers"]
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
