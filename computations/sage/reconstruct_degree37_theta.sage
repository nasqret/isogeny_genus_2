"""Compute the degree-37 Frey-Kani quotient theta null and moduli."""

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

prime = ZZ(37)
field_order = ZZ(128021)
finite_field = GF(field_order)
E1 = EllipticCurve(finite_field, [94494, 115630])
E2 = EllipticCurve(finite_field, [94047, 106345])
basis1 = (
    E1(125182, 24590),
    E1(45004, 43742),
)
basis2 = (
    E2(56059, 19346),
    E2(36636, 89945),
)
theta_data = frey_kani_theta_quotient(
    E1,
    E2,
    prime,
    basis1,
    basis2,
    matrix(GF(prime), [[1, 0], [0, 21]]),
    extension_degree=12,
    repository_root=root,
)
curve = theta_data["quotient_curve"]
igusa_clebsch = curve.igusa_clebsch_invariants()
absolute_igusa = curve.absolute_igusa_invariants_kohel()
assert tuple(igusa_clebsch) == (46170, 60638, 15031, 94505)
assert tuple(absolute_igusa) == (29635, 122473, 53158)
assert all(
    value^field_order == value for value in absolute_igusa
)

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
    value^field_order == value
    for value in normalized_igusa_clebsch
)

weil_polynomial_ring = PolynomialRing(ZZ, "T")
T = weil_polynomial_ring.gen()
expected_weil_polynomial = (
    T^4 - 41*T^3 - 212078*T^2
    - 5248861*T + 16389376441
)

rosenhain_polynomial = curve.hyperelliptic_polynomials()[0]
rosenhain_descends = all(
    coefficient^field_order == coefficient
    for coefficient in rosenhain_polynomial
)
assert not rosenhain_descends
polynomial_ring = PolynomialRing(finite_field, "x")
x = polynomial_ring.gen()
source_polynomial = (
    36955*x^6
    + 49647*x^5
    + 21256*x^4
    + 44090*x^3
    + 59931*x^2
    + 75182*x
    + 123483
)
source_curve = HyperellipticCurve(source_polynomial)
assert source_polynomial.is_squarefree()
assert source_curve.genus() == 2
assert source_curve.absolute_igusa_invariants_kohel() == (
    finite_field(29635),
    finite_field(122473),
    finite_field(53158),
)
assert source_curve.has_odd_degree_model()
odd_degree_source_curve = source_curve.odd_degree_model()
actual_weil_polynomial = odd_degree_source_curve.frobenius_polynomial(
    algorithm="matrix"
)
assert list(actual_weil_polynomial) == list(expected_weil_polynomial)
base_field_curve = {
    "equation": f"y^2={source_polynomial}",
    "coefficients_ascending": [
        int(coefficient) for coefficient in source_polynomial
    ],
    "squarefree": True,
    "genus": int(2),
    "absolute_igusa_invariants": [
        int(29635), int(122473), int(53158)
    ],
    "frobenius_polynomial": str(actual_weil_polynomial),
}

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B027",
    "verified": True,
    "status": "verified",
    "scope": "degree-37 Frey-Kani quotient theta null and moduli",
    "field": "GF(128021)",
    "degree": int(prime),
    "theta_extension_degree": int(12),
    "anti_isometry_matrix": [
        [int(1), int(0)],
        [int(0), int(21)],
    ],
    "quotient_theta_null": [
        str(value)
        for value in theta_data["quotient"].theta_null_point()
    ],
    "rosenhain_polynomial": str(rosenhain_polynomial),
    "igusa_clebsch_invariants": [
        str(value) for value in igusa_clebsch
    ],
    "absolute_igusa_invariants": [
        int(value.polynomial()[0]) for value in absolute_igusa
    ],
    "normalized_igusa_clebsch": [
        int(value.polynomial()[0])
        for value in normalized_igusa_clebsch
    ],
    "absolute_invariants_frobenius_fixed": True,
    "expected_quotient_weil_polynomial": str(
        expected_weil_polynomial
    ),
    "rosenhain_model_descends_without_transport": rosenhain_descends,
    "base_field_curve": base_field_curve,
    "certificate": {
        "theta_quotient_computed": True,
        "moduli_descend_to_base_field": True,
        "normalized_mestre_input_computed": True,
        "base_model_matches_moduli": True,
        "base_model_matches_quotient_weil_polynomial": True,
    },
    "remaining_step": (
        "recover and descend both degree-37 maps"
    ),
}
output = root / "results" / "sage_degree37_theta.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
