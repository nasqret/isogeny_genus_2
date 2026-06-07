"""Recover both degree-23 maps using the general Frey-Kani engine."""

from pathlib import Path


set_random_seed(0)
FREY_KANI_MAP_RECOVERY_CONFIG = {
    "workstream": "B021",
    "prime": 23,
    "field_order": 21943,
    "source_coefficients": [
        14637, 11330, 20690, 6384, 17544, 9761, 7036
    ],
    "elliptic_coefficients": [
        [18008, 21189],
        [6198, 5070],
    ],
    "hasse_witt_eigenvectors": [
        [1, 19333],
        [1, 19653],
    ],
    "frobenius_traces": [255, -274],
    "torsion_bases": [
        [[95, 1862], [18951, 3611]],
        [[1554, 11740], [1716, 21748]],
    ],
    "anti_isometry_matrix": [[1, 0], [0, 1]],
    "extension_degree": 12,
    "sample_count": 54,
    "output_filename": "sage_degree23_maps.json",
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
