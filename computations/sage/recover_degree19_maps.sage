"""Recover both degree-19 maps using the general Frey-Kani engine."""

from pathlib import Path


set_random_seed(0)
FREY_KANI_MAP_RECOVERY_CONFIG = {
    "workstream": "B020",
    "prime": 19,
    "field_order": 11743,
    "source_coefficients": [
        3417, 4884, 1439, 7190, 6679, 7591, 9500
    ],
    "elliptic_coefficients": [
        [8444, 6205],
        [4036, 11557],
    ],
    "hasse_witt_eigenvectors": [
        [1, 8272],
        [1, 5957],
    ],
    "frobenius_traces": [192, -169],
    "torsion_bases": [
        [[2689, 8983], [6025, 7701]],
        [[7067, 8512], [1751, 5524]],
    ],
    "anti_isometry_matrix": [[1, 0], [0, 16]],
    "extension_degree": 12,
    "sample_count": 46,
    "output_filename": "sage_degree19_maps.json",
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
