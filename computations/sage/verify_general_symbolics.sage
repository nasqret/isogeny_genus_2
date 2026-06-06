"""
Universal SageMath verification for the symmetric-square identities in C001
and the trace rewriting identity in C002.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_general_symbolics.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()

# Work over the coefficient field of a universal sextic and a universal
# bidegree-(2,2) polynomial g1(x1,x2).
coefficient_names = [
    *(f"a{i}" for i in range(7)),
    *(f"c{i}{j}" for i in range(3) for j in range(3)),
]
A = PolynomialRing(QQ, coefficient_names)
K = A.fraction_field()
a = [K(A(f"a{i}")) for i in range(7)]
c = {
    (i, j): K(A(f"c{i}{j}"))
    for i in range(3)
    for j in range(3)
}

R.<x1, x2, y1, y2> = PolynomialRing(K, 4)


def F(value):
    return sum(a[i] * value^i for i in range(7))


F1 = F(x1)
F2 = F(x2)
sx = x1 + x2
px = x1 * x2
sy = y1 + y2
py = y1 * y2


def substitute(poly, images):
    return R(poly(*images))


r_images = (x2, x1, y2, -y1)
s_images = (x2, x1, y2, y1)


def apply_r(poly):
    return substitute(poly, r_images)


def apply_s(poly):
    return substitute(poly, s_images)


def iterate(action, poly, count):
    result = R(poly)
    for _ in range(count):
        result = action(result)
    return result


# C001: the displayed automorphisms satisfy the D4 presentation.
for generator in R.gens():
    assert iterate(apply_r, generator, 4) == generator
    assert iterate(apply_s, generator, 2) == generator
    assert apply_s(apply_r(apply_s(generator))) == iterate(
        apply_r, generator, 3
    )

# The four displayed symmetric generators are fixed by s.
for invariant in (sx, px, sy, py):
    assert apply_s(invariant) == invariant

# Express the universal symmetric sum and product in sx,px.
B.<S, P> = PolynomialRing(K, 2)
power_sums = [B(2), S]
for degree in range(2, 7):
    power_sums.append(S * power_sums[-1] - P * power_sums[-2])
Fsum_symmetric = sum(a[i] * power_sums[i] for i in range(7))

BT.<T> = PolynomialRing(B)
quadratic = T^2 - S*T + P
F_universal = sum(B(a[i]) * T^i for i in range(7))
Fproduct_symmetric = quadratic.resultant(F_universal)

assert R(Fsum_symmetric(sx, px)) == F1 + F2
assert R(Fproduct_symmetric(sx, px)) == F1 * F2

# The two defining relations of the symmetric square.
relation_sum = sy^2 - F1 - F2 - 2*py
relation_product = py^2 - F1*F2


def reduce_squares(poly):
    reduced = R.zero()
    for exponents, coefficient in R(poly).dict().items():
        ex1, ex2, ey1, ey2 = exponents
        reduced += (
            coefficient
            * x1^ex1
            * x2^ex2
            * y1^(ey1 % 2)
            * y2^(ey2 % 2)
            * F1^(ey1 // 2)
            * F2^(ey2 // 2)
        )
    return R(reduced)


assert reduce_squares(relation_sum) == 0
assert reduce_squares(relation_product) == 0

# C002: verify the trace-method identity for a universal polynomial g1.
g1 = sum(c[i, j] * x1^i * x2^j for i in range(3) for j in range(3))
g1_swap = apply_s(g1)
denominator = F1 - F2
h1_numerator = g1*F1 - g1_swap*F2
h2_numerator = g1 - g1_swap

# Both h1 and h2 are symmetric rational functions.
assert apply_s(h1_numerator) == -h1_numerator
assert apply_s(h2_numerator) == -h2_numerator
assert apply_s(denominator) == -denominator

trace_identity_numerator = (
    (g1*y1 + g1_swap*y2) * denominator
    - h1_numerator * sy
    + h2_numerator * py * sy
)
assert reduce_squares(trace_identity_numerator) == 0

# Verify the full A1+A2*py+B1*sy+B2*py*sy decomposition on a universal
# symmetric test element. The nontrivial B terms are exactly the identity
# above; A1 and A2 are independent universal symmetric polynomials.
d0, d1, d2, e0, e1, e2 = K.gens()[:6]
A1 = d0 + d1*sx + d2*px
A2 = e0 + e1*sx + e2*px
test_element = A1 + A2*py + g1*y1 + g1_swap*y2
rewritten = (
    A1
    + A2*py
    + (h1_numerator/denominator)*sy
    - (h2_numerator/denominator)*py*sy
)
cleared_difference = R((test_element - rewritten)*denominator)
assert reduce_squares(cleared_difference) == 0

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "claims": {
        "C001": {
            "verified": True,
            "coefficient_field": "Q(a0,...,a6)",
            "certificates": [
                "r^4=s^2=1 and s*r*s=r^-1 on all four generators",
                "sx,px,sy,py are fixed by the transposition s",
                "universal sextic sum and product are expressed in sx,px",
                "sy^2=F(x1)+F(x2)+2py and py^2=F(x1)F(x2)",
            ],
        },
        "C002": {
            "verified": True,
            "coefficient_field": "Q(a0,...,a6,c00,...,c22)",
            "certificate": (
                "The trace identity and A1+A2*py+B1*sy+B2*py*sy "
                "decomposition hold for a universal bidegree-(2,2) g1."
            ),
        },
    },
}

output = root / "results" / "sage_general_symbolics.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
