"""
Regression certificate for resumable CRT lifting of complete map coefficients.

The two degree-6 maps exercise both supported representations:

* X=A(x)/D(x);
* X=A(x)/D(x)+y*B(x)/D(x).

Run from the repository root:

    HOME=/tmp/sagehome sage \
        computations/sage/test_crt_coefficient_lifting.sage
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
    / "elliptic_cover_recovery.sage"
))

R.<x> = PolynomialRing(QQ)
source_polynomial = (
    x^6
    - 6*x^5
    + 7*x^4
    + QQ(28)/9*x^3
    - QQ(16)/3*x^2
    - QQ(16)/9*x
    + QQ(16)/81
)
E1 = EllipticCurve([0, 0, 0, -27, 90])
E2 = EllipticCurve([0, 0, 0, 81, -162])

rational_partial = discover_coefficients_by_crt(
    source_polynomial,
    E1,
    x,
    -1,
    6,
    (6, 6),
    [101],
    map_type="rational",
    target_center=E1(3, -6),
    precision=48,
    allow_partial=True,
)
assert not rational_partial["verified"]
rational_lift = discover_coefficients_by_crt(
    source_polynomial,
    E1,
    x,
    -1,
    6,
    (6, 6),
    [103, 107, 109, 113, 127],
    map_type="rational",
    target_center=E1(3, -6),
    precision=48,
    initial_state=rational_partial,
)
assert rational_lift["verified"]
assert rational_lift["map"]["degree"] == 6
assert rational_lift["map"]["identity_residual"] == 0

general_partial = discover_coefficients_by_crt(
    source_polynomial,
    E2,
    1,
    QQ(2)/3,
    6,
    (12, 9, 8),
    [101, 103, 107],
    map_type="general",
    precision=48,
    allow_partial=True,
)
assert not general_partial["verified"]
general_lift = discover_coefficients_by_crt(
    source_polynomial,
    E2,
    1,
    QQ(2)/3,
    6,
    (12, 9, 8),
    [109, 113, 127, 131, 137, 139, 149, 151, 157, 163],
    map_type="general",
    precision=48,
    initial_state=general_partial,
)
assert general_lift["verified"]
assert general_lift["map"]["cover_degree"] == 6
assert general_lift["map"]["x_coordinate_degree"] == 12
assert general_lift["map"]["identity_residual"] == (0, 0)

exact_rational = recover_elliptic_cover(
    source_polynomial,
    E1,
    x,
    -1,
    cover_degree=6,
    degree_bounds=(6, 6),
    target_center=E1(3, -6),
    precision=48,
)
exact_general = recover_general_elliptic_cover(
    source_polynomial,
    E2,
    1,
    QQ(2)/3,
    6,
    (12, 9, 8),
    precision=48,
)
assert (
    rational_lift["map"]["x_coordinate"]
    == exact_rational["x_coordinate"]
)
assert (
    general_lift["map"]["x_coordinate"]
    == exact_general["x_coordinate"]
)

elapsed = perf_counter()-started
result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "elapsed_seconds": float(round(elapsed, 6)),
    "workstream": "B012",
    "verified": True,
    "scope": (
        "Resumable CRT reconstruction of every projective coefficient "
        "in rational and full quadratic-function elliptic maps"
    ),
    "cases": [
        {
            "label": "degree6_rational",
            "map_type": "rational",
            "degree_bounds": [int(6), int(6)],
            "cover_degree": int(6),
            "partial_modulus_bits": int(
                rational_partial["crt_modulus"].nbits()
            ),
            "final_modulus_bits": int(
                rational_lift["crt_modulus"].nbits()
            ),
            "pivot_index": int(rational_lift["pivot_index"]),
            "prime_count": len(rational_lift["certificates"]),
            "failure_count": len(rational_lift["failures"]),
            "x_coordinate": str(
                rational_lift["map"]["x_coordinate"]
            ),
        },
        {
            "label": "degree6_general",
            "map_type": "general",
            "degree_bounds": [int(12), int(9), int(8)],
            "cover_degree": int(6),
            "partial_modulus_bits": int(
                general_partial["crt_modulus"].nbits()
            ),
            "final_modulus_bits": int(
                general_lift["crt_modulus"].nbits()
            ),
            "pivot_index": int(general_lift["pivot_index"]),
            "prime_count": len(general_lift["certificates"]),
            "failure_count": len(general_lift["failures"]),
            "x_coordinate": {
                "rational_part": str(
                    general_lift["map"]["x_coordinate"][0]
                ),
                "y_part": str(
                    general_lift["map"]["x_coordinate"][1]
                ),
            },
        },
    ],
}

output = root / "results" / "sage_crt_coefficient_lifting.json"
output.write_text(
    json.dumps(result, indent=2) + "\n",
    encoding="utf-8",
)
print(json.dumps(result, indent=2))
