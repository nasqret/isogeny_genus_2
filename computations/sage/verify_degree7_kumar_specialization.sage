"""
Exact degree-7 evidence from a rational specialization of Kumar's Y_-(49).

The one-parameter family is the rational curve r=4/(5s) in the degree-7
Hilbert modular surface.  We specialize at s=1, recover the two rational
j-invariants, choose the globally compatible quadratic twists, and verify
the factorization of the genus-2 Frobenius polynomial at every good prime
11 <= p < 200.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_degree7_kumar_specialization.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()

U.<u> = PolynomialRing(QQ)
Ku = U.fraction_field()

# Kumar's two j-invariants on the rational curve r=4/(5u).
degree5_factor = (
    u^5 + 150*u^4 + 520*u^3 + 240*u^2 + 80*u - 32
)
j1_family = Ku(
    QQ(25)/16
    * (u - QQ(2)/25)
    * degree5_factor^3
    / ((u - 4)^7*u^5*(u + 1)^3)
)
j2_family = Ku(
    -QQ(9765625)/64
    * (u - QQ(2)/25)^2
    * (u^2 + QQ(28)/25*u + QQ(4)/25)^3
    / (u^2*(u + 1))
)

parameter = QQ(1)
j1 = QQ(j1_family(u=parameter))
j2 = QQ(j2_family(u=parameter))
assert j1 == -QQ(20285403817)/279936
assert j2 == -QQ(97967097)/128

R.<x> = PolynomialRing(QQ)
s = parameter
cubic1 = (
    x^3
    + (25*s - 2)*x^2
    - 8*(s - 4)*(25*s - 2)*x
    - 20*(s - 4)*(12*s + 1)*(25*s - 2)
)
cubic2 = (
    x^3
    - QQ(2)/5*(25*s - 2)*x^2
    - QQ(1)/4*(11*s - 142)*(25*s - 2)*x
    - QQ(5)/4*(25*s - 2)*(3*s^2 + 368*s - 148)
)
source_polynomial = cubic1*cubic2
assert source_polynomial.is_squarefree()
source_curve = HyperellipticCurve(source_polynomial)
assert source_curve.genus() == 2

# j determines an elliptic curve only up to quadratic twist.  These twists
# are the unique small square classes compatible with the Euler factors.
E1 = EllipticCurve_from_j(j1).quadratic_twist(-115)
E2 = EllipticCurve_from_j(j2).quadratic_twist(5)
assert E1.j_invariant() == j1
assert E2.j_invariant() == j2

prime_certificates = []
for prime in prime_range(11, 200):
    if (
        source_polynomial.discriminant() % prime == 0
        or E1.discriminant() % prime == 0
        or E2.discriminant() % prime == 0
    ):
        continue
    finite_source = HyperellipticCurve(
        source_polynomial.change_ring(GF(prime))
    )
    source_frobenius = finite_source.frobenius_polynomial()
    trace1 = prime + 1 - E1.change_ring(GF(prime)).cardinality()
    trace2 = prime + 1 - E2.change_ring(GF(prime)).cardinality()
    T = source_frobenius.parent().gen()
    expected = (
        (T^2 - trace1*T + prime)
        * (T^2 - trace2*T + prime)
    )
    assert source_frobenius == expected
    prime_certificates.append(
        {
            "prime": int(prime),
            "trace_E1": int(trace1),
            "trace_E2": int(trace2),
            "frobenius_polynomial": str(source_frobenius),
        }
    )

assert len(prime_certificates) == 41

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B008",
    "verified": True,
    "degree": int(7),
    "source": {
        "family_parameter": "u=1 on r=4/(5u)",
        "cubic1": str(cubic1),
        "cubic2": str(cubic2),
        "polynomial": str(source_polynomial),
        "genus": int(2),
        "discriminant_factorization": str(
            factor(source_polynomial.discriminant())
        ),
    },
    "elliptic_factors": [
        {
            "j": str(j1),
            "twist_square_class": int(-115),
            "model": str(E1),
            "conductor": int(E1.conductor()),
        },
        {
            "j": str(j2),
            "twist_square_class": int(5),
            "model": str(E2),
            "conductor": int(E2.conductor()),
        },
    ],
    "evidence": {
        "type": "Euler-factor equality at all good primes in [11,200)",
        "tested_prime_count": len(prime_certificates),
        "prime_certificates": prime_certificates,
    },
    "scope_note": (
        "This certifies the expected split isogeny class at a dense finite "
        "set of reductions.  Constructing and certifying the two degree-7 "
        "maps over Q remains a separate workstream."
    ),
}

output = root / "results" / "sage_degree7_kumar_specialization.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
