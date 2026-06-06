"""
Independent SageMath audit of the degree-5 example, claims C026-C029.

This script intentionally compares the article's printed quartic with the
quartic obtained from the exact divided difference. It records discrepancies
instead of silently replacing the printed coefficients.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_degree5_basic.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()


# C026: reconstruct the branch field, elliptic curve, source curve, and map.
Qe.<e> = PolynomialRing(QQ)
Qu.<u> = PolynomialRing(QQ)
S.<x, parameter> = PolynomialRing(QQ, 2)
F1x = x^2 + 65*x + 15
F2x = 15*x^2 + 65*x + 1
cover_equation = x*F1x^2 - parameter*F2x^2
branch_resultant = cover_equation.resultant(
    cover_equation.derivative(x), x
)
branch_polynomial = Qe(branch_resultant(x=0, parameter=e))
branch_monic = branch_polynomial/branch_polynomial.leading_coefficient()
expected_branch = e^2*(e - 1)^2*(e^2 - QQ(605)/289*e + 1)
assert branch_monic == expected_branch

K.<z> = NumberField(u^2 + u - 5)
assert K.degree() == 2
P.<t> = PolynomialRing(K)
Kt = P.fraction_field()
alpha = K((283 - 39*z)/289)
assert alpha^2 - QQ(605)/289*alpha + 1 == 0

elliptic_rhs = t*(t - 1)*(t - alpha)
elliptic_curve = EllipticCurve(
    K,
    [0, elliptic_rhs[2], 0, elliptic_rhs[1], elliptic_rhs[0]],
)
assert elliptic_curve.j_invariant() == QQ(8077950976)/2255067

F1 = t^2 + 65*t + 15
F2 = 15*t^2 + 65*t + 1
phi = Kt(t*F1^2/F2^2)
assert max(phi.numerator().degree(), phi.denominator().degree()) == 5

source_cubic = (
    t^3
    + (8197*z - 24949)/289*t^2
    + (176575*z + 493478)/289*t
    - (1064*z + 2987)/289
)
source_polynomial = t*(t - 1)*source_cubic
expected_source = (
    t^5
    + (8197*z - 25238)/289*t^4
    + (168378*z + 518427)/289*t^3
    + (-177639*z - 496465)/289*t^2
    + (1064*z + 2987)/289*t
)
assert source_polynomial == expected_source
assert source_polynomial.is_squarefree()
assert HyperellipticCurve(source_polynomial).genus() == 2

adjusting_factor = Kt(
    (t + z - 2)*(t^2 - 47*t + 1)*F1/F2^3
)
assert Kt(elliptic_rhs(phi)) == Kt(
    source_polynomial*adjusting_factor^2
)


# C027: derive the symmetric base quartic and compare it coefficient-by-
# coefficient with the article.
R2.<x1, x2> = PolynomialRing(QQ, 2)
K2 = R2.fraction_field()


def phi_q(value):
    return (
        value*(value^2 + 65*value + 15)^2
        / (15*value^2 + 65*value + 1)^2
    )


sx = x1 + x2
px = x1*x2
denominator_product = (
    (15*x1^2 + 65*x1 + 1)^2
    * (15*x2^2 + 65*x2 + 1)^2
)
divided_difference = K2((phi_q(x1) - phi_q(x2))/(x1 - x2))

corrected_base = R2(
    sx^4
    + 130*sx^3*px
    + 130*sx^3
    + 4255*sx^2*px^2
    - 33728*sx^2*px
    + 4255*sx^2
    + 1950*sx*px^3
    + 114140*sx*px^2
    + 114140*sx*px
    + 1950*sx
    + 225*px^4
    - 708130*px^3
    + 14336251*px^2
    - 708130*px
    + 225
)
printed_base = R2(
    sx^4
    + 130*sx^3*px
    + 130*sx^3
    + 4255*sx^2*px^2
    - 33728*sx^2*px
    + 4255*sx^2
    + 19500*sx*px^3
    + 114140*sx*px^2
    + 114140*sx*px
    + 19500*sx
    + 225*px^4
    - 707130*px^3
    + 14336251*px^2
    - 707130*px
    + 225
)
assert divided_difference*denominator_product == corrected_base
assert divided_difference*denominator_product != printed_base
printed_difference = R2(corrected_base - printed_base)
assert printed_difference == R2(
    -17550*sx*px^3 - 17550*sx - 1000*px^3 - 1000*px
)


# C028: the printed quartic is smooth of genus 3. The corrected intended
# quartic has exactly three ordinary nodes, hence geometric genus 3-3=0.
A2.<s, p> = PolynomialRing(QQ, 2)


def base_polynomial(s_coefficient, cubic_coefficient):
    return (
        s^4
        + 130*s^3*p
        + 130*s^3
        + 4255*s^2*p^2
        - 33728*s^2*p
        + 4255*s^2
        + s_coefficient*s*p^3
        + 114140*s*p^2
        + 114140*s*p
        + s_coefficient*s
        + 225*p^4
        + cubic_coefficient*p^3
        + 14336251*p^2
        + cubic_coefficient*p
        + 225
    )


printed_affine = base_polynomial(19500, -707130)
corrected_affine = base_polynomial(1950, -708130)
printed_singular_ideal = A2.ideal(
    [
        printed_affine,
        printed_affine.derivative(s),
        printed_affine.derivative(p),
    ]
)
assert printed_singular_ideal == A2.ideal([1])

corrected_singular_ideal = A2.ideal(
    [
        corrected_affine,
        corrected_affine.derivative(s),
        corrected_affine.derivative(p),
    ]
)
assert corrected_singular_ideal.dimension() == 0
assert corrected_singular_ideal.radical().vector_space_dimension() == 3

node_coordinates = [
    (QQ(-65), QQ(15)),
    (QQ(47), QQ(1)),
    (QQ(-13)/3, QQ(1)/15),
]
T2.<du, dv> = PolynomialRing(QQ, 2)
node_certificates = []
for s0, p0 in node_coordinates:
    assert corrected_affine(s=s0, p=p0) == 0
    assert corrected_affine.derivative(s)(s=s0, p=p0) == 0
    assert corrected_affine.derivative(p)(s=s0, p=p0) == 0
    translated = T2(corrected_affine(s=s0 + du, p=p0 + dv))
    tangent_cone = sum(
        coefficient*du^exponents[0]*dv^exponents[1]
        for exponents, coefficient in translated.dict().items()
        if sum(exponents) == 2
    )
    tangent_discriminant = tangent_cone.discriminant(du)
    assert tangent_discriminant != 0
    node_certificates.append(
        {
            "point": [str(s0), str(p0)],
            "tangent_cone": str(tangent_cone),
            "discriminant": str(tangent_discriminant),
        }
    )


def no_singularities_at_infinity(
    s_coefficient, cubic_coefficient
):
    H.<S0, P0, W0> = PolynomialRing(QQ, 3)
    homogenized = (
        S0^4
        + 130*S0^3*P0
        + 130*S0^3*W0
        + 4255*S0^2*P0^2
        - 33728*S0^2*P0*W0
        + 4255*S0^2*W0^2
        + s_coefficient*S0*P0^3
        + 114140*S0*P0^2*W0
        + 114140*S0*P0*W0^2
        + s_coefficient*S0*W0^3
        + 225*P0^4
        + cubic_coefficient*P0^3*W0
        + 14336251*P0^2*W0^2
        + cubic_coefficient*P0*W0^3
        + 225*W0^4
    )
    U.<v> = PolynomialRing(QQ)
    equations = [
        U(poly(S0=v, P0=1, W0=0))
        for poly in (
            homogenized,
            homogenized.derivative(S0),
            homogenized.derivative(P0),
            homogenized.derivative(W0),
        )
    ]
    common = equations[0]
    for equation in equations[1:]:
        common = common.gcd(equation)
    return common == 1


assert no_singularities_at_infinity(19500, -707130)
assert no_singularities_at_infinity(1950, -708130)
printed_geometric_genus = 3
corrected_geometric_genus = 3 - len(node_coordinates)
assert corrected_geometric_genus == 0


# C029: project from the node (-65,15). The normalization is the conic
# y^2=20*(647*m^2+160*m+3), which has a K-rational point.
RM.<r, m> = PolynomialRing(K, 2)
projected = RM(
    corrected_affine(
        s=-65 + r,
        p=15 + m*r,
    )
)
assert projected % r^2 == 0
residual_quadratic = RM(projected // r^2)
residual_discriminant = residual_quadratic.discriminant(r)
expected_projection_discriminant = (
    3920*(8*m + 1)^2*(65*m + 16)^2
    * (647*m^2 + 160*m + 3)
)
assert residual_discriminant == expected_projection_discriminant

CK.<M, N, Y> = PolynomialRing(K, 3)
normalization_conic = Conic(
    Y^2 - 20*(647*M^2 + 160*M*N + 3*N^2)
)
conic_point = normalization_conic.rational_point()
assert conic_point[1] != 0
m_value = K(conic_point[0]/conic_point[1])
y_value = K(conic_point[2]/conic_point[1])

Rr.<rr> = PolynomialRing(K)
residual_at_m = Rr(residual_quadratic(r=rr, m=m_value))
square_root_discriminant = K(
    14*(8*m_value + 1)*(65*m_value + 16)*y_value
)
assert square_root_discriminant^2 == residual_at_m.discriminant()
r_value = K(
    (-residual_at_m[1] + square_root_discriminant)
    / (2*residual_at_m[2])
)
s_value = K(-65 + r_value)
p_value = K(15 + m_value*r_value)
assert corrected_affine(s=s_value, p=p_value) == 0
partial_s = K(corrected_affine.derivative(s)(s=s_value, p=p_value))
partial_p = K(corrected_affine.derivative(p)(s=s_value, p=p_value))
assert partial_s != 0 or partial_p != 0


elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "claims": {
        "C026": {
            "verified": True,
            "branch_factorization": str(factor(branch_monic)),
            "base_field": "Q(z), z^2+z-5=0",
            "elliptic_rhs": str(elliptic_rhs),
            "elliptic_j": str(elliptic_curve.j_invariant()),
            "source_polynomial": str(source_polynomial),
            "source_genus": int(HyperellipticCurve(source_polynomial).genus()),
            "cover_degree": int(
                max(phi.numerator().degree(), phi.denominator().degree())
            ),
            "cover_identity_verified": True,
        },
        "C027": {
            "verified": False,
            "paper_assertion": "The displayed quartic equals the divided-difference equation.",
            "outcome": "disproved",
            "corrected_equation": str(corrected_base),
            "printed_difference": str(printed_difference),
            "incorrect_coefficients": {
                "sx*px^3": {
                    "printed": int(19500),
                    "correct": int(1950),
                },
                "sx": {
                    "printed": int(19500),
                    "correct": int(1950),
                },
                "px^3": {
                    "printed": int(-707130),
                    "correct": int(-708130),
                },
                "px": {
                    "printed": int(-707130),
                    "correct": int(-708130),
                },
            },
        },
        "C028": {
            "verified": False,
            "paper_assertion": "The displayed plane quartic has geometric genus zero.",
            "outcome": "disproved_as_printed",
            "printed_curve_genus": int(printed_geometric_genus),
            "corrected_curve_genus": int(corrected_geometric_genus),
            "corrected_curve_nodes": node_certificates,
        },
        "C029": {
            "verified": False,
            "paper_assertion": "The corrected genus-zero curve has no nonsingular point over Q(z).",
            "outcome": "disproved",
            "normalization_conic": str(normalization_conic.defining_polynomial()),
            "conic_point": str(conic_point),
            "nonsingular_affine_point": [str(s_value), str(p_value)],
            "partial_derivatives_nonzero": True,
        },
    },
}

output = root / "results" / "sage_degree5_basic.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
