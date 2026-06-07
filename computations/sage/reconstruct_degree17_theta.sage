"""Compute the explicit degree-17 Frey-Kani theta quotient."""

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

prime = ZZ(17)
finite_field = GF(8263)
E1 = EllipticCurve(finite_field, [0, 1728])
E2 = EllipticCurve(finite_field, [6442, 3171])
basis1 = (
    E1(3198, 717),
    E1(1807, 564),
)
basis2 = (
    E2(7342, 3211),
    E2(4793, 6460),
)
theta_data = frey_kani_theta_quotient(
    E1,
    E2,
    prime,
    basis1,
    basis2,
    matrix(GF(prime), [[1, 0], [0, 6]]),
    extension_degree=12,
    repository_root=root,
)
curve = theta_data["quotient_curve"]
igusa_clebsch = curve.igusa_clebsch_invariants()
absolute_igusa = curve.absolute_igusa_invariants_kohel()
assert tuple(absolute_igusa) == (893, 1328, 7156)
assert all(value^8263 == value for value in absolute_igusa)

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(perf_counter() - started, 6)),
    "workstream": "B019",
    "verified": True,
    "scope": "explicit degree-17 Frey-Kani theta quotient",
    "field": "GF(8263)",
    "degree": int(17),
    "theta_extension_degree": int(12),
    "anti_isometry_matrix": [
        [int(1), int(0)],
        [int(0), int(6)],
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
    "absolute_invariants_frobenius_fixed": True,
    "remaining_step": (
        "reconstruct a fixed F_8263 model and recover both degree-17 maps"
    ),
}
output = root / "results" / "sage_degree17_theta.json"
output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
