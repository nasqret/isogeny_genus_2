"""Benchmark one common root extension in degree-13 map recovery."""

from pathlib import Path


set_random_seed(0)
FREY_KANI_MAP_RECOVERY_CONFIG = {
    "workstream": "B022",
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
    "sample_count": 34,
    "dual_isogeny_strategy": "explicit_degree_prime_extension",
    "explicit_root_extraction_strategy": "individual_nth_root",
    "output_filename": "sage_degree13_extension_roots.json",
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
