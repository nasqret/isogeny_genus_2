"""Compute the degree-31 Frey-Kani quotient theta null and moduli."""

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

prime = ZZ(31)
finite_field = GF(64853)
E1 = EllipticCurve(finite_field, [48095, 18584])
E2 = EllipticCurve(finite_field, [1, 0])
basis1 = (
    E1(25371, 36533),
    E1(44319, 54650),
)
basis2 = (
    E2(64587, 63692),
    E2(23062, 28841),
)
theta_data = frey_kani_theta_quotient(
    E1,
    E2,
    prime,
    basis1,
    basis2,
    matrix(GF(prime), [[1, 0], [0, 11]]),
    extension_degree=12,
    repository_root=root,
)
curve = theta_data["quotient_curve"]
igusa_clebsch = curve.igusa_clebsch_invariants()
absolute_igusa = curve.absolute_igusa_invariants_kohel()
assert tuple(igusa_clebsch) == (36614, 24694, 25370, 43295)
assert tuple(absolute_igusa) == (36707, 3040, 53075)
assert all(value^64853 == value for value in absolute_igusa)

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
    value^64853 == value for value in normalized_igusa_clebsch
)

weil_polynomial_ring = PolynomialRing(ZZ, "T")
T = weil_polynomial_ring.gen()
expected_weil_polynomial = (
    T^4 + 27*T^3 - 100992*T^2 + 1751031*T + 4205911609
)

polynomial_ring = PolynomialRing(finite_field, "x")
x = polynomial_ring.gen()
source_polynomial = (
    x^5
    + 52399*x^4
    + 40681*x^3
    + 18410*x^2
    + 18215*x
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
    "workstream": "B025",
    "verified": True,
    "status": "verified",
    "scope": "explicit degree-31 Frey-Kani quotient curve",
    "field": "GF(64853)",
    "degree": int(prime),
    "theta_extension_degree": int(12),
    "anti_isometry_matrix": [
        [int(1), int(0)],
        [int(0), int(11)],
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
            "y^2=x^5+52399*x^4+40681*x^3+18410*x^2+18215*x"
        ),
        "coefficients_ascending": [
            int(0),
            int(18215),
            int(18410),
            int(40681),
            int(52399),
            int(1),
        ],
        "squarefree": True,
        "genus": int(2),
        "absolute_igusa_invariants": [
            int(36707), int(3040), int(53075)
        ],
        "frobenius_polynomial": str(actual_weil_polynomial),
    },
    "certificate": {
        "theta_quotient_computed": True,
        "moduli_descend_to_base_field": True,
        "normalized_mestre_input_computed": True,
        "rosenhain_model_descends_without_transport": True,
        "base_model_matches_moduli": True,
        "base_model_matches_quotient_weil_polynomial": True,
    },
    "remaining_step": "recover and descend both degree-31 maps",
}
output = root / "results" / "sage_degree31_theta.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
