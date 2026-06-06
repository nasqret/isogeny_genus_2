"""
Exact SageMath verification for claims C031-C033.

Run from the repository root:

    sage computations/sage/verify_degree2_j_twists.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter

started = perf_counter()
root = Path.cwd()

# C031: the two degree-2 maps in the generic even-sextic family.
B.<a, b> = PolynomialRing(QQ, 2)
KB = B.fraction_field()
R.<x> = PolynomialRing(KB)
Kx = R.fraction_field()

source_rhs = x^6 + a*x^4 + b*x^2 + 1
z1 = Kx(x^2)
w1_squared = Kx(source_rhs)
target1_rhs = z1^3 + a*z1^2 + b*z1 + 1
assert w1_squared == target1_rhs

z2 = Kx(x^-2)
w2_squared = Kx(source_rhs*x^-6)
target2_rhs = z2^3 + b*z2^2 + a*z2 + 1
assert w2_squared == target2_rhs

def rational_degree(function):
    return max(
        function.numerator().degree(),
        function.denominator().degree(),
    )

assert rational_degree(z1) == 2
assert rational_degree(z2) == 2

# C032: derive the critical-quartic j formulas for
# g=x^4+p*x^2+q*x, the affine-normalized generic quartic.
P.<p, q> = PolynomialRing(QQ, 2)
KP = P.fraction_field()
S.<X, Z> = PolynomialRing(KP, 2)
g = X^4 + p*X^2 + q*X
critical_discriminant = (g - Z).discriminant(X)

UZ.<z> = PolynomialRing(KP)
critical_cubic = UZ(critical_discriminant(X=0, Z=z))
leading = critical_cubic[3]
quadratic = critical_cubic[2]
linear = critical_cubic[1]
constant = critical_cubic[0]

# For w^2=A*z^3+B*z^2+C*z+D, set x=A*z and y=A*w.
critical_curve = EllipticCurve(
    KP,
    [0, quadratic, 0, leading*linear, leading^2*constant],
)
ramification_curve = EllipticCurve(KP, [0, 0, 0, p/2, q/4])

Us.<s> = PolynomialRing(KP)
self_fiber_quartic = -s^4 - 2*p*s^2 - 2*q*s
quartic_i = 4*p^2
quartic_discriminant = self_fiber_quartic.discriminant()
complement_j = KP(256*quartic_i^3/quartic_discriminant)

ramification_j = KP(ramification_curve.j_invariant())
critical_j = KP(critical_curve.j_invariant())
predicted_critical_j = KP(
    ramification_j*(ramification_j - 1536)^3
    / (2^18*(ramification_j - 1728))
)
predicted_complement_j = KP(
    ramification_j^2/(4*(ramification_j - 1728))
)

assert critical_j == predicted_critical_j
assert complement_j == predicted_complement_j

specializations = []
for p0, q0 in [(-8, 16), (1, 1), (2, 3)]:
    substitution = {p: QQ(p0), q: QQ(q0)}
    values = {
        "parameters": [int(p0), int(q0)],
        "ramification_j": str(ramification_j.subs(substitution)),
        "critical_j": str(critical_j.subs(substitution)),
        "complement_j": str(complement_j.subs(substitution)),
    }
    specializations.append(values)

# C033: the explicit degree-3 maps give nonconstant K(t)-points on both
# quadratic twists by the source sextic.
Qx.<t> = PolynomialRing(QQ)
Kt = Qx.fraction_field()
F = (
    t^6
    + QQ(19)/5*t^5
    + QQ(42)/5*t^4
    + QQ(309)/20*t^3
    + QQ(63)/4*t^2
    + 15*t
    + QQ(25)/4
)

den = t^3 + 3*t^2 + 4*t + 5
Z = Kt(t^2/den)
W = Kt((t^3 - 4*t - 10)/den^2)
f = Z^3 - QQ(84)/247*Z^2 + QQ(164)/247*Z - QQ(20)/247
assert -QQ(20)/247*F*W^2 == f

den_prime = t^3 + QQ(4)/5*t^2 + 2*t + QQ(5)/4
Zprime = Kt(
    (-6*t^3 - 6*t^2 - QQ(35)/4*t + QQ(25)/4)
    / den_prime
)
Wprime = Kt(
    (-3*t^3 + QQ(55)/2*t^2 + QQ(25)/2*t + QQ(125)/8)
    / den_prime^2
)
assert F*Wprime^2 == Zprime^3 + 25*Zprime + 375
assert Z.derivative() != 0
assert Zprime.derivative() != 0

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "claims": {
        "C031": {
            "verified": True,
            "first_map_degree": int(rational_degree(z1)),
            "second_map_degree": int(rational_degree(z2)),
            "certificate": "Both substitutions preserve the target equations over Q(a,b)(x).",
        },
        "C032": {
            "verified": True,
            "critical_formula": "j*(j-1536)^3/(2^18*(j-1728))",
            "complement_formula": "j^2/(4*(j-1728))",
            "specializations": specializations,
        },
        "C033": {
            "verified": True,
            "certificate": "The degree-3 maps define nonconstant points on both twists by F(t).",
            "Z_nonconstant": True,
            "Zprime_nonconstant": True,
        },
    },
}

output = root / "results" / "sage_degree2_j_twists.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
