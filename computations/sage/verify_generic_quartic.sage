"""
Universal SageMath verification for the generic critical-quartic cluster
C008-C011 in the affine-normalized family g=x^4+p*x^2+q*x.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_generic_quartic.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()

P.<p, q> = PolynomialRing(QQ, 2)
K = P.fraction_field()
R.<x, t, z> = PolynomialRing(K, 3)


def g(value):
    return value^4 + p*value^2 + q*value


# C008: the discriminant factorization for the fiber product.
critical_discriminant = (g(t) - z).discriminant(t)
divided_difference = (g(t) - g(x)) // (t - x)
fiber_polynomial = divided_difference.discriminant(t)
factorization_identity = R(
    critical_discriminant(z=g(x))
    - g(x).derivative(x)^2 * fiber_polynomial
)
assert factorization_identity == 0

expected_fiber = -(
    16*x^6
    + 32*p*x^4
    + 40*q*x^3
    + 20*p^2*x^2
    + 36*p*q*x
    + 4*p^3
    + 27*q^2
)
assert fiber_polynomial == expected_fiber

# C009: exact nondegeneracy conditions for the smooth genus-2 model.
fiber_discriminant_raw = fiber_polynomial.discriminant(x)
derivative_discriminant_raw = g(x).derivative(x).discriminant(x)
critical_cubic_discriminant_raw = critical_discriminant.discriminant(z)

expected_fiber_discriminant = -2^29*q^2*(8*p^3 + 27*q^2)^4
expected_derivative_discriminant = -16*(8*p^3 + 27*q^2)
expected_critical_discriminant = -2^16*q^2*(8*p^3 + 27*q^2)^3
assert fiber_discriminant_raw == R(expected_fiber_discriminant)
assert derivative_discriminant_raw == R(expected_derivative_discriminant)
assert critical_cubic_discriminant_raw == R(expected_critical_discriminant)

fiber_discriminant = factor(expected_fiber_discriminant)
derivative_discriminant = factor(expected_derivative_discriminant)
critical_cubic_discriminant = factor(expected_critical_discriminant)

Rx.<X> = PolynomialRing(K)
fiber_univariate = Rx(fiber_polynomial(X, 0, 0))
assert fiber_univariate.degree() == 6
assert fiber_univariate.is_squarefree()
fiber_curve = HyperellipticCurve(fiber_univariate)
assert fiber_curve.genus() == 2

# C010: the displayed map (x,y)->(g(x),y*g'(x)) preserves E_g.
map_identity = R(
    fiber_polynomial * g(x).derivative(x)^2
    - critical_discriminant(z=g(x))
)
assert map_identity == 0

# C011: normalize the off-diagonal self-fiber product.
S.<u, v> = PolynomialRing(K, 2)
self_fiber = S((g(u) - g(v)) // (u - v))
expected_self_fiber = (
    u^3 + u^2*v + u*v^2 + v^3 + p*(u + v) + q
)
assert self_fiber == expected_self_fiber

T.<s, Y> = PolynomialRing(K, 2)
quartic_rhs = -s^4 - 2*p*s^2 - 2*q*s
u_inverse = (s + Y/s)/2
v_inverse = (s - Y/s)/2

# The maps s=u+v, Y=s(u-v) and their inverse identify the plane
# self-fiber curve birationally with Y^2=quartic_rhs.
forward_relation = T.ideal([Y^2 - quartic_rhs])
inverse_self_fiber = self_fiber(u_inverse, v_inverse)
inverse_numerator = T(inverse_self_fiber * 4*s)
assert forward_relation.reduce(inverse_numerator) == 0

U.<u0, v0> = PolynomialRing(K, 2)
s_forward = u0 + v0
Y_forward = (u0 + v0)*(u0 - v0)
quartic_forward = U(Y_forward^2 - quartic_rhs(s_forward, 0))
self_fiber_ideal = U.ideal(
    [u0^3 + u0^2*v0 + u0*v0^2 + v0^3 + p*(u0 + v0) + q]
)
assert self_fiber_ideal.reduce(quartic_forward) == 0

quartic_univariate = Rx(-X^4 - 2*p*X^2 - 2*q*X)
expected_quartic_discriminant = -16*q^2*(8*p^3 + 27*q^2)
assert quartic_univariate.discriminant() == K(expected_quartic_discriminant)
quartic_discriminant = factor(expected_quartic_discriminant)
quartic_curve = HyperellipticCurve(quartic_univariate)
assert quartic_curve.genus() == 1

# Classical binary-quartic invariant gives the generic complementary j.
quartic_I = 4*p^2
complement_j_raw = K(256*quartic_I^3/expected_quartic_discriminant)
expected_complement_j_raw = K(
    -1024*p^6/(q^2*(8*p^3 + 27*q^2))
)
assert complement_j_raw == expected_complement_j_raw
complement_j = factor(complement_j_raw)

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "family": "g=x^4+p*x^2+q*x over Q(p,q)",
    "nondegeneracy": "q*(8*p^3+27*q^2) != 0",
    "claims": {
        "C008": {
            "verified": True,
            "certificate": "Disc(g(t)-g(x))=g'(x)^2*Disc((g(t)-g(x))/(t-x))",
            "fiber_polynomial": str(fiber_univariate),
        },
        "C009": {
            "verified": True,
            "fiber_discriminant": str(fiber_discriminant),
            "critical_cubic_discriminant": str(
                critical_cubic_discriminant
            ),
            "degree": int(fiber_univariate.degree()),
            "genus": int(fiber_curve.genus()),
        },
        "C010": {
            "verified": True,
            "certificate": "Substitution of (g(x),y*g'(x)) preserves E_g.",
        },
        "C011": {
            "verified": True,
            "self_fiber_equation": str(expected_self_fiber),
            "normalized_quartic": str(quartic_univariate),
            "quartic_discriminant": str(quartic_discriminant),
            "genus": int(quartic_curve.genus()),
            "complement_j": str(complement_j),
        },
    },
}

output = root / "results" / "sage_generic_quartic.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
