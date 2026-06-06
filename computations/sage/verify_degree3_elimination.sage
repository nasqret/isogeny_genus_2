"""
Exact SageMath verification for claims C014, C016, and C017.

The script reconstructs the degree-3 complementary genus-one model by
eliminating the symmetric-square variables. It then compares the resulting
binary-quartic j-invariant with Kuhn's formula.

Run from the repository root:

    sage computations/sage/verify_degree3_elimination.sage
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


def reconstruct_complement(a, b, c):
    """Return the eliminated equation, normalized quartic, and j-invariant."""
    a = QQ(a)
    b = QQ(b)
    c = QQ(c)
    if c == 0:
        raise ValueError("The degree-3 presentation requires c != 0.")

    Rt.<t> = PolynomialRing(QQ)
    cover_denominator = t^3 + a*t^2 + b*t + c
    source_factor = 4*c*t^3 + b^2*t^2 + 2*b*c*t + c^2
    source_polynomial = cover_denominator*source_factor/(4*c)
    adjusting_numerator = t^3 - b*t - 2*c

    B.<sx, px> = PolynomialRing(QQ, 2)
    KB = B.fraction_field()
    KT.<T> = PolynomialRing(KB)
    quadratic = T^2 - sx*T + px

    def lift(poly):
        return KT([KB(coefficient) for coefficient in poly.list()])

    def quadratic_trace(numerator, denominator=Rt.one()):
        """Trace h(x1)+h(x2) in the quadratic algebra of x1,x2."""
        numerator_mod = lift(numerator).mod(quadratic)
        denominator_mod = lift(denominator).mod(quadratic)
        inverse = denominator_mod.inverse_mod(quadratic)
        reduced = (numerator_mod*inverse).mod(quadratic)
        return KB(reduced[1]*sx + 2*reduced[0])

    # F(x1)+F(x2) and F(x1)F(x2).
    source_sum = quadratic_trace(source_polynomial)
    BT.<U> = PolynomialRing(B)
    source_product = KB(
        (U^2 - sx*U + px).resultant(
            BT([B(coefficient) for coefficient in source_polynomial.list()])
        )
    )

    # If A=W(x1), B=W(x2), then
    # (y1*A+y2*B)*(y1+y2) = F1*A+F2*B+p_y*(A+B).
    # Away from the irrelevant s_y=0 component, the selected component is
    # H0 + p_y*H1 = 0 with the following symmetric traces.
    adjusting_denominator = cover_denominator^2
    h1 = quadratic_trace(adjusting_numerator, adjusting_denominator)
    h0 = quadratic_trace(
        source_polynomial*adjusting_numerator,
        adjusting_denominator,
    )

    Rp.<p> = PolynomialRing(QQ)
    KP = Rp.fraction_field()
    sx_parameter = (p^2 - b*p)/c

    def specialize(rational_function):
        numerator = B(rational_function.numerator())
        denominator = B(rational_function.denominator())
        return KP(numerator(sx_parameter, p)/denominator(sx_parameter, p))

    source_sum_p = specialize(source_sum)
    source_product_p = specialize(source_product)
    h0_p = specialize(h0)
    h1_p = specialize(h1)

    R.<p0, sy> = PolynomialRing(QQ, 2)
    KR = R.fraction_field()

    def embed(rational_function):
        numerator = R(rational_function.numerator()(p0))
        denominator = R(rational_function.denominator()(p0))
        return KR(numerator/denominator)

    source_sum_r = embed(source_sum_p)
    source_product_r = embed(source_product_p)
    h0_r = embed(h0_p)
    h1_r = embed(h1_p)

    # Eliminate p_y using p_y=(s_y^2-F_sum)/2.
    selected_component = 2*h0_r + h1_r*(sy^2 - source_sum_r)
    product_relation = (sy^2 - source_sum_r)^2 - 4*source_product_r
    selected_polynomial = R(selected_component.numerator())
    product_polynomial = R(product_relation.numerator())

    eliminated = selected_polynomial.gcd(product_polynomial)
    eliminated = eliminated / eliminated.content()

    as_sy = eliminated.polynomial(sy)
    if as_sy.degree() != 2 or as_sy[1] != 0:
        raise AssertionError("Expected an equation linear in s_y^2.")

    coefficient_sy2 = Rp(as_sy[2])
    constant = Rp(as_sy[0])
    q = KP(-constant/coefficient_sy2)
    normalized_quartic = (
        q.numerator()*q.denominator()
    ).squarefree_part()

    if normalized_quartic.degree() > 4:
        raise AssertionError("Expected a quartic genus-one model.")

    # Classical binary-quartic invariant formula.
    e = normalized_quartic[0]
    d = normalized_quartic[1]
    cc = normalized_quartic[2]
    bb = normalized_quartic[3]
    aa = normalized_quartic[4]
    invariant_i = 12*aa*e - 3*bb*d + cc^2
    quartic_discriminant = normalized_quartic.discriminant()
    if quartic_discriminant == 0:
        raise AssertionError("The normalized quartic is singular.")
    reconstructed_j = QQ(256)*invariant_i^3/quartic_discriminant

    kuhn_denominator = (
        27*c^2
        - 18*a*b*c
        + 4*a^3*c
        + 4*b^3
        - a^2*b^2
    )
    if kuhn_denominator == 0:
        raise AssertionError("Kuhn's j-invariant denominator vanishes.")
    kuhn_j = QQ(256)*(3*b - a^2)^3/kuhn_denominator

    return {
        "eliminated": R(eliminated),
        "normalized_quartic": Rp(normalized_quartic),
        "reconstructed_j": QQ(reconstructed_j),
        "kuhn_j": QQ(kuhn_j),
        "source_squarefree": bool(source_polynomial.is_squarefree()),
    }


started = perf_counter()
root = Path.cwd()

main = reconstruct_complement(3, 4, 5)
R = main["eliminated"].parent()
p0, sy = R.gens()
expected = (
    5^6*sy^2
    - p0
    * (p0^3 - 4*p0^2 + 15*p0 - 25)
    * (p0^4 - 10*p0^3 + 32*p0^2 - QQ(189)/2*p0 + 150)^2
)
assert main["eliminated"] / expected in QQ
normalized_variable = main["normalized_quartic"].parent().gen()
expected_normalized_quartic = (
    normalized_variable
    * (
        normalized_variable^3
        - 4*normalized_variable^2
        + 15*normalized_variable
        - 25
    )
)
normalization_quotient, normalization_remainder = (
    main["normalized_quartic"].quo_rem(expected_normalized_quartic)
)
assert normalization_remainder == 0
assert normalization_quotient.degree() == 0
assert normalization_quotient != 0
assert main["reconstructed_j"] == QQ(6912)/247
assert main["reconstructed_j"] == main["kuhn_j"]

sample_triples = [
    (1, 2, 3),
    (2, 3, 5),
    (1, 4, 2),
    (4, 7, 3),
]
sample_results = []
for triple in sample_triples:
    reconstruction = reconstruct_complement(*triple)
    assert reconstruction["source_squarefree"]
    assert reconstruction["reconstructed_j"] == reconstruction["kuhn_j"]
    sample_results.append(
        {
            "parameters": [int(value) for value in triple],
            "normalized_quartic": str(reconstruction["normalized_quartic"]),
            "reconstructed_j": str(reconstruction["reconstructed_j"]),
            "kuhn_j": str(reconstruction["kuhn_j"]),
        }
    )

elapsed = perf_counter() - started
result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "claims": {
        "C014": {
            "verified": True,
            "certificate": "Exact elimination and polynomial GCD reproduce the displayed factorized singular model.",
            "eliminated_equation": str(main["eliminated"]),
            "normalized_quartic": str(main["normalized_quartic"]),
        },
        "C016": {
            "verified": True,
            "reconstructed_j": str(main["reconstructed_j"]),
            "kuhn_j": str(main["kuhn_j"]),
        },
        "C017": {
            "verified": True,
            "sample_count": int(len(sample_results)),
            "samples": sample_results,
        },
    },
}

output = root / "results" / "sage_degree3_elimination.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
