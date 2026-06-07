"""
Search for and certify an irreducible degree-17 Frey-Kani graph.
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

prime = ZZ(17)
field_order = ZZ(8263)
search = search_prime_frey_kani_curves(prime, field_order)
assert search["complete"]
assert search["admissible_traces"] == [172, -117]

entry1 = search["curves_by_trace"][ZZ(172)][0]
entry2 = search["curves_by_trace"][ZZ(-117)][0]
E1 = entry1["curve"]
E2 = entry2["curve"]
basis1 = entry1["torsion_basis"]
basis2 = entry2["torsion_basis"]
pairing1 = basis1[0].weil_pairing(basis1[1], prime)
pairing2 = basis2[0].weil_pairing(basis2[1], prime)
required_determinant = pairing_compatible_determinant(
    pairing1,
    pairing2,
    prime,
)
anti_isometry_matrix = matrix(
    GF(prime),
    [[1, 0], [0, required_determinant]],
)
certificate = certify_prime_frey_kani_graph(
    E1,
    E2,
    prime,
    basis1,
    basis2,
    anti_isometry_matrix,
)

assert (E1.a4(), E1.a6()) == (0, 1728)
assert (E2.a4(), E2.a6()) == (6442, 3171)
assert E1.abelian_group().invariants() == (34, 238)
assert E2.abelian_group().invariants() == (17, 493)
assert certificate["required_determinant"] == 6
assert certificate["anti_isometry_count"] == 4896
assert certificate["graph_size"] == 289
assert certificate["cm_squareclasses"] == (-3, -67)


def curve_record(entry):
    curve = entry["curve"]
    return {
        "equation": (
            f"y^2=x^3+{curve.a4()}*x+{curve.a6()}"
        ),
        "j": str(entry["j"]),
        "cardinality": int(entry["cardinality"]),
        "group_invariants": [
            int(value) for value in entry["group_invariants"]
        ],
        "trace": int(entry["trace"]),
        "cm_squareclass": int(entry["cm_squareclass"]),
        "torsion_basis": [
            str(point) for point in entry["torsion_basis"]
        ],
    }


result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "prime-degree Frey-Kani synthesis",
    "verified": True,
    "scope": "degree-17 candidate search and anti-isometry certificate",
    "field": "GF(8263)",
    "degree": int(17),
    "admissible_traces": [
        int(value) for value in search["admissible_traces"]
    ],
    "curves": [curve_record(entry1), curve_record(entry2)],
    "anti_isometry": {
        "matrix": [
            [int(1), int(0)],
            [int(0), int(6)],
        ],
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
        "cm_squareclasses": [int(-3), int(-67)],
        "geometrically_nonisogenous": True,
        "frey_kani_irreducible": True,
        "geometric_quotient_is_smooth_genus2_jacobian": True,
    },
    "quotient_weil_polynomial": str(
        certificate["weil_polynomial"]
    ),
    "remaining_step": (
        "reconstruct the degree-17 quotient curve and its two maps"
    ),
}
output = root / "results" / "sage_degree17_anti_isometry.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
