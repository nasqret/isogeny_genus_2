"""Production acceptance benchmark for prepared recurrence in degree 31."""

from pathlib import Path


set_random_seed(0)
FREY_KANI_MAP_RECOVERY_CONFIG = {
    "workstream": "B026",
    "prime": 31,
    "field_order": 64853,
    "source_coefficients": [
        0, 18215, 18410, 40681, 52399, 1
    ],
    "elliptic_coefficients": [
        [48095, 18584],
        [1, 0],
    ],
    "hasse_witt_eigenvectors": [
        [1, 55105],
        [1, 54058],
    ],
    "frobenius_traces": [467, -494],
    "torsion_bases": [
        [[25371, 36533], [44319, 54650]],
        [[64587, 63692], [23062, 28841]],
    ],
    "anti_isometry_matrix": [[1, 0], [0, 11]],
    "extension_degree": 12,
    "sample_count": 70,
    "dual_isogeny_strategy": "explicit_degree_prime_extension",
    "explicit_root_extraction_strategy": "kummer_class",
    "kernel_recurrence_strategy": "prepared_basis_diff_add",
    "theta_power_sum_strategy": "coordinate_major",
    "output_filename": "sage_degree31_prepared_recurrence.json",
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
