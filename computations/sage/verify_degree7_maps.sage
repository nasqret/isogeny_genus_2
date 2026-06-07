"""
Exact primitive degree-7 maps for the u=1 Kumar benchmark (B008/B010).

The first map is reconstructed at infinity from the eigenform dx/y.  Its
trace-zero complementary eigenform is x dx/y.  The second map is reconstructed
at the finite target point -7*(29,-590) on the second elliptic factor.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_degree7_maps.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()

R.<x> = PolynomialRing(QQ)
F1 = x^3 + 23*x^2 + 552*x + 17940
F2 = (
    x^3
    - QQ(46)/5*x^2
    + QQ(3013)/4*x
    - QQ(25645)/4
)
source_polynomial = F1*F2
source_curve = HyperellipticCurve(source_polynomial)
assert source_curve.genus() == 2

E1_original = EllipticCurve(
    [1, 0, 0, -6077163, -5835183183]
)
E2_original = EllipticCurve(
    [1, -1, 1, -15705, 762297]
)
E1 = E1_original.short_weierstrass_model()
E2 = E2_original.short_weierstrass_model()
assert E1 == EllipticCurve(
    [0, 0, 0, -7876003275, -272222678576250]
)
assert E2 == EllipticCurve(
    [0, 0, 0, -20353275, 35382561750]
)

# The first eigenmap.  The absent x^6 coefficient is also the exact
# trace-zero certificate for the complementary eigenform x*dx/y.
c1 = QQ(49)/12
A1 = (
    x^7
    + QQ(2415)/2*x^5
    + QQ(7245)/2*x^4
    + QQ(41306965)/192*x^3
    + QQ(393877001)/96*x^2
    - QQ(90651235955)/768*x
    + QQ(1179635972075)/768
)
B1 = F2
X1 = QQ(576)/2401*A1/B1
Y1_multiplier = X1.derivative()/(2*c1)

assert A1[6] == 0
assert B1.degree() == 3
assert (
    source_polynomial*X1.derivative()^2
    == 4*c1^2*(X1^3 + E1.a4()*X1 + E1.a6())
)
assert (
    source_polynomial*Y1_multiplier^2
    == X1^3 + E1.a4()*X1 + E1.a6()
)

# The complementary eigenmap.  The chosen positive branch at infinity maps
# to -7 times the Mordell-Weil generator on the original E2 model.
c2 = -QQ(49)/60
quadratic_pole_factor = (
    x^2 - QQ(115)/24*x + QQ(7475)/24
)
A2 = (
    QQ(10465)/4*x^7
    + QQ(197225)/8*x^6
    + QQ(164727955)/64*x^5
    + QQ(1305770375)/64*x^4
    + QQ(36305600625)/64*x^3
    - QQ(1306013384375)/64*x^2
    - QQ(232046932796875)/16
)
B2 = F1*quadratic_pole_factor^2
X2 = A2/B2
Y2_multiplier = X2.derivative()/(2*c2*x)

assert B2.degree() == 7
assert B2 == F1*quadratic_pole_factor^2
assert (
    source_polynomial*X2.derivative()^2
    == 4*c2^2*x^2*(X2^3 + E2.a4()*X2 + E2.a6())
)
assert (
    source_polynomial*Y2_multiplier^2
    == X2^3 + E2.a4()*X2 + E2.a6()
)


def rational_degree(value):
    return max(
        value.numerator().degree(),
        value.denominator().degree(),
    )


assert rational_degree(X1) == 7
assert rational_degree(X2) == 7

# Check the finite image of the positive point at infinity for the second map.
prec = 8
S.<t> = PowerSeriesRing(QQ, default_prec=prec)
source_at_infinity = S(
    sum(source_polynomial[i]*t^(6-i) for i in range(7))
)
positive_y_at_infinity = t^-3*source_at_infinity.sqrt()
X2_at_infinity = X2(x=1/t)
Y2_at_infinity = (
    Y2_multiplier(x=1/t)*positive_y_at_infinity
)
assert X2_at_infinity[0] == QQ(10465)/4
assert Y2_at_infinity[0] == -QQ(51175)/8

generator = E2_original.gens()[0]
short_isomorphism = E2_original.isomorphism_to(E2)
infinity_image = short_isomorphism(-7*generator)
assert infinity_image == E2(
    QQ(10465)/4, -QQ(51175)/8
)

# A prime degree map from a genus-2 curve to a genus-1 curve cannot factor
# nontrivially through another curve, so both degree-7 covers are primitive.
assert Integer(7).is_prime()

elapsed = perf_counter() - started
maps = [
    {
        "label": "f1",
        "target_model": str(E1),
        "target_j": str(E1.j_invariant()),
        "degree": int(rational_degree(X1)),
        "differential_pullback": "(49/12) dx/y",
        "x_coordinate": str(X1),
        "y_multiplier": str(Y1_multiplier),
        "pole_denominator_factorization": str(factor(B1)),
        "trace_zero_complement": "Tr(x)=0 from the absent x^6 term",
    },
    {
        "label": "f2",
        "target_model": str(E2),
        "target_j": str(E2.j_invariant()),
        "degree": int(rational_degree(X2)),
        "differential_pullback": "(-49/60) x dx/y",
        "x_coordinate": str(X2),
        "y_multiplier": str(Y2_multiplier),
        "pole_denominator_factorization": str(factor(B2)),
        "positive_infinity_image": [
            str(infinity_image[0]),
            str(infinity_image[1]),
        ],
        "mordell_weil_description": "-7*(29,-590) on the original model",
    },
]

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstreams": ["B008", "B010"],
    "verified": True,
    "source_polynomial": str(source_polynomial),
    "source_genus": int(source_curve.genus()),
    "maps": maps,
    "certificate": (
        "For each map X=A/B and Y=y*dX/(2*c*l), Sage verifies "
        "F*(dX/dx)^2=4*c^2*l^2*(X^3+a4*X+a6) identically over Q(x)."
    ),
    "primitive": True,
}

output = root / "results" / "sage_degree7_maps.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
