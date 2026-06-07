"""Benchmark one common root extension in degree-17 map recovery."""

from pathlib import Path


set_random_seed(0)
FREY_KANI_MAP_RECOVERY_CONFIG = {
    "workstream": "B022",
    "prime": 17,
    "field_order": 8263,
    "source_coefficients": [
        6050, 4554, 6314, 5667, 4875, 4306, 5422
    ],
    "elliptic_coefficients": [
        [0, 1728],
        [6442, 3171],
    ],
    "hasse_witt_eigenvectors": [
        [1, 3636],
        [1, 6247],
    ],
    "frobenius_traces": [172, -117],
    "torsion_bases": [
        [[3198, 717], [1807, 564]],
        [[7342, 3211], [4793, 6460]],
    ],
    "anti_isometry_matrix": [[1, 0], [0, 6]],
    "extension_degree": 12,
    "sample_count": 42,
    "dual_isogeny_strategy": "explicit_degree_prime_extension",
    "output_filename": "sage_degree17_extension_roots.json",
}
load(
    str(
        Path.cwd()
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_map_recovery.sage"
    )
)
