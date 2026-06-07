"""Search for and certify an irreducible degree-37 Frey-Kani graph."""

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

prime = ZZ(37)
field_order = ZZ(128021)


def arithmetic_candidates(candidate_field):
    traces = admissible_full_torsion_traces(
        prime,
        candidate_field,
    )
    squareclasses = [
        ZZ(trace^2 - 4*candidate_field).squarefree_part()
        for trace in traces
    ]
    return traces, squareclasses


smaller_admissible_fields = []
for candidate_field in prime_range(2, field_order):
    candidate_field = ZZ(candidate_field)
    if candidate_field % prime != 1:
        continue
    candidate_traces, candidate_squareclasses = arithmetic_candidates(
        candidate_field
    )
    if (
        len(candidate_traces) >= 2
        and len(set(candidate_squareclasses)) >= 2
    ):
        smaller_admissible_fields.append(
            {
                "field_order": int(candidate_field),
                "traces": [int(value) for value in candidate_traces],
                "squareclasses": [
                    int(value) for value in candidate_squareclasses
                ],
            }
        )

assert smaller_admissible_fields == []
field_traces, field_squareclasses = arithmetic_candidates(field_order)
assert field_traces == [705, -664]
assert field_squareclasses == [-11, -13]

search = search_prime_frey_kani_curves(prime, field_order)
assert search["complete"]
assert search["admissible_traces"] == [705, -664]

entry1 = search["curves_by_trace"][ZZ(705)][0]
entry2 = search["curves_by_trace"][ZZ(-664)][0]
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

assert (E1.a4(), E1.a6()) == (94494, 115630)
assert (E2.a4(), E2.a6()) == (94047, 106345)
assert E1.abelian_group().invariants() == (37, 3441)
assert E2.abelian_group().invariants() == (37, 3478)
assert basis1 == (
    E1(125182, 24590),
    E1(45004, 43742),
)
assert basis2 == (
    E2(56059, 19346),
    E2(36636, 89945),
)
assert certificate["required_determinant"] == 21
assert certificate["anti_isometry_count"] == prime*(prime^2 - 1)
assert certificate["graph_size"] == prime^2
assert certificate["cm_squareclasses"] == (-11, -13)


def point_record(point):
    return [int(point[0]), int(point[1])]


def curve_record(entry):
    curve = entry["curve"]
    return {
        "equation": f"y^2=x^3+{curve.a4()}*x+{curve.a6()}",
        "a4": int(curve.a4()),
        "a6": int(curve.a6()),
        "j": str(entry["j"]),
        "cardinality": int(entry["cardinality"]),
        "group_invariants": [
            int(value) for value in entry["group_invariants"]
        ],
        "trace": int(entry["trace"]),
        "cm_squareclass": int(entry["cm_squareclass"]),
        "torsion_basis": [
            point_record(point) for point in entry["torsion_basis"]
        ],
    }


result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B027",
    "verified": True,
    "scope": "degree-37 candidate search and anti-isometry certificate",
    "field": "GF(128021)",
    "degree": int(prime),
    "field_minimality": {
        "first_prime_congruent_to_1_mod_37_with_two_admissible_traces": True,
        "smaller_admissible_fields": smaller_admissible_fields,
        "admissible_trace_squareclasses": [int(-11), int(-13)],
    },
    "admissible_traces": [
        int(value) for value in search["admissible_traces"]
    ],
    "curves": [curve_record(entry1), curve_record(entry2)],
    "anti_isometry": {
        "matrix": [
            [int(1), int(0)],
            [int(0), int(required_determinant)],
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
        "cm_squareclasses": [int(-11), int(-13)],
        "geometrically_nonisogenous": True,
        "frey_kani_irreducible": True,
        "geometric_quotient_is_smooth_genus2_jacobian": True,
    },
    "quotient_weil_polynomial": str(
        certificate["weil_polynomial"]
    ),
    "remaining_step": (
        "reconstruct the degree-37 quotient curve and its two maps"
    ),
}
output = root / "results" / "sage_degree37_anti_isometry.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
