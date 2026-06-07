"""Compute the degree-29 Frey-Kani quotient theta null and moduli."""

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

prime = ZZ(29)
finite_field = GF(50867)
E1 = EllipticCurve(finite_field, [18068, 28770])
E2 = EllipticCurve(finite_field, [16732, 29860])
basis1 = (
    E1(24954, 13946),
    E1(40497, 37256),
)
basis2 = (
    E2(45037, 16292),
    E2(32423, 11221),
)
theta_data = frey_kani_theta_quotient(
    E1,
    E2,
    prime,
    basis1,
    basis2,
    matrix(GF(prime), [[1, 0], [0, 24]]),
    extension_degree=12,
    repository_root=root,
)
curve = theta_data["quotient_curve"]
igusa_clebsch = curve.igusa_clebsch_invariants()
absolute_igusa = curve.absolute_igusa_invariants_kohel()
assert tuple(absolute_igusa) == (15563, 43108, 4996)
assert all(value^50867 == value for value in absolute_igusa)

# For I2=1, Kohel's invariants are
# (I4*I6/I10, I4/I10, I6/I10).
i1, i2, i3 = absolute_igusa
normalized_igusa_clebsch = (
    curve.base_ring()(1),
    i1/i3,
    i1/i2,
    i1/(i2*i3),
)
assert normalized_igusa_clebsch[1]/normalized_igusa_clebsch[3] == i2
assert normalized_igusa_clebsch[2]/normalized_igusa_clebsch[3] == i3
assert (
    normalized_igusa_clebsch[1]
    * normalized_igusa_clebsch[2]
    / normalized_igusa_clebsch[3]
    == i1
)
assert all(
    value^50867 == value for value in normalized_igusa_clebsch
)

weil_polynomial_ring = PolynomialRing(ZZ, "T")
T = weil_polynomial_ring.gen()
expected_weil_polynomial = (
    T^4 + 25*T^3 - 74930*T^2 + 1271675*T + 2587451689
)

polynomial_ring = PolynomialRing(finite_field, "x")
x = polynomial_ring.gen()
source_polynomial = (
    24513*x^6
    + 50615*x^5
    + 5530*x^4
    + 37221*x^3
    + 46765*x^2
    + 234*x
    + 31812
)
source_curve = HyperellipticCurve(source_polynomial)
assert source_polynomial.is_squarefree()
assert source_curve.genus() == 2
assert source_curve.absolute_igusa_invariants_kohel() == absolute_igusa
actual_weil_polynomial = source_curve.frobenius_polynomial()
assert list(actual_weil_polynomial) == list(expected_weil_polynomial)

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B024",
    "verified": True,
    "status": "verified",
    "scope": "explicit degree-29 Frey-Kani quotient curve",
    "field": "GF(50867)",
    "degree": int(prime),
    "theta_extension_degree": int(12),
    "anti_isometry_matrix": [
        [int(1), int(0)],
        [int(0), int(24)],
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
    "normalized_igusa_clebsch": [
        int(value) for value in normalized_igusa_clebsch
    ],
    "absolute_invariants_frobenius_fixed": True,
    "expected_quotient_weil_polynomial": str(
        expected_weil_polynomial
    ),
    "base_field_curve": {
        "equation": (
            "y^2=24513*x^6+50615*x^5+5530*x^4+37221*x^3"
            "+46765*x^2+234*x+31812"
        ),
        "coefficients_ascending": [
            int(31812),
            int(234),
            int(46765),
            int(37221),
            int(5530),
            int(50615),
            int(24513),
        ],
        "squarefree": True,
        "genus": int(2),
        "absolute_igusa_invariants": [
            int(15563), int(43108), int(4996)
        ],
        "frobenius_polynomial": str(actual_weil_polynomial),
    },
    "certificate": {
        "theta_quotient_computed": True,
        "moduli_descend_to_base_field": True,
        "normalized_mestre_input_computed": True,
        "base_model_matches_moduli": True,
        "base_model_matches_quotient_weil_polynomial": True,
    },
    "remaining_step": "recover and descend both degree-29 maps",
}
output = root / "results" / "sage_degree29_theta.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
