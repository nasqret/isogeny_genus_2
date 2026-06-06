"""
Generic structural certificates for the two-parameter degree-5 family.

This goes beyond the paper's single specialization.  It derives the branch
quadratic, the symmetric divided-difference quartic, its three universal
nodes, and a normalization conic over Q(a,b).

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_degree5_family_structure.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()

R.<a, b, s, p, m> = PolynomialRing(QQ, 5)
K = R.fraction_field()
U.<x> = PolynomialRing(K)


def F1(value):
    return (
        value^2
        + (2*a + 2*b + a^2)*value
        + 2*a*b
        + b^2
    )


def F2(value):
    return (
        (2*a + 1)*value^2
        + (a^2 + 2*a*b + 2*b)*value
        + b^2
    )


def F3(value):
    return value^2 - (a^2 - 2*b)*value + b^2


# The normalized Frey-Kani map and its three distinguished fibers.
phi_num = x*F1(x)^2
phi_den = F2(x)^2
assert phi_num - phi_den == (x - 1)*F3(x)^2

# Compute the branch resultant over Q[a,b,e].
BE.<aa, bb, xx, e> = PolynomialRing(QQ, 4)
F1e = xx^2 + (2*aa + 2*bb + aa^2)*xx + 2*aa*bb + bb^2
F2e = (2*aa + 1)*xx^2 + (aa^2 + 2*aa*bb + 2*bb)*xx + bb^2
cover_equation = xx*F1e^2 - e*F2e^2
branch_resultant = cover_equation.resultant(
    cover_equation.derivative(xx), xx
)
branch_quadratic = BE(
    branch_resultant
    / (
        256
        * aa^12
        * bb^4
        * (aa + bb + 1)^4
        * e^2
        * (e - 1)^2
    )
)
assert branch_quadratic.degree(e) == 2
branch_discriminant = branch_quadratic.discriminant(e)
expected_branch_discriminant = (
    aa
    * (-aa^3 + 2*aa*bb + 2*bb^2 + 2*bb)^2
    * (
        aa^3
        + 4*aa^2*bb
        + 4*aa*bb^2
        + 4*aa^2
        - 12*aa*bb
        - 16*bb^2
        + 4*aa
        - 16*bb
    )^3
)
assert branch_discriminant == expected_branch_discriminant


def symmetric_divided_difference():
    """Return the off-diagonal equation in s=x1+x2 and p=x1*x2."""
    x2 = s - x
    numerator = (
        x*F1(x)^2*F2(x2)^2
        - x2*F1(x2)^2*F2(x)^2
    )
    quotient, remainder = numerator.quo_rem(2*x - s)
    assert remainder == 0
    reduced = quotient.mod(x^2 - s*x + p)
    assert reduced.degree() == 0
    return R(reduced[0])


base_quartic = symmetric_divided_difference()
assert base_quartic.degree(s) <= 4
assert base_quartic.degree(p) <= 4
assert max(
    exponents[2] + exponents[3]
    for exponents in base_quartic.dict()
) == 4

nodes = [
    (
        -(a^2 + 2*a + 2*b),
        2*a*b + b^2,
        "fiber over 0",
    ),
    (
        a^2 - 2*b,
        b^2,
        "fiber over 1",
    ),
    (
        -(a^2 + 2*a*b + 2*b)/(2*a + 1),
        b^2/(2*a + 1),
        "fiber over infinity",
    ),
]

AB.<A, B> = PolynomialRing(QQ, 2)
FAB = AB.fraction_field()
T.<du, dv> = PolynomialRing(FAB, 2)
node_certificates = []
for s0, p0, label in nodes:
    s0ab = FAB(s0(a=A, b=B))
    p0ab = FAB(p0(a=A, b=B))
    specialized = T(
        base_quartic(
            a=A,
            b=B,
            s=s0ab + du,
            p=p0ab + dv,
            m=0,
        )
    )
    assert specialized[0, 0] == 0
    assert specialized[1, 0] == 0
    assert specialized[0, 1] == 0
    tangent_cone = sum(
        coefficient*du^exponents[0]*dv^exponents[1]
        for exponents, coefficient in specialized.dict().items()
        if sum(exponents) == 2
    )
    tangent_discriminant = (
        tangent_cone[1, 1]^2
        - 4*tangent_cone[2, 0]*tangent_cone[0, 2]
    )
    assert tangent_discriminant != 0
    node_certificates.append(
        {
            "label": label,
            "coordinates": [str(s0), str(p0)],
            "tangent_discriminant": str(factor(tangent_discriminant)),
        }
    )

# Project from the node belonging to the fiber over zero.  The residual
# quadratic has square factors times the following quadratic Q(m).
FR.<r> = PolynomialRing(FractionField(QQ["a,b,m"]))
af, bf, mf = FR.base_ring().gens()
s0 = -(af^2 + 2*af + 2*bf)
p0 = 2*af*bf + bf^2
projected = FR(
    base_quartic(
        a=af,
        b=bf,
        s=s0 + r,
        p=p0 + mf*r,
        m=mf,
    )
)
residual, projection_remainder = projected.quo_rem(r^2)
assert projection_remainder == 0
assert residual.degree() == 2
projection_discriminant = residual.discriminant()

normalization_quadratic = (
    af^4*mf^2
    + 2*af^3*bf*mf
    + 2*af^2*bf^2*mf
    + 2*af^3*mf^2
    + 2*af^2*bf*mf^2
    + 2*af*bf^3
    + bf^4
    + 2*af*bf^2*mf
    + 2*bf^3*mf
    + af^2*mf^2
    + bf^2*mf^2
)
expected_projection_discriminant = (
    16
    * af^2
    * (af*mf + bf + mf)^2
    * (
        af^2*mf
        + 2*af*bf
        + bf^2
        + 2*af*mf
        + bf*mf
        + bf
        + mf
    )^2
    * normalization_quadratic
)
assert projection_discriminant == expected_projection_discriminant

normalization_leading = (
    af^4 + 2*af^3 + 2*af^2*bf + af^2 + bf^2
)
normalization_linear = 2*bf*(af + bf)*(af^2 + bf)
normalization_constant = bf^3*(2*af + bf)
normalization_discriminant = (
    normalization_linear^2
    - 4*normalization_leading*normalization_constant
)
assert normalization_discriminant == (
    -4
    * bf^2
    * af^3
    * (-af^3 + 2*af*bf + 2*bf^2 + 2*bf)
)

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B002",
    "verified": True,
    "family": {
        "F1": str(F1(x)),
        "F2": str(F2(x)),
        "F3": str(F3(x)),
        "phi_minus_one_factorization": "(x-1)*F3(x)^2/F2(x)^2",
    },
    "branch": {
        "quadratic": str(branch_quadratic),
        "discriminant_factorization": str(factor(branch_discriminant)),
    },
    "base_curve": {
        "equation": str(base_quartic),
        "degree": int(4),
        "arithmetic_genus": int(3),
        "generic_nodes": node_certificates,
        "generic_geometric_genus": int(0),
    },
    "normalization": {
        "conic": "y^2 = " + str(normalization_quadratic),
        "projection_discriminant_factorization": str(
            factor(projection_discriminant)
        ),
        "quadratic_discriminant_factorization": str(
            factor(normalization_discriminant)
        ),
    },
    "genericity_conditions": [
        "a*b*(a+b+1)*(2*a+1) != 0",
        "branch quadratic discriminant != 0",
        "(2*a+b)*(-a+b+1) != 0 for ordinary displayed nodes",
    ],
}

output = root / "results" / "sage_degree5_family_structure.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
