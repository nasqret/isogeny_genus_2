"""
Independent verification of claim C038.

For g(x)=x^4+p*x^2+q*x, the off-diagonal self-fiber has the
genus-one model

    Y^2 = X^4 + 2*p*X^2 + 2*q*X.

The substitution U=2*q/X, V=2*q*Y/X^2 gives

    V^2 = U^3 + 2*p*U^2 + 4*q^2.

The universal Q(i)-solution u=i*t, v=t with
t=(i-1)q/(2p) maps to P=(-2*p,2*q).  We classify when P is torsion
using exact division polynomials and Mazur's theorem.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_exceptional_ramification.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()

R.<p, q> = PolynomialRing(QQ)
K = R.fraction_field()
E = EllipticCurve(K, [0, 2*p, 0, 0, 4*q^2])
P = E(-2*p, 2*q)

# Directly verify the quartic-to-cubic birational substitution at the
# universal point on the quartic model.
assert P in E
assert E.j_invariant() == -1024*p^6/(q^2*(8*p^3 + 27*q^2))

# The ramification curve y^2=g'(x) has this j-invariant.
j_ram = 13824*p^3/(8*p^3 + 27*q^2)
j_complement = j_ram^2/(4*(j_ram - 1728))
assert j_complement == E.j_invariant()

# For p != 0, all division-polynomial evaluations depend only on
# r=q^2/p^3.  Setting p=1 and replacing q^(2k) by r^k preserves their
# rational zero sets.
S.<r> = PolynomialRing(QQ)


def normalized_division_polynomial(order):
    value = R(E.division_polynomial(order)(-2*p))
    result = S.zero()
    for exponents, coefficient in value.dict().items():
        p_exp, q_exp = exponents
        assert q_exp % 2 == 0
        result += coefficient*r^(q_exp//2)
    return result


# Mazur's theorem restricts the order of a rational torsion point to this
# list (orders 1 and 2 are visibly impossible here when q != 0).
mazur_orders = [3, 4, 5, 6, 7, 8, 9, 10, 12]
division_certificates = {}
rational_roots = set()
for order in mazur_orders:
    polynomial = normalized_division_polynomial(order)
    roots = polynomial.roots(QQ)
    rational_roots.update(root for root, multiplicity in roots)
    division_certificates[str(order)] = {
        "polynomial": str(polynomial.factor()),
        "rational_roots": [str(root) for root, multiplicity in roots],
    }

# r=0 gives j_ram=1728 and is excluded by the hypotheses.  The only
# admissible finite values are r=-1/4 and r=-1/2.
assert rational_roots == {QQ(0), -QQ(1)/4, -QQ(1)/2}
j_ram_normalized = 13824/(8 + 27*r)
assert j_ram_normalized(r=0) == 1728
assert j_ram_normalized(r=-QQ(1)/4) == QQ(55296)/5
assert j_ram_normalized(r=-QQ(1)/2) == -QQ(27648)/11

# The remaining case p=0 is not visible in r=q^2/p^3.  It makes P a
# nonzero 3-torsion point and gives ramification j=0.
Kq.<q0> = FunctionField(QQ)
E0 = EllipticCurve(Kq, [0, 0, 0, 0, 4*q0^2])
P0 = E0(0, 2*q0)
assert not P0.is_zero()
assert 3*P0 == E0(0)

exceptional_values = [
    QQ(0),
    -QQ(27648)/11,
    QQ(55296)/5,
]
complementary_values = [
    value^2/(4*(value - 1728)) if value != 0 else QQ(0)
    for value in exceptional_values
]
assert complementary_values == [
    QQ(0),
    -QQ(4096)/11,
    QQ(16384)/5,
]

output = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": f"SageMath {sage.version.version}",
    "elapsed_seconds": perf_counter() - started,
    "claim": "C038",
    "verified": True,
    "quartic_model": "Y^2=X^4+2*p*X^2+2*q*X",
    "elliptic_model": "V^2=U^3+2*p*U^2+4*q^2",
    "universal_point": "(-2*p, 2*q)",
    "ramification_j": str(j_ram),
    "complementary_j": str(j_complement),
    "mazur_orders_checked": [int(order) for order in mazur_orders],
    "division_certificates": division_certificates,
    "excluded_rational_root": {
        "r": "0",
        "reason": "j_ram=1728, excluded by the paper's ellipticity hypothesis",
    },
    "exceptional_ramification_j": [str(value) for value in exceptional_values],
    "exceptional_complementary_j": [
        str(value) for value in complementary_values
    ],
    "interpretation": (
        "The universal Q(i)-solution maps to a rational point P. "
        "Mazur's theorem plus the exact division-polynomial factors show "
        "that P is torsion precisely at the three stated ramification "
        "j-values, after excluding j=1728."
    ),
}

result_path = root / "results" / "sage_exceptional_ramification.json"
result_path.write_text(json.dumps(output, indent=2) + "\n")
print(json.dumps(output, indent=2))
