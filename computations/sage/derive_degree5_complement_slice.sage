"""
Derive a one-parameter slice of the generic degree-5 complementary j.

This is a symbolic degree-bound and factor-discovery computation over Q(a).
The second parameter ``b`` is selected by ``DEGREE5_B`` in the environment,
defaulting to 1.

Run from the repository root:

    HOME=/tmp/sagehome DEGREE5_B=1 \
      sage computations/sage/derive_degree5_complement_slice.sage
"""

import json
import os
from datetime import datetime
from pathlib import Path
from time import perf_counter


proof.polynomial(False)
started = perf_counter()
root = Path.cwd()
b_value = QQ(os.environ.get("DEGREE5_B", "1"))

F.<a> = FunctionField(QQ)
b = F(b_value)
Pc.<C> = PolynomialRing(F)
critical_polynomial = (
    (2*a + 1)*C^2
    + (2*b - 2*a*b - 2*a - a^2)*C
    + b^2
    + 2*a*b
).monic()
Kc.<c> = F.extension(critical_polynomial)

load(str(root / "computations" / "sage" / "lib" / "degree5_complement.sage"))

canonical_point = degree5_canonical_conic_point(Kc, a, b, c)
assert canonical_point["conic_residual"] == 0
certificate = degree5_complement_from_conic_point(
    Kc,
    a,
    b,
    c,
    (canonical_point["m"], canonical_point["y"]),
    verify_pair_relation=False,
    verify_even_factor=False,
    materialize_orientation=False,
    verbose=True,
)
j_tower = certificate["complement_j"]

# The j-invariant descends through both quadratic extensions.
j_in_critical_field = Kc(j_tower)
j_in_a_basis = j_in_critical_field.list()
assert len(j_in_a_basis) <= 2
j_constant = F(j_in_a_basis[0])
j_critical = F(j_in_a_basis[1]) if len(j_in_a_basis) == 2 else F(0)
j_trace = F(j_in_critical_field.trace())
j_norm = F(j_in_critical_field.norm())


def rational_function_data(value):
    numerator = value.numerator()
    denominator = value.denominator()
    numerator_factorization = (
        "0" if numerator == 0 else str(factor(numerator))
    )
    return {
        "value": str(value),
        "numerator_degree_in_a": int(numerator.degree()),
        "denominator_degree_in_a": int(denominator.degree()),
        "numerator_factorization": numerator_factorization,
        "denominator_factorization": str(factor(denominator)),
    }


result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "workstream": "B003",
    "verified": True,
    "b": str(b_value),
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "j_in_critical_basis": {
        "constant": rational_function_data(j_constant),
        "critical_coefficient": rational_function_data(j_critical),
    },
    "minimal_polynomial": {
        "equation": "J^2 - trace*J + norm",
        "trace": rational_function_data(j_trace),
        "norm": rational_function_data(j_norm),
    },
    "branch_quartic_degree": int(
        certificate["branch_quartic"].degree()
    ),
}

output = (
    root
    / "results"
    / ("sage_degree5_complement_slice_b_%s.json" % b_value)
)
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
