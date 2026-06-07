"""Descend both degree-29 maps using the general Frey-Kani engine."""

from pathlib import Path


set_random_seed(0)
FREY_KANI_MAP_DESCENT_CONFIG = {
    "workstream": "B024",
    "prime": 29,
    "field_order": 50867,
    "source_coefficients": [
        31812, 234, 46765, 37221, 5530, 50615, 24513
    ],
    "elliptic_coefficients": [
        [18068, 28770],
        [16732, 29860],
    ],
    "hasse_witt_eigenvectors": [
        [1, 4375],
        [1, 33334],
    ],
    "frobenius_traces": [408, -433],
    "torsion_bases": [
        [[24954, 13946], [40497, 37256]],
        [[45037, 16292], [32423, 11221]],
    ],
    "anti_isometry_matrix": [[1, 0], [0, 24]],
    "extension_degree": 12,
    "map_input_filename": "sage_degree29_maps.json",
    "output_filename": "sage_degree29_descended_maps.json",
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
