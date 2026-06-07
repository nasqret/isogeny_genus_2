"""
Initial Frey-Kani synthesis certificate beyond degree 11.

This constructs an irreducible degree-13 anti-isometry graph over F_8009.
The quotient principal polarization is therefore geometrically the Jacobian
of a smooth genus-2 curve.
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
load(str(root / "computations" / "sage" / "lib" / "frey_kani_synthesis.sage"))

prime = ZZ(13)
finite_field = GF(8009)
E1 = EllipticCurve(finite_field, [5553, 5419])
E2 = EllipticCurve(finite_field, [2531, 1402])

P1 = E1(3600, 411)
P2 = E1(5265, 3005)
Q1 = E2(6171, 1633)
Q2 = E2(3628, 2373)

anti_isometry_matrix = matrix(GF(prime), [[1, 0], [0, 3]])
certificate = certify_prime_frey_kani_graph(
    E1,
    E2,
    prime,
    (P1, P2),
    (Q1, Q2),
    anti_isometry_matrix,
)

assert E1.cardinality() == 7943
assert E2.cardinality() == 8112
assert E1.abelian_group().invariants() == (13, 611)
assert E2.abelian_group().invariants() == (13, 624)
assert certificate["anti_isometry_count"] == 2184
assert certificate["graph_size"] == 169
assert certificate["cm_squareclasses"] == (-163, -2)

result = {
    "generated_at": datetime.now().astimezone().isoformat(timespec="seconds"),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B014",
    "verified": True,
    "scope": "initial finite-field Frey-Kani synthesis in prime degree 13",
    "field": "GF(8009)",
    "degree": int(13),
    "curves": [
        {
            "equation": "y^2=x^3+5553*x+5419",
            "j": str(E1.j_invariant()),
            "cardinality": int(E1.cardinality()),
            "group_invariants": [
                int(value)
                for value in E1.abelian_group().invariants()
            ],
            "trace": int(certificate["traces"][0]),
            "cm_squareclass": int(
                certificate["cm_squareclasses"][0]
            ),
            "torsion_basis": [str(P1), str(P2)],
        },
        {
            "equation": "y^2=x^3+2531*x+1402",
            "j": str(E2.j_invariant()),
            "cardinality": int(E2.cardinality()),
            "group_invariants": [
                int(value)
                for value in E2.abelian_group().invariants()
            ],
            "trace": int(certificate["traces"][1]),
            "cm_squareclass": int(
                certificate["cm_squareclasses"][1]
            ),
            "torsion_basis": [str(Q1), str(Q2)],
        },
    ],
    "anti_isometry": {
        "matrix": [[int(1), int(0)], [int(0), int(3)]],
        "required_determinant_in_chosen_bases": int(
            certificate["required_determinant"]
        ),
        "compatible_matrix_count": int(
            certificate["anti_isometry_count"]
        ),
        "pairing_1": str(certificate["pairing1"]),
        "pairing_2_after_map": str(
            certificate["pairing2_after_map"]
        ),
        "pairing_product": "1",
    },
    "graph": {
        "size": int(certificate["graph_size"]),
        "maximal_isotropic": True,
    },
    "irreducibility": {
        "geometrically_nonisogenous": True,
        "reason": (
            "ordinary endomorphism fields Q(sqrt(-163)) and "
            "Q(sqrt(-2)) are distinct"
        ),
        "frey_kani_irreducible": True,
        "geometric_quotient_is_smooth_genus2_jacobian": True,
    },
    "quotient_weil_polynomial": str(
        certificate["weil_polynomial"]
    ),
    "remaining_step": (
        "reconstruct an explicit genus-2 curve and its two degree-13 maps"
    ),
}

output = root / "results" / "sage_degree13_anti_isometry.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
