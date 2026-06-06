"""
Exact SageMath verification for claims C021-C025.

Run from the repository root:

    sage computations/sage/verify_degree4_example.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter

started = perf_counter()
root = Path.cwd()

# C021: derive the critical elliptic curve and reduced fiber-product model.
R.<x, t, z> = PolynomialRing(QQ, 3)

def g(value):
    return value^4 - 8*value^2 + 16*value

critical_discriminant = (g(t) - z).discriminant(t)
critical_cubic = z^3 + 32*z^2 - 896*z + 4864
assert critical_discriminant == -256*critical_cubic

divided_difference = (g(t) - g(x)) // (t - x)
fiber_discriminant = divided_difference.discriminant(t)
fiber_polynomial = (
    x^6
    - 16*x^4
    + 40*x^3
    + 80*x^2
    - 288*x
    + 304
)
assert fiber_discriminant == -16*fiber_polynomial
assert fiber_polynomial.degree(x) == 6
assert fiber_polynomial.gcd(fiber_polynomial.derivative(x)) == 1

Rx.<x0> = PolynomialRing(QQ)
fiber_univariate = Rx(
    x0^6
    - 16*x0^4
    + 40*x0^3
    + 80*x0^2
    - 288*x0
    + 304
)
Cg = HyperellipticCurve(-fiber_univariate)
assert Cg.genus() == 2

# The general discriminant models use w=y*g'(x). After the example's
# rescalings w_original=16*w and y_original=4*y, this becomes w=y*g'(x)/4.
map_identity = (
    fiber_polynomial*(g(x).derivative(x)/4)^2
    - critical_cubic(z=g(x))
)
assert map_identity == 0

# C022: normalize the self-fiber-product cubic.
S.<u, v> = PolynomialRing(QQ, 2)
self_fiber = (
    u^3 + u^2*v + u*v^2 + v^3 - 8*u - 8*v + 16
)
s = u + v
d = u - v
p = u*v
assert self_fiber == s^3 - 2*p*s - 8*s + 16

# On self_fiber=0, p=(s^3-8s+16)/(2s). With Y=s(u-v),
# this gives Y^2=-s^4+16s^2-32s.
Q.<s0, Y> = PolynomialRing(QQ, 2)
quartic_rhs = -s0^4 + 16*s0^2 - 32*s0

target_x = 12 - 72/s0
target_y = -108*Y/s0^2
target_rhs = target_x^3 - 432*target_x - 8208
quartic_ideal = Q.ideal([Y^2 - quartic_rhs])
forward_numerator = Q((target_y^2 - target_rhs)*s0^4)
assert quartic_ideal.reduce(forward_numerator) == 0

T.<X0, Y0> = PolynomialRing(QQ, 2)
inverse_s = -72/(X0 - 12)
inverse_Y = -48*Y0/(X0 - 12)^2
inverse_expression = (
    inverse_Y^2
    - (
        -inverse_s^4
        + 16*inverse_s^2
        - 32*inverse_s
    )
)
target_ideal = T.ideal([Y0^2 - (X0^3 - 432*X0 - 8208)])
inverse_numerator = T(inverse_expression*(X0 - 12)^4)
assert target_ideal.reduce(inverse_numerator) == 0

Eprime = EllipticCurve(QQ, [0, 0, 0, -432, -8208])
assert Eprime.discriminant() != 0

# C023 and C024: identify the untwisted curve and certify its arithmetic.
untwisted = Eprime.quadratic_twist(-1).minimal_model()
assert untwisted.cremona_label() == "11a3"
database_curve = EllipticCurve("11a3")
assert untwisted.is_isomorphic(database_curve)
assert database_curve.rank(proof=True) == 0
torsion = database_curve.torsion_subgroup()
assert torsion.invariants() == (5,)

# C025: the ramification curve u^2=g'(x) has the displayed j-invariant.
# Dividing its y-coordinate by 2 gives y^2=x^3-4x+4.
ramification_curve = EllipticCurve(QQ, [0, 0, 0, -4, 4])
assert ramification_curve.j_invariant() == -QQ(27648)/11

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "claims": {
        "C021": {
            "verified": True,
            "critical_discriminant_factor": "-256",
            "fiber_discriminant_factor": "-16",
            "fiber_polynomial": str(fiber_univariate),
            "fiber_squarefree": True,
            "genus": int(Cg.genus()),
        },
        "C022": {
            "verified": True,
            "self_fiber_quartic": str(quartic_rhs),
            "forward_map": "x=12-72/s, y=-108*Y/s^2",
            "target": "y^2=x^3-432*x-8208",
        },
        "C023": {
            "verified": True,
            "untwisted_minimal_model": str(untwisted),
            "cremona_label": untwisted.cremona_label(),
        },
        "C024": {
            "verified": True,
            "rank": int(database_curve.rank(proof=True)),
            "torsion_invariants": [int(value) for value in torsion.invariants()],
        },
        "C025": {
            "verified": True,
            "ramification_model": "y^2=x^3-4*x+4",
            "j_invariant": str(ramification_curve.j_invariant()),
        },
    },
}

output = root / "results" / "sage_degree4_example.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
