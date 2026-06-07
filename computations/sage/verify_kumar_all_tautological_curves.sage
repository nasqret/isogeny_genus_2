"""
Construct one tautological genus-2 curve for every Kumar degree 6 through 11.

This is the heavy B009 parser check.  In particular, degree 11 evaluates the
six coefficient assignments in the 3.1 MB upstream universal-curve file.
"""

import json
from datetime import datetime
from pathlib import Path
from time import perf_counter


started = perf_counter()
root = Path.cwd()
load(str(
    root
    / "computations"
    / "sage"
    / "lib"
    / "kumar_square_discriminant_families.sage"
))

sample_parameters = {
    6: (-3, -3),
    7: (QQ(4)/5, 1),
    8: (-3, -3),
    9: (-3, -3),
    10: (-3, -1),
    11: (-3, -3),
}
sample_z_values = {
    7: -QQ(23)/25,
}

certificates = []
for degree in KUMAR_DEGREES:
    item_started = perf_counter()
    r_value, s_value = sample_parameters[degree]
    specialization = specialize_kumar_family(
        degree,
        r_value,
        s_value,
        z_value=sample_z_values.get(degree),
    )
    sextic = specialization["source_polynomial"]
    curve = specialization["source_curve"]
    assert sextic.degree() == 6
    assert sextic.is_squarefree()
    assert curve.genus() == 2
    assert specialization["j_polynomial"].degree() == 2
    certificates.append({
        "degree": int(degree),
        "parameters": [str(r_value), str(s_value)],
        "surface_value": str(specialization["surface_value"]),
        "coefficient_field_degree": int(
            specialization["coefficient_field"].degree()
        ),
        "sextic_degree": int(sextic.degree()),
        "sextic_discriminant_nonzero": bool(
            sextic.discriminant() != 0
        ),
        "genus": int(curve.genus()),
        "j_polynomial": str(specialization["j_polynomial"]),
        "elapsed_seconds": float(round(
            perf_counter()-item_started,
            6,
        )),
    })

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B009",
    "verified": True,
    "scope": (
        "One exact nonsingular tautological genus-2 specialization in every "
        "degree 6 through 11"
    ),
    "certificates": certificates,
}

output = root / "results" / "sage_kumar_tautological_curves.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print(json.dumps(result, indent=2))
