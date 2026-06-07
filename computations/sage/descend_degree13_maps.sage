"""Descend both degree-13 maps using the general Frey-Kani engine."""

from pathlib import Path


FREY_KANI_MAP_DESCENT_CONFIG = {
    "workstream": "B014",
    "prime": 13,
    "field_order": 8009,
    "source_coefficients": [
        84, 5767, 4018, 3661, 6357, 4620, 6042
    ],
    "elliptic_coefficients": [
        [5553, 5419],
        [2531, 1402],
    ],
    "hasse_witt_eigenvectors": [
        [1, 3779],
        [1, 7873],
    ],
    "frobenius_traces": [67, -102],
    "torsion_bases": [
        [[3600, 411], [5265, 3005]],
        [[6171, 1633], [3628, 2373]],
    ],
    "anti_isometry_matrix": [[1, 0], [0, 3]],
    "extension_degree": 12,
    "map_input_filename": "sage_degree13_maps.json",
    "output_filename": "sage_degree13_descended_maps.json",
    "remaining_step": "synthesize prime-degree examples beyond degree 13",
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
