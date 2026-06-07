"""Aggregate the exact odd-prime Frobenius descent certificates."""

import json
from datetime import datetime, timezone
from pathlib import Path


root = Path.cwd()
input_files = [
    "sage_degree13_descended_maps.json",
    "sage_degree17_descended_maps.json",
    "sage_degree19_descended_maps.json",
    "sage_degree23_descended_maps.json",
    "sage_degree29_descended_maps.json",
    "sage_degree31_descended_maps.json",
    "sage_degree37_descended_maps.json",
]

cases = []
for filename in input_files:
    data = json.loads((root / "results" / filename).read_text())
    assert data["status"] == "verified"
    for record in data["maps"]:
        degree = record["cover_degree"]
        factor_index = record["factor_index"]
        cocycle = record["descent_cocycle"]
        permutation = cocycle["frobenius_action_on_two_torsion"]
        rational_indices = cocycle["rational_two_torsion_indices"]
        correction_indices = cocycle["correction_candidate_indices"]

        assert sorted(permutation) == list(range(4))
        assert permutation[0] == 0
        assert rational_indices == [
            index
            for index, image_index in enumerate(permutation)
            if image_index == index
        ]
        assert len(correction_indices) == len(rational_indices)
        assert cocycle["selected_correction_index"] in correction_indices
        assert cocycle["direct_descent"] == (
            cocycle["frobenius_translation_index"] == 0
        )
        assert cocycle["cocycle_norm_zero"]
        assert cocycle["selected_coboundary_equation_verified"]
        assert cocycle["correction_coset_equals_rational_two_torsion"]
        assert record["coefficients_in_base_field"]
        assert record["elliptic_equation_identity"]
        assert record["linear_differential_pullback"]

        cases.append(
            {
                "degree": degree,
                "factor_index": factor_index,
                "target_j_invariant": record["target_j_invariant"],
                "frobenius_action_on_two_torsion": permutation,
                "frobenius_translation_index": cocycle[
                    "frobenius_translation_index"
                ],
                "rational_two_torsion_indices": rational_indices,
                "correction_candidate_indices": correction_indices,
                "selected_correction_index": cocycle[
                    "selected_correction_index"
                ],
                "direct_descent": cocycle["direct_descent"],
            }
        )

nontrivial_cases = [
    [case["degree"], case["factor_index"]]
    for case in cases
    if not case["direct_descent"]
]
assert nontrivial_cases == [[17, 1], [19, 1], [29, 1]]
assert len(cases) == 14

result = {
    "workstream": "B023",
    "status": "verified",
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "scope": (
        "Frobenius translation cocycles and 2-torsion coboundary "
        "corrections for both maps in degrees 13, 17, 19, 23, 29, 31, and 37"
    ),
    "case_count": len(cases),
    "direct_descent_count": sum(
        case["direct_descent"] for case in cases
    ),
    "nontrivial_cocycle_count": len(nontrivial_cases),
    "nontrivial_cases": nontrivial_cases,
    "cases": cases,
    "certificate": {
        "all_frobenius_actions_are_permutations_of_E2": True,
        "all_frobenius_translation_cocycles_identified": True,
        "all_cocycle_norms_zero": True,
        "all_selected_coboundary_equations_verified": True,
        "every_correction_set_is_an_E2_base_field_coset": True,
        "all_descended_map_identities_verified": True,
    },
}

output = root / "results" / "sage_prime_degree_descent_cocycles.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print("PRIME_DEGREE_DESCENT_COCYCLES verified")
print("cases", len(cases))
print("direct", result["direct_descent_count"])
print("nontrivial", nontrivial_cases)
print("result", output)
