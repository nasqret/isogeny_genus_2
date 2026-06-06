"""
Exact SageMath certificates for claims C005, C035, C036, C039, and C040.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_structural_claims.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()


# C005: normalization of y^2=q(t) by removing square factors.
def squarefree_normalization(q):
    """Return H and r with q=H*r^2 and H=num_sf*den_sf."""
    Kt = q.parent()
    Rt = Kt.ring()
    numerator = Rt(q.numerator())
    denominator = Rt(q.denominator())
    common = numerator.gcd(denominator)
    numerator //= common
    denominator //= common

    def split_rational_square(unit):
        unit = QQ(unit)
        sign = -1 if unit < 0 else 1
        numerator = ZZ(abs(unit.numerator()))
        denominator = ZZ(unit.denominator())

        def split_integer(value):
            core = ZZ.one()
            square = ZZ.one()
            for prime, exponent in value.factor():
                core *= prime^(exponent % 2)
                square *= prime^(exponent // 2)
            return core, square

        numerator_core, numerator_square = split_integer(numerator)
        denominator_core, denominator_square = split_integer(denominator)
        core = QQ(sign*numerator_core/denominator_core)
        square = QQ(numerator_square/denominator_square)
        assert unit == core*square^2
        return core, square

    def split_squares(poly):
        factorization = poly.factor()
        unit_core, unit_square = split_rational_square(
            factorization.unit()
        )
        core = Rt(unit_core)
        square = Rt(unit_square)
        for factor, exponent in factorization:
            core *= factor^(exponent % 2)
            square *= factor^(exponent // 2)
        assert poly == core*square^2
        return core, square

    numerator_core, numerator_square = split_squares(numerator)
    denominator_core, denominator_square = split_squares(denominator)
    normalized = numerator_core*denominator_core
    scaling = Kt(
        numerator_square/(denominator_square*denominator_core)
    )
    assert q == Kt(normalized)*scaling^2
    assert normalized.is_squarefree()
    return normalized, scaling


Rt.<t> = PolynomialRing(QQ)
Kt = Rt.fraction_field()
paper_square = (
    t^4 - 10*t^3 + 32*t^2 - QQ(189)/2*t + 150
)
paper_q = Kt(
    t*(t^3 - 4*t^2 + 15*t - 25)*paper_square^2/5^6
)
paper_normalized, paper_scaling = squarefree_normalization(paper_q)
expected_paper_normalized = t*(t^3 - 4*t^2 + 15*t - 25)
assert paper_normalized == expected_paper_normalized
assert paper_scaling == Kt(paper_square/5^3)

normalization_tests = [
    Kt(2*(t - 1)^3*(t + 3)^2/(3*(t + 2)^4)),
    Kt((t^2 + 1)^5/((t - 4)^3*(t + 7)^2)),
    Kt(-5*(t^3 - 2*t + 2)^2/(7*(t^2 + t + 1)^3)),
]
for test_q in normalization_tests:
    squarefree_normalization(test_q)


# C035: Kuhn's universal degree-3 x-coordinate gives an equation linear in sx.
B3.<a3, b3, c3> = PolynomialRing(QQ, 3)
K3 = B3.fraction_field()
R3.<x1, x2> = PolynomialRing(K3, 2)
Kx12 = R3.fraction_field()


def kuhn_z(value):
    return value^2/(value^3 + a3*value^2 + b3*value + c3)


kuhn_divided = Kx12((kuhn_z(x1) - kuhn_z(x2))/(x1 - x2))
kuhn_denominator = (
    (x1^3 + a3*x1^2 + b3*x1 + c3)
    * (x2^3 + a3*x2^2 + b3*x2 + c3)
)
sx = x1 + x2
px = x1*x2
kuhn_base_equation = c3*sx - px^2 + b3*px
assert kuhn_divided*kuhn_denominator == kuhn_base_equation
assert R3(kuhn_base_equation).degree(x1) > 0


# C036: the critical cubic is elliptic exactly when the ramification
# j-invariant is neither 1728 nor infinity.
P4.<p, q> = PolynomialRing(QQ, 2)
K4 = P4.fraction_field()
ramification_curve = EllipticCurve(K4, [0, 0, 0, p/2, q/4])
ramification_j = K4(ramification_curve.j_invariant())
delta = 8*p^3 + 27*q^2
assert ramification_j == K4(13824*p^3/delta)
assert K4(ramification_j - 1728) == K4(-46656*q^2/delta)

R4.<X, Z> = PolynomialRing(K4, 2)
g = X^4 + p*X^2 + q*X
critical_discriminant = (g - Z).discriminant(X)
Rz.<z> = PolynomialRing(K4)
critical_cubic = Rz(critical_discriminant(X=0, Z=z))
leading = critical_cubic[3]
critical_curve = EllipticCurve(
    K4,
    [
        0,
        critical_cubic[2],
        0,
        leading*critical_cubic[1],
        leading^2*critical_cubic[0],
    ],
)
critical_curve_discriminant = K4(critical_curve.discriminant())
assert critical_curve_discriminant == K4(-2^36*q^2*delta^3)


# C039: the map (a,b) -> (j(E),j(E')) is dominant.
B2.<a, b> = PolynomialRing(QQ, 2)
K2 = B2.fraction_field()
E = EllipticCurve(K2, [0, a, 0, b, 1])
Eprime = EllipticCurve(K2, [0, b, 0, a, 1])
j1 = K2(E.j_invariant())
j2 = K2(Eprime.j_invariant())
jacobian = K2(
    j1.derivative(a)*j2.derivative(b)
    - j1.derivative(b)*j2.derivative(a)
)
assert jacobian != 0
assert jacobian(a=1, b=2) == QQ(-1351680000)/12167
jacobian_factorization = factor(jacobian)


# C040: nonconstant twist points have infinite order. A single good
# infinite-order specialization proves that each generic point is non-torsion.
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
Z_map = Kt(t^2/den)
W_map = Kt((t^3 - 4*t - 10)/den^2)
den_prime = t^3 + QQ(4)/5*t^2 + 2*t + QQ(5)/4
Zprime_map = Kt(
    (-6*t^3 - 6*t^2 - QQ(35)/4*t + QQ(25)/4)/den_prime
)
Wprime_map = Kt(
    (-3*t^3 + QQ(55)/2*t^2 + QQ(25)/2*t + QQ(125)/8)
    / den_prime^2
)


def rational_degree(function):
    return max(
        function.numerator().degree(),
        function.denominator().degree(),
    )


assert rational_degree(Z_map) == 3
assert rational_degree(Zprime_map) == 3
assert Z_map.derivative() != 0
assert Zprime_map.derivative() != 0

t0 = QQ(0)
d = QQ(F(t0))
assert d == QQ(25)/4

# First target: w^2=A*z^3+B*z^2+C*z+D.
A0 = QQ(-247)/20
B0 = QQ(21)/5
C0 = QQ(-41)/5
D0 = QQ(1)
leading_twist = A0/d
twist_E = EllipticCurve(
    QQ,
    [
        0,
        B0/d,
        0,
        A0*C0/d^2,
        A0^2*D0/d^3,
    ],
)
point_E = twist_E(
    leading_twist*QQ(Z_map(t0)),
    leading_twist*QQ(W_map(t0)),
)
assert point_E.order() == Infinity

# Complementary target: w'^2=z'^3+25*z'+375.
twist_Eprime = EllipticCurve(
    QQ,
    [0, 0, 0, QQ(25)/d^2, QQ(375)/d^3],
)
point_Eprime = twist_Eprime(
    QQ(Zprime_map(t0))/d,
    QQ(Wprime_map(t0))/d,
)
assert point_Eprime.order() == Infinity


elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "claims": {
        "C005": {
            "verified": True,
            "paper_normalized_polynomial": str(paper_normalized),
            "paper_scaling": str(paper_scaling),
            "additional_tests": int(len(normalization_tests)),
        },
        "C035": {
            "verified": True,
            "universal_base_equation": "c*sx-px^2+b*px",
            "coefficient_field": "Q(a,b,c)",
        },
        "C036": {
            "verified": True,
            "ramification_j": str(ramification_j),
            "ramification_j_minus_1728": str(
                factor(ramification_j - 1728)
            ),
            "critical_curve_discriminant": str(
                factor(critical_curve_discriminant)
            ),
            "certificate": (
                "The critical discriminant is nonzero exactly when "
                "ramification j is neither 1728 nor infinity."
            ),
        },
        "C039": {
            "verified": True,
            "jacobian_factorization": str(jacobian_factorization),
            "value_at_1_2": str(jacobian(a=1, b=2)),
        },
        "C040": {
            "verified": True,
            "map_degrees": [
                int(rational_degree(Z_map)),
                int(rational_degree(Zprime_map)),
            ],
            "specialization_t": str(t0),
            "twist_parameter": str(d),
            "first_point": str(point_E),
            "first_point_order": str(point_E.order()),
            "second_point": str(point_Eprime),
            "second_point_order": str(point_Eprime.order()),
        },
    },
}

output = root / "results" / "sage_structural_claims.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
