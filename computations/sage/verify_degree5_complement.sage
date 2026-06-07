"""
Exact specialization checks for the generic degree-5 complement engine.

The first row is the article's (a,b)=(7,1) example and must recover the
independently known complementary j-invariant.  The second row demonstrates
the genuinely quadratic generic behavior.
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
load(str(root / "computations" / "sage" / "lib" / "degree5_complement.sage"))

examples = []
for av, bv in [(7, 1), (1, 2)]:
    R.<u> = PolynomialRing(QQ)
    critical_polynomial = degree5_critical_polynomial(QQ, av, bv, u)
    K.<c> = NumberField(critical_polynomial)
    canonical_point = degree5_canonical_conic_point(K, av, bv, c)
    assert canonical_point["conic_residual"] == 0
    certificate = degree5_complement_from_conic_point(
        K,
        av,
        bv,
        c,
        (canonical_point["m"], canonical_point["y"]),
    )
    complement_j = certificate["complement_j"]
    minimal_polynomial = complement_j.minpoly()
    assert certificate["branch_quartic"].degree() == 4
    assert minimal_polynomial.degree() in (1, 2)

    if (av, bv) == (7, 1):
        assert complement_j == QQ(-250888806400)/56807829
        assert minimal_polynomial.degree() == 1
    else:
        assert minimal_polynomial.degree() == 2

    examples.append(
        {
            "parameters": {"a": int(av), "b": int(bv)},
            "critical_polynomial": str(critical_polynomial),
            "canonical_conic_point": {
                "m": str(canonical_point["m"]),
                "y": str(canonical_point["y"]),
            },
            "component_square_class_degrees": {
                "z": int(certificate["zero_polynomial"].degree()),
                "z_minus_1": int(
                    certificate["one_polynomial"].degree()
                ),
                "z_minus_e": int(
                    certificate["branch_value_polynomial"].degree()
                ),
                "diagonal": int(
                    certificate["diagonal_polynomial"].degree()
                ),
            },
            "branch_quartic": str(certificate["branch_quartic"]),
            "complement_j": str(complement_j),
            "complement_j_minimal_polynomial": str(minimal_polynomial),
            "complement_j_degree": int(minimal_polynomial.degree()),
        }
    )

result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B003",
    "verified": True,
    "algorithm": (
        "Galois-quotient orientation square class on the canonical "
        "branch-field parametrization of the normalization conic"
    ),
    "examples": examples,
}

output = root / "results" / "sage_degree5_complement.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
