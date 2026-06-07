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
precision = 28

R.<x> = PolynomialRing(QQ)
F1 = x^3 + 23*x^2 + 552*x + 17940
F2 = (
    x^3
    - QQ(46)/5*x^2
    + QQ(3013)/4*x
    - QQ(25645)/4
)
source_polynomial = F1*F2

S.<t> = PowerSeriesRing(QQ, default_prec=precision)
source_at_infinity = S(
    sum(source_polynomial[i]*t^(6-i) for i in range(7))
)
square_root = source_at_infinity.sqrt()
integral_dx_over_y = (-t/square_root).integral()
integral_x_dx_over_y = (-1/square_root).integral()

E1 = EllipticCurve(
    [0, 0, 0, -7876003275, -272222678576250]
)
E2_original = EllipticCurve(
    [1, -1, 1, -15705, 762297]
)
E2 = E2_original.short_weierstrass_model()


def pade_reconstruct(series, numerator_degree, denominator_degree):
    shift = numerator_degree-denominator_degree
    regular_series = (t^shift*series).add_bigoh(precision)
    rows = []
    rhs = []
    for k in range(
        numerator_degree+1,
        numerator_degree+denominator_degree+1,
    ):
        rows.append([
            regular_series[k-j]
            for j in range(1, denominator_degree+1)
        ])
        rhs.append(-regular_series[k])
    solution = matrix(QQ, rows).solve_right(vector(QQ, rhs))
    denominator_series = 1+sum(
        solution[j-1]*t^j
        for j in range(1, denominator_degree+1)
    )
    numerator_series = (
        regular_series*denominator_series
    ).add_bigoh(precision)
    for k in range(
        numerator_degree+denominator_degree+1,
        min(precision, numerator_series.prec()),
    ):
        assert numerator_series[k] == 0
    numerator = sum(
        numerator_series[k]*x^(numerator_degree-k)
        for k in range(numerator_degree+1)
    )
    denominator = sum(
        (QQ(1) if k == 0 else solution[k-1])
        * x^(denominator_degree-k)
        for k in range(denominator_degree+1)
    )
    return numerator/denominator


# First map: the chosen infinity maps to the elliptic origin.
c1 = QQ(49)/12
formal_group_1 = E1.formal_group()
parameter_1 = formal_group_1.log(precision).reverse()(
    c1*integral_dx_over_y
)
x_series_1 = formal_group_1.x(precision)(parameter_1)
recovered_X1 = pade_reconstruct(x_series_1, 7, 3)

# Second map: translate the formal point by the finite image of infinity.
c2 = -QQ(49)/60
generator = E2_original.gens()[0]
isomorphism = E2_original.isomorphism_to(E2)
infinity_image = isomorphism(-7*generator)
formal_group_2 = E2.formal_group()
parameter_2 = formal_group_2.log(precision).reverse()(
    c2*integral_x_dx_over_y
)
formal_x = formal_group_2.x(precision)(parameter_2)
formal_y = formal_group_2.y(precision)(parameter_2)
point_x = infinity_image[0]
point_y = infinity_image[1]
addition_slope = (formal_y-point_y)/(formal_x-point_x)
x_series_2 = (
    addition_slope^2-point_x-formal_x
).add_bigoh(precision)
recovered_X2 = pade_reconstruct(x_series_2, 7, 7)

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

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B010",
    "verified": True,
    "method": "formal integration plus exact Pade reconstruction",
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
