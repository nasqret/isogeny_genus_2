"""
Reconstruct and certify the genus-2 quotient of the degree-13 graph.

This verifies the theta quotient over F_(8009^12), descends its absolute
Igusa invariants to F_8009, and checks the explicit base-field curve returned
by the independent Magma Mestre reconstruction.
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
load(
    str(
        root
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_synthesis.sage"
    )
)
load(
    str(
        root
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_theta_gluing.sage"
    )
)

prime = ZZ(13)
base_field = GF(8009)
E1 = EllipticCurve(base_field, [5553, 5419])
E2 = EllipticCurve(base_field, [2531, 1402])
P1 = E1(3600, 411)
P2 = E1(5265, 3005)
Q1 = E2(6171, 1633)
Q2 = E2(3628, 2373)
anti_isometry_matrix = matrix(GF(prime), [[1, 0], [0, 3]])

graph_certificate = certify_prime_frey_kani_graph(
    E1,
    E2,
    prime,
    (P1, P2),
    (Q1, Q2),
    anti_isometry_matrix,
)
theta_certificate = frey_kani_theta_quotient(
    E1,
    E2,
    prime,
    (P1, P2),
    (Q1, Q2),
    anti_isometry_matrix,
    extension_degree=12,
    repository_root=root,
)

quotient = theta_certificate["quotient"]
rosenhain_curve = theta_certificate["quotient_curve"]
igusa_clebsch = rosenhain_curve.igusa_clebsch_invariants()
absolute_igusa = rosenhain_curve.absolute_igusa_invariants_kohel()
assert tuple(igusa_clebsch) == (2419, 7563, 6738, 5346)
assert tuple(absolute_igusa) == (4139, 7829, 4340)
assert all(value^8009 == value for value in absolute_igusa)

polynomial_ring = PolynomialRing(base_field, "x")
x = polynomial_ring.gen()
source_polynomial = (
    6042*x^6
    + 4620*x^5
    + 6357*x^4
    + 3661*x^3
    + 4018*x^2
    + 5767*x
    + 84
)
source_curve = HyperellipticCurve(source_polynomial)
assert source_polynomial.is_squarefree()
assert source_curve.genus() == 2
assert source_curve.absolute_igusa_invariants_kohel() == absolute_igusa

expected_weil_polynomial = graph_certificate["weil_polynomial"]
actual_weil_polynomial = source_curve.frobenius_polynomial()
assert list(actual_weil_polynomial) == list(expected_weil_polynomial)

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B014",
    "verified": True,
    "scope": "explicit degree-13 Frey-Kani quotient curve",
    "dependency": {
        "name": "AVIsogenies Sage branch",
        "repository": "https://gitlab.inria.fr/roberdam/avisogenies.git",
        "commit": "e488a54304a5b5bcd0ae8c58d0ab82aeb02d6746",
        "license": "GPL-3.0",
    },
    "field": "GF(8009)",
    "theta_extension_degree": int(12),
    "degree": int(prime),
    "anti_isometry_matrix": [[int(1), int(0)], [int(0), int(3)]],
    "quotient_theta_null": [
        str(value) for value in quotient.theta_null_point()
    ],
    "rosenhain_polynomial_over_theta_extension": str(
        rosenhain_curve.hyperelliptic_polynomials()[0]
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
            "y^2=6042*x^6+4620*x^5+6357*x^4+3661*x^3"
            "+4018*x^2+5767*x+84"
        ),
        "squarefree": True,
        "genus": int(2),
        "absolute_igusa_invariants": [
            int(4139), int(7829), int(4340)
        ],
        "frobenius_polynomial": str(actual_weil_polynomial),
    },
    "certificate": {
        "elliptic_kummer_arithmetic": True,
        "product_graph_arithmetic": True,
        "theta_quotient_computed": True,
        "moduli_descend_to_base_field": True,
        "base_model_matches_moduli": True,
        "base_model_matches_quotient_weil_polynomial": True,
    },
    "remaining_step": (
        "transport the recovered maps to the fixed F_8009 sextic "
        "and certify them independently in Magma"
    ),
}

output = root / "results" / "sage_degree13_curve.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
