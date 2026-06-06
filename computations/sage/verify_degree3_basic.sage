"""
Exact SageMath verification for claims C012, C013, C015, C018, and C020.

Run from the repository root:

    sage computations/sage/verify_degree3_basic.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter

started = perf_counter()
root = Path.cwd()

R.<x> = PolynomialRing(QQ)
K = R.fraction_field()

F = (
    x^6
    + QQ(19) / 5 * x^5
    + QQ(42) / 5 * x^4
    + QQ(309) / 20 * x^3
    + QQ(63) / 4 * x^2
    + 15 * x
    + QQ(25) / 4
)

den_pi = x^3 + 3 * x^2 + 4 * x + 5
Z = x^2 / den_pi
W = (x^3 - 4 * x - 10) / den_pi^2

z = polygen(QQ, "z")
elliptic_rhs = z^3 - QQ(84) / 247 * z^2 + QQ(164) / 247 * z - QQ(20) / 247

# C012: the displayed degree-3 cover preserves the elliptic equation
# -20/247*w^2 = z^3 - 84/247*z^2 + 164/247*z - 20/247.
cover_identity = K(-QQ(20) / 247 * F * W^2 - elliptic_rhs(Z))
assert cover_identity == 0
assert F.is_squarefree()

# C013: derive the equation in s_x=x1+x2 and p_x=x1*x2.
R2.<x1, x2> = PolynomialRing(QQ)
K2 = R2.fraction_field()

def Z2(value):
    return value^2 / (value^3 + 3 * value^2 + 4 * value + 5)

divided_Z = K2((Z2(x1) - Z2(x2)) / (x1 - x2))
sx = x1 + x2
px = x1 * x2
base_equation = sx - px^2 / 5 + 4 * px / 5
denominator_product = (
    (x1^3 + 3 * x1^2 + 4 * x1 + 5)
    * (x2^3 + 3 * x2^2 + 4 * x2 + 5)
)
assert divided_Z == 5 * base_equation / denominator_product

# C015: the normalized quartic is birational to the printed Weierstrass model.
S.<u, v> = PolynomialRing(QQ, 2)
quartic_rhs = u * (u^3 - 4 * u^2 + 15 * u - 25)
U = 5 - 25 / u
V = 25 * v / u^2
weierstrass_rhs = U^3 + 25 * U + 375
quartic_ideal = S.ideal([v^2 - quartic_rhs])
forward_numerator = S((V^2 - weierstrass_rhs) * u^4)
assert quartic_ideal.reduce(forward_numerator) == 0

T.<U0, V0> = PolynomialRing(QQ, 2)
inverse_u = -25 / (U0 - 5)
inverse_v = 25 * V0 / (U0 - 5)^2
inverse_check = (
    inverse_v^2
    - inverse_u * (inverse_u^3 - 4 * inverse_u^2 + 15 * inverse_u - 25)
)
weierstrass_ideal = T.ideal([V0^2 - (U0^3 + 25 * U0 + 375)])
inverse_numerator = T(inverse_check * (U0 - 5)^4)
assert weierstrass_ideal.reduce(inverse_numerator) == 0

Eprime = EllipticCurve(QQ, [0, 0, 0, 25, 375])
assert Eprime.discriminant() != 0

# C018: the printed complementary map preserves E'.
den_prime = x^3 + QQ(4) / 5 * x^2 + 2 * x + QQ(5) / 4
Zprime = (
    -6 * x^3 - 6 * x^2 - QQ(35) / 4 * x + QQ(25) / 4
) / den_prime
Wprime = (
    -3 * x^3 + QQ(55) / 2 * x^2 + QQ(25) / 2 * x + QQ(125) / 8
) / den_prime^2
complementary_map_identity = K(F * Wprime^2 - (Zprime^3 + 25 * Zprime + 375))
assert complementary_map_identity == 0

# C020: exact denominator factorization.
assert den_pi * den_prime == F

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "claims": {
        "C012": {
            "verified": True,
            "certificate": "-20/247*F*W^2 equals the displayed cubic evaluated at Z",
            "F_squarefree": True,
        },
        "C013": {
            "verified": True,
            "certificate": "(Z(x1)-Z(x2))/(x1-x2) = 5*(sx-px^2/5+4px/5)/(den1*den2)",
        },
        "C015": {
            "verified": True,
            "certificate": "U=5-25/u, V=25v/u^2 and its inverse identify the quartic with E'",
            "Eprime_discriminant": str(Eprime.discriminant()),
            "Eprime_j_invariant": str(Eprime.j_invariant()),
        },
        "C018": {
            "verified": True,
            "certificate": "F*Wprime^2 equals Zprime^3+25*Zprime+375",
        },
        "C020": {
            "verified": True,
            "certificate": "den_pi*den_prime equals F exactly",
        },
    },
}

output = root / "results" / "sage_degree3_basic.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
