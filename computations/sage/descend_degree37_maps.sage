"""Descend both degree-37 maps using the general Frey-Kani engine."""

from pathlib import Path


set_random_seed(0)
FREY_KANI_MAP_DESCENT_CONFIG = {
    "workstream": "B027",
    "prime": 37,
    "field_order": 128021,
    "source_coefficients": [
        123483, 75182, 59931, 44090, 21256, 49647, 36955
    ],
    "elliptic_coefficients": [
        [94494, 115630],
        [94047, 106345],
    ],
    "hasse_witt_eigenvectors": [
        [1, 27611],
        [1, 13761],
    ],
    "frobenius_traces": [705, -664],
    "torsion_bases": [
        [[125182, 24590], [45004, 43742]],
        [[56059, 19346], [36636, 89945]],
    ],
    "anti_isometry_matrix": [[1, 0], [0, 21]],
    "extension_degree": 12,
    "map_input_filename": "sage_degree37_maps.json",
    "output_filename": "sage_degree37_descended_maps.json",
    "remaining_step": "independent Magma verification of both maps",
}
load(
    str(
        Path.cwd()
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_map_descent.sage"
    )
)
