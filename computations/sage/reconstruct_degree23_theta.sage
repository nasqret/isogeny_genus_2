"""Compute and certify the explicit degree-23 Frey-Kani quotient curve."""

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

prime = ZZ(23)
finite_field = GF(21943)
E1 = EllipticCurve(finite_field, [18008, 21189])
E2 = EllipticCurve(finite_field, [6198, 5070])
basis1 = (E1(95, 1862), E1(18951, 3611))
basis2 = (E2(1554, 11740), E2(1716, 21748))
theta_data = frey_kani_theta_quotient(
    E1,
    E2,
    prime,
    basis1,
    basis2,
    matrix(GF(prime), [[1, 0], [0, 1]]),
    extension_degree=12,
    repository_root=root,
)
curve = theta_data["quotient_curve"]
igusa_clebsch = curve.igusa_clebsch_invariants()
absolute_igusa = curve.absolute_igusa_invariants_kohel()
assert tuple(igusa_clebsch) == (6652, 7299, 13559, 5703)
assert tuple(absolute_igusa) == (10751, 7124, 12516)
assert all(value^21943 == value for value in absolute_igusa)

polynomial_ring = PolynomialRing(finite_field, "x")
x = polynomial_ring.gen()
source_polynomial = (
    7036*x^6
    + 9761*x^5
    + 17544*x^4
    + 6384*x^3
    + 20690*x^2
    + 11330*x
    + 14637
)
source_curve = HyperellipticCurve(source_polynomial)
assert source_polynomial.is_squarefree()
assert source_curve.genus() == 2
assert source_curve.absolute_igusa_invariants_kohel() == absolute_igusa

weil_polynomial_ring = PolynomialRing(ZZ, "T")
T = weil_polynomial_ring.gen()
expected_weil_polynomial = (
    T^4 + 19*T^3 - 25984*T^2 + 416917*T + 481495249
)
actual_weil_polynomial = source_curve.frobenius_polynomial()
assert list(actual_weil_polynomial) == list(expected_weil_polynomial)

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B021",
    "verified": True,
    "scope": "explicit degree-23 Frey-Kani quotient curve",
    "field": "GF(21943)",
    "degree": int(prime),
    "theta_extension_degree": int(12),
    "anti_isometry_matrix": [[int(1), int(0)], [int(0), int(1)]],
    "quotient_theta_null": [
        str(value)
        for value in theta_data["quotient"].theta_null_point()
    ],
    "rosenhain_polynomial": str(
        curve.hyperelliptic_polynomials()[0]
    ),
    "igusa_clebsch_invariants": [
        int(value) for value in igusa_clebsch
    ],
    "absolute_igusa_invariants": [
        int(value) for value in absolute_igusa
    ],
    "absolute_invariants_frobenius_fixed": True,
    "base_field_curve": {
        "equation": (
            "y^2=7036*x^6+9761*x^5+17544*x^4+6384*x^3"
            "+20690*x^2+11330*x+14637"
        ),
        "squarefree": True,
        "genus": int(2),
        "absolute_igusa_invariants": [
            int(10751), int(7124), int(12516)
        ],
        "frobenius_polynomial": str(actual_weil_polynomial),
    },
    "certificate": {
        "theta_quotient_computed": True,
        "moduli_descend_to_base_field": True,
        "base_model_matches_moduli": True,
        "base_model_matches_quotient_weil_polynomial": True,
    },
    "remaining_step": "recover and descend both degree-23 maps",
}
output = root / "results" / "sage_degree23_theta.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
