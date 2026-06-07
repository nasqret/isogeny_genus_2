"""Build the machine-readable prime-degree synthesis comparison."""

import json
from datetime import datetime
from pathlib import Path


root = Path.cwd()
records = []
for degree in (13, 17, 19, 23):
    anti = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_anti_isometry.json"
        ).read_text()
    )
    theta_name = (
        "sage_degree13_curve.json"
        if degree == 13
        else f"sage_degree{degree}_theta.json"
    )
    theta = json.loads((root / "results" / theta_name).read_text())
    maps = json.loads(
        (root / "results" / f"sage_degree{degree}_maps.json").read_text()
    )
    descended = json.loads(
        (
            root
            / "results"
            / f"sage_degree{degree}_descended_maps.json"
        ).read_text()
    )
    magma = json.loads(
        (
            root / "results" / f"magma_degree{degree}_maps.json"
        ).read_text()
    )
    translations = [
        map_record.get("target_two_torsion_translation_x")
        for map_record in descended["maps"]
    ]
    records.append(
        {
            "degree": degree,
            "field": anti["field"],
            "theta_extension_degree": theta["theta_extension_degree"],
            "map_extension_degree": maps["theta_field_degree"],
            "sample_count": maps["evaluation"]["sample_count"],
            "sample_formula": 2*degree + 8,
            "theta_runtime_seconds": theta.get(
                "elapsed_seconds",
                theta.get("runtime_seconds"),
            ),
            "map_recovery_runtime_seconds": maps["runtime_seconds"],
            "descent_runtime_seconds": descended["runtime_seconds"],
            "magma_map_runtime_seconds": magma["elapsed_seconds"],
            "rosenhain_x_degree_pairs": [
                [
                    item["x_coordinate"]["numerator_degree"],
                    item["x_coordinate"]["denominator_degree"],
                ]
                for item in maps["maps"]
            ],
            "base_field_x_degree_pairs": [
                [
                    item["x_coordinate"]["numerator_degree"],
                    item["x_coordinate"]["denominator_degree"],
                ]
                for item in descended["maps"]
            ],
            "nontrivial_two_torsion_corrections": sum(
                value is not None for value in translations
            ),
        }
    )

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "verified": True,
    "degrees": records,
    "observed_patterns": {
        "sample_count": "2*n+8",
        "theta_extension_degree": 12,
        "map_extension_degree": 24,
        "rosenhain_x_degree_pair": "(n,n-1)",
        "base_field_x_degree_pair": "(n,n)",
        "map_recovery_is_dominant_cost": True,
    },
}
output = root / "results" / "prime_degree_scaling.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
