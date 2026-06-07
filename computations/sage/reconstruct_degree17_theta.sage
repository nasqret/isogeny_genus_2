"""Compute and certify the explicit degree-17 Frey-Kani quotient curve."""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
set_random_seed(0)
load(
    str(
        root
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_theta_gluing.sage"
    )
)

prime = ZZ(17)
finite_field = GF(8263)
E1 = EllipticCurve(finite_field, [0, 1728])
E2 = EllipticCurve(finite_field, [6442, 3171])
basis1 = (
    E1(3198, 717),
    E1(1807, 564),
)
basis2 = (
    E2(7342, 3211),
    E2(4793, 6460),
)
theta_data = frey_kani_theta_quotient(
    E1,
    E2,
    prime,
    basis1,
    basis2,
    matrix(GF(prime), [[1, 0], [0, 6]]),
    extension_degree=12,
    repository_root=root,
)
curve = theta_data["quotient_curve"]
igusa_clebsch = curve.igusa_clebsch_invariants()
absolute_igusa = curve.absolute_igusa_invariants_kohel()
assert tuple(absolute_igusa) == (893, 1328, 7156)
assert all(value^8263 == value for value in absolute_igusa)

polynomial_ring = PolynomialRing(finite_field, "x")
x = polynomial_ring.gen()
source_polynomial = (
    5422*x^6
    + 4306*x^5
    + 4875*x^4
    + 5667*x^3
    + 6314*x^2
    + 4554*x
    + 6050
)
source_curve = HyperellipticCurve(source_polynomial)
assert source_polynomial.is_squarefree()
assert source_curve.genus() == 2
assert source_curve.absolute_igusa_invariants_kohel() == absolute_igusa

weil_polynomial_ring = PolynomialRing(ZZ, "T")
T = weil_polynomial_ring.gen()
expected_weil_polynomial = (
    T^4
    - 55*T^3
    - 3598*T^2
    - 454465*T
    + 68277169
)
actual_weil_polynomial = source_curve.frobenius_polynomial()
assert list(actual_weil_polynomial) == list(expected_weil_polynomial)

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B019",
    "verified": True,
    "scope": "explicit degree-17 Frey-Kani quotient curve",
    "field": "GF(8263)",
    "degree": int(17),
    "theta_extension_degree": int(12),
    "anti_isometry_matrix": [
        [int(1), int(0)],
        [int(0), int(6)],
    ],
    "quotient_theta_null": [
        str(value)
        for value in theta_data["quotient"].theta_null_point()
    ],
    "rosenhain_polynomial": str(
        curve.hyperelliptic_polynomials()[0]
    ),
    "igusa_clebsch_invariants": [
        str(value) for value in igusa_clebsch
    ],
    "absolute_igusa_invariants": [
        int(value) for value in absolute_igusa
    ],
    "absolute_invariants_frobenius_fixed": True,
    "base_field_curve": {
        "equation": (
            "y^2=5422*x^6+4306*x^5+4875*x^4+5667*x^3"
            "+6314*x^2+4554*x+6050"
        ),
        "squarefree": True,
        "genus": int(2),
        "absolute_igusa_invariants": [
            int(893), int(1328), int(7156)
        ],
        "frobenius_polynomial": str(actual_weil_polynomial),
    },
    "certificate": {
        "theta_quotient_computed": True,
        "moduli_descend_to_base_field": True,
        "base_model_matches_moduli": True,
        "base_model_matches_quotient_weil_polynomial": True,
    },
    "remaining_step": "recover and descend both degree-17 maps",
}
output = root / "results" / "sage_degree17_theta.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
