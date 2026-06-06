"""
Exact nonprimitive high-degree maps obtained by elliptic multiplication.

Starting from the (a,b)=(7,1) primitive degree-5 cover, compose with [2] and
[4] on the elliptic target.  The resulting maps have degrees 20 and 80.
These examples are deliberately labeled nonprimitive: they create high
degree maps, but no new elliptic subfield of the genus-2 function field.

Run from the repository root:

    HOME=/tmp/sagehome sage computations/sage/verify_composed_high_degree_maps.sage
"""

import hashlib
import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()

Qt.<t0> = PolynomialRing(QQ)
K.<e> = NumberField(289*t0^2 - 605*t0 + 289)
Kx.<x> = PolynomialRing(K)
F = Kx.fraction_field()

a = K(7)
b = K(1)
F1 = x^2 + (2*a + 2*b + a^2)*x + 2*a*b + b^2
F2 = (2*a + 1)*x^2 + (a^2 + 2*a*b + 2*b)*x + b^2
F3 = x^2 - (a^2 - 2*b)*x + b^2
phi_num = x*F1^2
phi_den = F2^2
assert phi_num - phi_den == (x - 1)*F3^2

pullback_numerator = (
    phi_num
    * (phi_num - phi_den)
    * (phi_num - e*phi_den)
)
source_polynomial = pullback_numerator.squarefree_part()
square_quotient = pullback_numerator // source_polynomial
assert square_quotient.is_square()
square_multiplier = square_quotient.sqrt()
assert HyperellipticCurve(source_polynomial).genus() == 2

# E: Y^2 = t^3 + a2*t^2 + a4*t.
a2 = -(1 + e)
a4 = e


def elliptic_rhs(value):
    return value^3 + a2*value^2 + a4*value


def double_x(value):
    tangent_numerator = 3*value^2 + 2*a2*value + a4
    return F(
        tangent_numerator^2/(4*elliptic_rhs(value))
        - a2
        - 2*value
    )


def double_y_factor(value):
    """Return R(value) such that Y([2]P)=Y(P)*R(value)."""
    tangent_numerator = 3*value^2 + 2*a2*value + a4
    doubled_x = double_x(value)
    return F(
        -1
        + tangent_numerator*(value - doubled_x)
        / (2*elliptic_rhs(value))
    )


def rational_degree(value):
    return max(value.numerator().degree(), value.denominator().degree())


def digest(value):
    return hashlib.sha256(str(value).encode("utf-8")).hexdigest()


t_degree_5 = F(phi_num/phi_den)
y_factor_degree_5 = F(square_multiplier/F2^3)
assert (
    source_polynomial*y_factor_degree_5^2
    == elliptic_rhs(t_degree_5)
)
assert rational_degree(t_degree_5) == 5

t_degree_20 = double_x(t_degree_5)
y_factor_degree_20 = (
    y_factor_degree_5*double_y_factor(t_degree_5)
)
assert (
    source_polynomial*y_factor_degree_20^2
    == elliptic_rhs(t_degree_20)
)
assert rational_degree(t_degree_20) == 20

t_degree_80 = double_x(t_degree_20)
y_factor_degree_80 = (
    y_factor_degree_20*double_y_factor(t_degree_20)
)
assert (
    source_polynomial*y_factor_degree_80^2
    == elliptic_rhs(t_degree_80)
)
assert rational_degree(t_degree_80) == 80

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B013",
    "verified": True,
    "base_cover": {
        "parameters": {"a": int(7), "b": int(1)},
        "degree": int(5),
        "field_polynomial": str(K.defining_polynomial()),
        "source_polynomial": str(source_polynomial),
        "target_j": str(
            K(256*(1 - e + e^2)^3/(e^2*(1 - e)^2))
        ),
    },
    "compositions": [
        {
            "elliptic_endomorphism": "[2]",
            "endomorphism_degree": int(4),
            "cover_degree": int(20),
            "x_coordinate_sha256": digest(t_degree_20),
            "identity": "source_y_factor^2 * source_polynomial = target cubic",
        },
        {
            "elliptic_endomorphism": "[4]",
            "endomorphism_degree": int(16),
            "cover_degree": int(80),
            "x_coordinate_sha256": digest(t_degree_80),
            "identity": "source_y_factor^2 * source_polynomial = target cubic",
        },
    ],
    "general_rule": (
        "A degree-n cover followed by multiplication-by-m on the elliptic "
        "target has degree n*m^2."
    ),
    "scope_note": (
        "These maps are exact but nonprimitive. They do not produce a new "
        "maximal elliptic subfield or a new complementary factor."
    ),
}

output = root / "results" / "sage_composed_high_degree_maps.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
