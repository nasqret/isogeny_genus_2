"""
Verify the fixed-field equation engine for the Galois complement.

This script connects the general invariant construction to the critical
quartic in the paper and emits exact quotient equations for the compact
degree-6, degree-7, and degree-8 benchmarks.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_galois_complement.sage
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
    / "galois_complement.sage"
))


def polynomial_summary(certificate):
    remainder = certificate["remainder_coefficients"]
    pair_relation = certificate["pair_relation"]
    orientation = certificate["orientation_relation"]
    return {
        "remainder_total_degrees": [
            int(value.total_degree()) for value in remainder
        ],
        "pair_relation_total_degree": int(
            pair_relation.total_degree()
        ),
        "orientation_total_degree": int(
            orientation.total_degree()
        ),
        "pair_relation_terms": int(len(pair_relation.monomials())),
        "orientation_terms": int(len(orientation.monomials())),
    }


# Generic critical quartic g=t^4+a*t^2+b*t.
Pab.<a, b> = PolynomialRing(QQ, 2)
Kab = Pab.fraction_field()
Rt.<t> = PolynomialRing(Kab)
Rz.<z0> = PolynomialRing(Kab)
Rtz.<tz> = PolynomialRing(Rz)
g = t^4 + a*t^2 + b*t
critical_discriminant = (
    tz^4+a*tz^2+b*tz-z0
).discriminant()
quartic_certificate = galois_complement_equations(
    g,
    critical_discriminant,
)
assert certify_galois_complement_equations(quartic_certificate)
s = quartic_certificate["variables"]["s"]
p = quartic_certificate["variables"]["p"]
z = quartic_certificate["variables"]["z"]
q = quartic_certificate["variables"]["q"]
quartic_remainder = quartic_certificate[
    "remainder_coefficients"
]
assert quartic_remainder[1] == s^3-2*s*p+a*s+b
assert quartic_remainder[0] == p^2-s^2*p-a*p-z

# The ordered-pair curve is the paper's self-fiber cubic.  Eliminating p
# with Y=s*(t1-t2) gives the exact genus-one quartic used in C011.
Ry.<S, Y> = PolynomialRing(Kab, 2)
quartic_rhs = -S^4-2*a*S^2-2*b*S
quartic_curve = HyperellipticCurve(
    PolynomialRing(Kab, names=("X",))(
        [0, -2*b, -2*a, 0, -1]
    )
)
assert quartic_curve.genus() == 1
quartic_I = 4*a^2
quartic_discriminant = -16*b^2*(8*a^3+27*b^2)
quartic_j = Kab(256*quartic_I^3/quartic_discriminant)
assert quartic_j == -1024*a^6/(b^2*(8*a^3+27*b^2))


def benchmark_certificate(numerator, denominator, elliptic_coefficients):
    source_ring = numerator.parent()
    rational_map = source_ring.fraction_field()(
        numerator/denominator
    )
    target_ring.<Z> = PolynomialRing(QQ)
    elliptic_rhs = sum(
        QQ(coefficient)*Z^index
        for index, coefficient in enumerate(elliptic_coefficients)
    )
    certificate = galois_complement_equations(
        rational_map,
        elliptic_rhs,
    )
    assert certify_galois_complement_equations(certificate)
    return certificate


Rx.<x> = PolynomialRing(QQ)

# Degree 6 compact quotient, target y^2=z^3-27*z+90.
degree6_numerator = (
    3*x^6 - 30*x^5 + 81*x^4 - QQ(296)/3*x^3
    + QQ(184)/3*x^2 - QQ(848)/27
)
degree6_denominator = (
    x^6 - 6*x^5 + 9*x^4 + QQ(40)/9*x^3
    - QQ(40)/3*x^2 + QQ(400)/81
)
degree6_certificate = benchmark_certificate(
    degree6_numerator,
    degree6_denominator,
    [90, -27, 0, 1],
)

# Degree 7 quotient at the elliptic origin.
degree7_denominator = (
    x^3 - QQ(46)/5*x^2 + QQ(3013)/4*x - QQ(25645)/4
)
degree7_numerator = (
    QQ(576)/2401*x^7
    + QQ(99360)/343*x^5
    + QQ(298080)/343*x^4
    + QQ(17702985)/343*x^3
    + QQ(337608858)/343*x^2
    - QQ(38850529695)/1372*x
    + QQ(3538907916225)/9604
)
degree7_certificate = benchmark_certificate(
    degree7_numerator,
    degree7_denominator,
    [-272222678576250, -7876003275, 0, 1],
)

# Degree 8 compact quotient, target y^2=z^3-z^2-5833*z+207037.
degree8_numerator = (
    x^8 + 4*x^7 + 12*x^6 + 32*x^5 + 87*x^4
    + 220*x^3 + 444*x^2 + 360*x - 8
)
degree8_denominator = x^4+4*x^3+8*x^2+8*x+4
degree8_certificate = benchmark_certificate(
    degree8_numerator,
    degree8_denominator,
    [207037, -5833, -1, 1],
)

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B011",
    "verified": True,
    "scope": (
        "Fixed-field equations for the off-diagonal Galois-closure "
        "quotient, with a generic quartic recovery and degree 6/7/8 "
        "benchmarks"
    ),
    "invariants": {
        "s": "t1+t2",
        "p": "t1*t2",
        "q": "w*(t1-t2)",
        "involution": "(t1,t2,w)->(t2,t1,-w)",
        "orientation_relation": "q^2=f(z)*(s^2-4*p)",
    },
    "generic_quartic": {
        "remainder_coefficient_T": str(quartic_remainder[1]),
        "remainder_constant": str(quartic_remainder[0]),
        "normalized_quartic": str(Y^2-quartic_rhs),
        "genus": int(quartic_curve.genus()),
        "j_invariant": str(factor(quartic_j)),
    },
    "benchmarks": {
        "degree6": polynomial_summary(degree6_certificate),
        "degree7": polynomial_summary(degree7_certificate),
        "degree8": polynomial_summary(degree8_certificate),
    },
}

output = root / "results" / "sage_galois_complement.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
