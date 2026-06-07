"""Configuration-driven recovery of both maps from a Frey-Kani quotient."""

import json
import time
from functools import partial
from itertools import accumulate
from pathlib import Path

from sage.misc.mrange import cantor_product


started_at = time.time()
root = Path.cwd()
config = FREY_KANI_MAP_RECOVERY_CONFIG
phase_timings = {}


def start_phase(name):
    print(f"PHASE_START {name}", flush=True)
    return time.perf_counter()


def finish_phase(name, phase_started):
    elapsed = time.perf_counter() - phase_started
    phase_timings[name] = elapsed
    print(f"PHASE_DONE {name} {elapsed:.6f}", flush=True)


load(
    str(
        root
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_theta_gluing.sage"
    )
)

prime = ZZ(config["prime"])
field_order = ZZ(config["field_order"])
finite_field = GF(field_order)
source_ring = PolynomialRing(finite_field, "x")
x = source_ring.gen()
source_polynomial = source_ring(
    config["source_coefficients"]
)
elliptic_curves = [
    EllipticCurve(finite_field, coefficients)
    for coefficients in config["elliptic_coefficients"]
]

hasse_power = source_polynomial^((field_order - 1)//2)
hasse_witt = matrix(
    finite_field,
    [
        [
            hasse_power[field_order - 1],
            hasse_power[field_order - 2],
        ],
        [
            hasse_power[2*field_order - 1],
            hasse_power[2*field_order - 2],
        ],
    ],
)
for eigenvector, eigenvalue in zip(
    config["hasse_witt_eigenvectors"],
    config["frobenius_traces"],
):
    eigenvector = vector(finite_field, eigenvector)
    assert hasse_witt*eigenvector == finite_field(eigenvalue)*eigenvector

torsion_bases = [
    tuple(
        elliptic_curve(*coordinates)
        for coordinates in basis
    )
    for elliptic_curve, basis in zip(
        elliptic_curves,
        config["torsion_bases"],
    )
]
anti_isometry_matrix = matrix(
    GF(prime),
    config["anti_isometry_matrix"],
)
phase_started = start_phase("theta_quotient")
theta_data = frey_kani_theta_quotient(
    elliptic_curves[0],
    elliptic_curves[1],
    prime,
    torsion_bases[0],
    torsion_bases[1],
    anti_isometry_matrix,
    extension_degree=config.get("extension_degree", 12),
    repository_root=root,
    compute_dual=True,
)
finish_phase("theta_quotient", phase_started)

rosenhain_curve = theta_data["quotient_curve"]
rosenhain_polynomial = rosenhain_curve.hyperelliptic_polynomials()[0]
extension_field = theta_data["extension_field"]
analytic = theta_data["analytic_quotient"]
analytic._curve = rosenhain_curve
analytic._phi = rosenhain_curve.identity_morphism()
analytic_index = lambda coordinates: ZZ(list(coordinates), 2)
analytic_power = analytic.level()/2
rosenhain_l = (
    analytic[0]*analytic[analytic_index([0, 1, 0, 0])]
    / (
        analytic[analytic_index([1, 0, 0, 0])]
        * analytic[analytic_index([1, 1, 0, 0])]
    )
)^analytic_power
rosenhain_m = (
    analytic[analytic_index([0, 0, 0, 1])]
    * analytic[analytic_index([0, 1, 0, 0])]
    / (
        analytic[analytic_index([1, 0, 0, 1])]
        * analytic[analytic_index([1, 1, 0, 0])]
    )
)^analytic_power
rosenhain_n = (
    analytic[0]*analytic[analytic_index([0, 0, 0, 1])]
    / (
        analytic[analytic_index([1, 0, 0, 0])]
        * analytic[analytic_index([1, 0, 0, 1])]
    )
)^analytic_power
analytic._wp = [
    extension_field(0),
    extension_field(1),
    rosenhain_l,
    rosenhain_m,
    rosenhain_n,
]
analytic._rac = extension_field(1)

load_avisogenies_sage(root)
from avisogenies_sage.analytic_theta_point import AnalyticThetaNullPoint
from avisogenies_sage.morphisms_level2 import (
    MumfordToLevel2ThetaPoint,
    ThetaToMumford_2_Generic,
)


def square_polynomial_lifts(u_polynomial, square_mod_u):
    field = u_polynomial.base_ring()
    ring = u_polynomial.parent()
    variable = ring.gen()
    u_polynomial = u_polynomial.monic()
    square_mod_u = square_mod_u % u_polynomial
    parameter_ring = PolynomialRing(field, "square_shift")
    square_shift = parameter_ring.gen()
    coefficients = [
        parameter_ring(square_mod_u[index])
        + square_shift*parameter_ring(u_polynomial[index])
        for index in range(3)
    ]
    discriminant = (
        coefficients[1]^2 - 4*coefficients[2]*coefficients[0]
    )
    lifts = []
    for shift in discriminant.roots(multiplicities=False):
        candidate_square = square_mod_u + field(shift)*u_polynomial
        leading = candidate_square[2]
        if leading == 0 or not leading.is_square():
            continue
        slope = leading.sqrt()
        intercept = candidate_square[1]/(2*slope)
        candidate = slope*variable + intercept
        if candidate^2 == candidate_square:
            lifts.extend([candidate, -candidate])
    return lifts


phase_started = start_phase("dual_kernel_recovery")
kernel_divisors = []
kernel_round_trip_counts = []
for kernel_point in theta_data["dual_kernel_basis"]:
    analytic_kernel = analytic(kernel_point)
    kernel_u, kernel_v_square = ThetaToMumford_2_Generic(
        analytic._wp,
        analytic_kernel,
    )
    matching_divisors = []
    for kernel_v in square_polynomial_lifts(
        kernel_u,
        kernel_v_square,
    ):
        assert (
            kernel_v^2 - rosenhain_polynomial
        ) % kernel_u.monic() == 0
        kernel_divisor = rosenhain_curve.jacobian()(
            [kernel_u.monic(), kernel_v % kernel_u.monic()]
        )
        if theta_data["quotient"](kernel_divisor) == kernel_point:
            matching_divisors.append(kernel_divisor)
    assert len(matching_divisors) == 2
    assert matching_divisors[0] == -matching_divisors[1]
    kernel_round_trip_counts.append(len(matching_divisors))
    kernel_divisors.append(matching_divisors[0])
finish_phase("dual_kernel_recovery", phase_started)

phase_started = start_phase("level2_kernel_preparation")
level2_field, _ = extension_field.extension(2, map=True)
analytic_level2 = AnalyticThetaNullPoint(
    level2_field,
    2,
    2,
    [level2_field(value) for value in analytic],
    wp=[level2_field(value) for value in analytic._wp],
    rac=level2_field(1),
)
level2_quotient = analytic_level2.to_algebraic()


def divisor_to_level2_theta(kummer, analytic_theta, divisor):
    field = kummer.base_ring()
    polynomial_ring = PolynomialRing(field, "level2_x")
    divisor_u, divisor_v = divisor
    extended_u = polynomial_ring(
        [field(coefficient) for coefficient in divisor_u]
    )
    extended_v = polynomial_ring(
        [field(coefficient) for coefficient in divisor_v]
    )
    support = sum(
        (
            [(root, extended_v(root))]*multiplicity
            for root, multiplicity in extended_u.roots()
        ),
        [],
    )
    assert len(support) == extended_u.degree()
    analytic_point = MumfordToLevel2ThetaPoint(
        [field(value) for value in analytic_theta._wp],
        analytic_theta,
        support,
    )
    return analytic_point.to_algebraic(A=kummer)


def explicit_root_isogeny(
    theta_null,
    isogeny_degree,
    torsion,
    points,
    root_extension_degree=1,
    check=False,
):
    """
    Evaluate the AVIsogenies level-2 formula using explicit finite-field roots.

    The upstream implementation works in a quotient polynomial ring with one
    formal l-th root for every compatible lift. Choosing roots in one finite
    extension gives the same l-th-power image coordinates without carrying
    the formal quotient ring. Every final coordinate is required to descend
    back to the original field.
    """
    from avisogenies_sage import KummerVariety
    from avisogenies_sage import tools as avisogenies_tools

    field = theta_null.base_ring()
    dimension = theta_null.dimension()
    coordinate_count = theta_null._ng
    row_count = len(points) + 1

    lifted_points = []
    deltas = []
    for basis_index, basis_point in enumerate(torsion):
        translated_points = [(point + basis_point)[0] for point in points]
        basis_sums = [
            (basis_point + other_basis_point)[0]
            for other_basis_point in torsion[basis_index + 1:]
        ]
        lifted_points.append(
            [basis_point] + translated_points + basis_sums
        )
        deltas += basis_point.compatible_lift(
            isogeny_degree,
            points,
            translated_points,
        )
        deltas += [
            basis_sum.compatible_lift(isogeny_degree)
            for basis_sum in basis_sums
        ]

    working_field = field
    working_theta_null = theta_null
    working_points = points
    working_lifted_points = lifted_points
    root_deltas = deltas
    embedding = None
    if root_extension_degree > 1:
        assert field.order() % isogeny_degree == 1
        working_field, embedding = field.extension(
            root_extension_degree,
            "explicit_root",
            map=True,
        )
        working_theta_null = theta_null.change_ring(working_field)

        def extend_point(point):
            return working_theta_null(
                [embedding(coordinate) for coordinate in point]
            )

        working_points = [extend_point(point) for point in points]
        working_lifted_points = [
            [extend_point(point) for point in row]
            for row in lifted_points
        ]
        root_deltas = [embedding(delta) for delta in deltas]

    roots = []
    for index, delta in enumerate(root_deltas):
        try:
            root = delta.nth_root(isogeny_degree)
        except ValueError as error:
            raise RuntimeError(
                f"Compatible lift {index} is not a "
                f"{isogeny_degree}-th power "
                "in the level-2 field."
            ) from error
        assert root^isogeny_degree == delta
        roots.append(root)
    print(
        (
            f"EXPLICIT_ROOTS verified {len(roots)} "
            f"extension_degree {root_extension_degree}"
        ),
        flush=True,
    )

    index = partial(avisogenies_tools.idx, n=isogeny_degree)
    residue_space = Zmod(isogeny_degree)^dimension
    basis_vectors = residue_space.basis()
    basis_indices = [index(vector_value) for vector_value in basis_vectors]
    kernel_size = isogeny_degree^dimension
    support = (
        [range(isogeny_degree)]*dimension + [range(row_count)]
    )
    row_offsets = list(
        accumulate(len(row) for row in lifted_points)
    )

    kernel_table = [
        [None]*kernel_size for _ in range(row_count)
    ]
    for *coefficients, row_index in cantor_product(*support):
        kernel_index = index(coefficients)
        kernel_vector = residue_space(coefficients)
        nonzero_positions = (
            position
            for position, coefficient in enumerate(coefficients)
            if coefficient
        )
        if kernel_vector == 0:
            kernel_table[row_index][0] = (
                working_theta_null(0)
                if row_index == 0
                else working_points[row_index - 1]
            )
            continue
        first_position = next(nonzero_positions)
        if kernel_vector in basis_vectors:
            root_offset = (
                row_offsets[first_position - 1]
                if first_position != 0
                else 0
            )
            kernel_table[row_index][kernel_index] = working_lifted_points[
                first_position
            ][row_index].scale(roots[root_offset + row_index])
            continue
        repeated_position = next(
            (
                position
                for position, coefficient in enumerate(coefficients)
                if coefficient > 1
            ),
            None,
        )
        if repeated_position is None:
            second_position = next(nonzero_positions)
            if (
                row_index == 0
                and next(nonzero_positions, None) is None
            ):
                root_offset = (
                    row_offsets[first_position - 1]
                    if first_position != 0
                    else 0
                )
                sum_index = (
                    row_count + second_position - first_position - 1
                )
                kernel_table[0][kernel_index] = working_lifted_points[
                    first_position
                ][sum_index].scale(roots[root_offset + sum_index])
                continue
            first_basis = basis_vectors[first_position]
            second_basis = basis_vectors[second_position]
            first_index = basis_indices[first_position]
            second_index = basis_indices[second_position]
            kernel_table[row_index][kernel_index] = kernel_table[0][
                first_index
            ].three_way_add(
                kernel_table[0][second_index],
                kernel_table[row_index][
                    index(kernel_vector - first_basis - second_basis)
                ],
                kernel_table[0][index(first_basis + second_basis)],
                kernel_table[row_index][index(kernel_vector - first_basis)],
                kernel_table[row_index][index(kernel_vector - second_basis)],
            )
            continue
        repeated_basis = basis_vectors[repeated_position]
        repeated_index = basis_indices[repeated_position]
        kernel_table[row_index][kernel_index] = kernel_table[row_index][
            index(kernel_vector - repeated_basis)
        ].diff_add(
            kernel_table[0][repeated_index],
            kernel_table[row_index][
                index(kernel_vector - 2*repeated_basis)
            ],
        )

    images = []
    for row_index in range(row_count):
        image_coordinates = [
            sum(
                element[coordinate_index]^isogeny_degree
                for element in kernel_table[row_index]
            )
            for coordinate_index in range(coordinate_count)
        ]
        images.append(image_coordinates)

    if embedding is not None:
        descended_images = []
        for coordinates in images:
            descended_coordinates = []
            for coordinate in coordinates:
                base_coordinate = field(coordinate)
                assert embedding(base_coordinate) == coordinate
                descended_coordinates.append(base_coordinate)
            descended_images.append(descended_coordinates)
        images = descended_images

    target = KummerVariety(
        field,
        dimension,
        images[0],
        check=check,
    )
    target_points = [
        target(coordinates, check=check)
        for coordinates in images[1:]
    ]
    return target, target_points, len(roots)


level2_ring = PolynomialRing(level2_field, "u")
u = level2_ring.gen()
rosenhain_polynomial_24 = level2_ring(
    [level2_field(value) for value in rosenhain_polynomial]
)
rosenhain_curve_24 = HyperellipticCurve(rosenhain_polynomial_24)
rosenhain_jacobian_24 = rosenhain_curve_24.jacobian()


def extend_divisor(divisor):
    divisor_u, divisor_v = divisor
    return rosenhain_jacobian_24(
        [
            level2_ring(
                [level2_field(value) for value in divisor_u]
            ),
            level2_ring(
                [level2_field(value) for value in divisor_v]
            ),
        ]
    )


kernel_divisors_24 = [
    extend_divisor(divisor) for divisor in kernel_divisors
]
level2_kernel = [
    divisor_to_level2_theta(
        level2_quotient,
        analytic_level2,
        divisor,
    )
    for divisor in kernel_divisors_24
]
assert all(
    prime*divisor == rosenhain_jacobian_24(0)
    for divisor in kernel_divisors_24
)
level2_basis_sum = divisor_to_level2_theta(
    level2_quotient,
    analytic_level2,
    kernel_divisors_24[0] + kernel_divisors_24[1],
)
level2_basis_difference = divisor_to_level2_theta(
    level2_quotient,
    analytic_level2,
    kernel_divisors_24[0] - kernel_divisors_24[1],
)
finish_phase("level2_kernel_preparation", phase_started)

phase_started = start_phase("sample_selection")
batch_divisors = []
batch_source_x = []
candidate_x = ZZ(2)
while len(batch_divisors) < config["sample_count"]:
    source_x = level2_field(candidate_x)
    candidate_x += 1
    source_rhs = rosenhain_polynomial_24(source_x)
    if source_rhs == 0 or not source_rhs.is_square():
        continue
    source_y = source_rhs.sqrt()
    batch_divisors.append(
        rosenhain_jacobian_24(
            [u - source_x, level2_ring(source_y)]
        )
    )
    batch_source_x.append(source_x)
finish_phase("sample_selection", phase_started)

phase_started = start_phase("sample_theta_conversion")
batch_theta_points = [
    divisor_to_level2_theta(
        level2_quotient,
        analytic_level2,
        divisor,
    )
    for divisor in batch_divisors
]
batch_theta_sums = [
    [
        divisor_to_level2_theta(
            level2_quotient,
            analytic_level2,
            divisor + kernel_divisor,
        )
        for kernel_divisor in kernel_divisors_24
    ]
    for divisor in batch_divisors
]
batch_theta_differences = [
    [
        divisor_to_level2_theta(
            level2_quotient,
            analytic_level2,
            divisor - kernel_divisor,
        )
        for kernel_divisor in kernel_divisors_24
    ]
    for divisor in batch_divisors
]
finish_phase("sample_theta_conversion", phase_started)

_, KummerVarietyPoint = load_avisogenies_sage(root)
original_add = KummerVarietyPoint._add
original_lift = KummerVarietyPoint.compatible_lift


def exact_level2_addition(self, other, idxi0=0):
    for sample_index, sample_point in enumerate(batch_theta_points):
        for kernel_index, kernel_point in enumerate(level2_kernel):
            if (
                (self == sample_point and other == kernel_point)
                or (self == kernel_point and other == sample_point)
            ):
                return (
                    batch_theta_sums[sample_index][kernel_index],
                    batch_theta_differences[sample_index][kernel_index],
                )
    if (
        (self == level2_kernel[0] and other == level2_kernel[1])
        or (self == level2_kernel[1] and other == level2_kernel[0])
    ):
        return level2_basis_sum, level2_basis_difference
    return original_add(self, other, idxi0)


KummerVarietyPoint._add = exact_level2_addition
KummerVarietyPoint.compatible_lift = _sage_10_compatible_lift
phase_started = start_phase("dual_isogeny_evaluation")
dual_isogeny_strategy = config.get(
    "dual_isogeny_strategy",
    "explicit_degree_prime_extension",
)
explicit_root_count = None
explicit_root_extension_degree = None
try:
    if dual_isogeny_strategy == "explicit_base_field_roots":
        (
            dual_target,
            batch_images,
            explicit_root_count,
        ) = explicit_root_isogeny(
            level2_quotient,
            prime,
            level2_kernel,
            batch_theta_points,
            check=False,
        )
        explicit_root_extension_degree = 1
    elif dual_isogeny_strategy == "explicit_degree_prime_extension":
        (
            dual_target,
            batch_images,
            explicit_root_count,
        ) = explicit_root_isogeny(
            level2_quotient,
            prime,
            level2_kernel,
            batch_theta_points,
            root_extension_degree=prime,
            check=False,
        )
        explicit_root_extension_degree = int(prime)
    elif dual_isogeny_strategy == "symbolic_quotient_ring":
        dual_target, batch_images = level2_quotient.isogeny(
            prime,
            level2_kernel,
            R=batch_theta_points,
            check=False,
        )
    else:
        raise ValueError(
            f"Unknown dual-isogeny strategy: {dual_isogeny_strategy}"
        )
finally:
    KummerVarietyPoint._add = original_add
    KummerVarietyPoint.compatible_lift = original_lift
finish_phase("dual_isogeny_evaluation", phase_started)

phase_started = start_phase("target_factorization")
target_matrix = matrix(
    level2_field,
    2,
    2,
    list(dual_target.theta_null_point()),
)
assert target_matrix.rank() == 1
factor_theta_parameters = [
    target_matrix[1, 0]/target_matrix[0, 0],
    target_matrix[0, 1]/target_matrix[0, 0],
]


def theta_parameter_j(parameter):
    legendre_parameter = 4*parameter^2/(1 + parameter^2)^2
    return (
        256
        * (1 - legendre_parameter + legendre_parameter^2)^3
        / (
            legendre_parameter^2
            * (1 - legendre_parameter)^2
        )
    )


source_models_by_j = {
    level2_field(model["curve"].j_invariant()): model
    for model in theta_data["elliptic_theta_models"]
}
factor_models = [
    source_models_by_j[theta_parameter_j(parameter)]
    for parameter in factor_theta_parameters
]


def ordered_roots_for_theta_parameter(model, parameter):
    legendre_parameter = 4*parameter^2/(1 + parameter^2)^2
    roots = [level2_field(value) for value in model["roots"]]
    for first in roots:
        for second in roots:
            if second == first:
                continue
            third = next(
                value
                for value in roots
                if value not in [first, second]
            )
            if (
                (third - first)/(second - first)
                == legendre_parameter
            ):
                return first, second, third
    raise ValueError("no root ordering matches the target theta null")


factor_ordered_roots = [
    ordered_roots_for_theta_parameter(model, parameter)
    for model, parameter in zip(
        factor_models,
        factor_theta_parameters,
    )
]


def elliptic_x_from_factored_image(
    parameter,
    ordered_roots,
    coordinates,
):
    first, second = coordinates
    legendre_x = (
        2*parameter*(second*parameter - first)
        / (
            (1 + parameter^2)
            * (second - parameter*first)
        )
    )
    root_0, root_1, _ = ordered_roots
    return root_0 + (root_1 - root_0)*legendre_x


batch_target_x = [[], []]
for image in batch_images:
    image_matrix = matrix(level2_field, 2, 2, list(image))
    assert image_matrix.rank() == 1
    factored_coordinates = [
        [image_matrix[row, 0] for row in range(2)],
        [
            image_matrix[0, column]/image_matrix[0, 0]
            for column in range(2)
        ],
    ]
    for factor_index in range(2):
        batch_target_x[factor_index].append(
            elliptic_x_from_factored_image(
                factor_theta_parameters[factor_index],
                factor_ordered_roots[factor_index],
                factored_coordinates[factor_index],
            )
        )
finish_phase("target_factorization", phase_started)


def interpolate_rational_function(
    source_values,
    target_values,
    numerator_degree,
    denominator_degree,
):
    rows = []
    for source_value, target_value in zip(
        source_values,
        target_values,
    ):
        rows.append(
            [
                source_value^degree
                for degree in range(numerator_degree + 1)
            ]
            + [
                -target_value*source_value^degree
                for degree in range(denominator_degree + 1)
            ]
        )
    interpolation_kernel = matrix(
        level2_field,
        rows,
    ).right_kernel()
    assert interpolation_kernel.dimension() == 1
    coefficients = interpolation_kernel.basis()[0]
    numerator = level2_ring(
        list(coefficients[:numerator_degree + 1])
    )
    denominator = level2_ring(
        list(coefficients[numerator_degree + 1:])
    )
    common = numerator.gcd(denominator)
    numerator //= common
    denominator //= common
    scale = denominator.leading_coefficient()
    return level2_ring.fraction_field()(
        (numerator/scale)/(denominator/scale)
    )


phase_started = start_phase("rational_interpolation")
recovered_x_maps = [
    interpolate_rational_function(
        batch_source_x,
        target_values,
        prime,
        prime,
    )
    for target_values in batch_target_x
]
for factor_index, recovered_map in enumerate(recovered_x_maps):
    assert all(
        recovered_map(source_value) == target_value
        for source_value, target_value in zip(
            batch_source_x,
            batch_target_x[factor_index],
        )
    )
finish_phase("rational_interpolation", phase_started)


def exact_polynomial_square_root(polynomial):
    polynomial = polynomial.parent()(polynomial)
    if polynomial == 0:
        return polynomial
    factorization = polynomial.factor()
    assert all(exponent % 2 == 0 for _, exponent in factorization)
    unit = factorization.unit()
    assert unit.is_square()
    return (
        unit.sqrt()
        * prod(
            factor^(exponent//2)
            for factor, exponent in factorization
        )
    )


phase_started = start_phase("map_identity_certification")
recovered_maps = []
for factor_index, recovered_x in enumerate(recovered_x_maps):
    target_curve = factor_models[factor_index]["curve"].change_ring(
        level2_field
    )
    elliptic_rhs = (
        recovered_x^3
        + level2_field(target_curve.a4())*recovered_x
        + level2_field(target_curve.a6())
    )
    differential_square = level2_ring.fraction_field()(
        recovered_x.derivative()^2
        * rosenhain_polynomial_24
        / (4*elliptic_rhs)
    )
    differential_numerator = differential_square.numerator()
    differential_denominator = differential_square.denominator()
    assert differential_denominator.degree() == 0
    differential_polynomial = level2_ring(
        differential_numerator/differential_denominator[0]
    )
    assert differential_polynomial.degree() <= 2
    pulled_back_eigenform = exact_polynomial_square_root(
        differential_polynomial
    )
    assert pulled_back_eigenform.degree() <= 1
    recovered_y_coefficient = level2_ring.fraction_field()(
        recovered_x.derivative()/(2*pulled_back_eigenform)
    )
    assert (
        recovered_y_coefficient^2*rosenhain_polynomial_24
        == elliptic_rhs
    )
    degree = max(
        recovered_x.numerator().degree(),
        recovered_x.denominator().degree(),
    )
    assert degree == prime
    recovered_maps.append(
        {
            "target_curve": target_curve,
            "x_coordinate": recovered_x,
            "y_coefficient": recovered_y_coefficient,
            "eigenform": pulled_back_eigenform,
            "degree": degree,
        }
    )
finish_phase("map_identity_certification", phase_started)


def rational_function_record(function):
    return {
        "numerator": str(function.numerator()),
        "denominator": str(function.denominator()),
        "numerator_degree": int(function.numerator().degree()),
        "denominator_degree": int(function.denominator().degree()),
    }


result = {
    "status": "verified",
    "workstream": config["workstream"],
    "prime": int(prime),
    "base_field": f"F_{field_order}",
    "theta_field_degree": int(level2_field.degree()),
    "theta_field_modulus": str(level2_field.modulus()),
    "source_curve_over_base_field": str(source_polynomial),
    "rosenhain_curve_over_theta_field": str(
        rosenhain_polynomial_24
    ),
    "hasse_witt_matrix_on_base_model": [
        [int(value) for value in row] for row in hasse_witt.rows()
    ],
    "base_model_eigenforms": [
        str(
            source_ring(
                list(eigenvector)
            )
        )
        for eigenvector in config["hasse_witt_eigenvectors"]
    ],
    "kernel": {
        "order": int(prime),
        "basis_size": int(2),
        "round_trip_lifts_per_basis_point": kernel_round_trip_counts,
        "torsion_verified": True,
    },
    "evaluation": {
        "sample_count": len(batch_source_x),
        "source_x_values": [str(value) for value in batch_source_x],
        "dual_isogeny_strategy": dual_isogeny_strategy,
        "explicit_root_count": explicit_root_count,
        "explicit_root_extension_degree": (
            explicit_root_extension_degree
        ),
        "target_theta_rank": int(target_matrix.rank()),
        "all_image_theta_ranks": [
            int(matrix(level2_field, 2, 2, list(image)).rank())
            for image in batch_images
        ],
    },
    "maps": [
        {
            "factor_index": index,
            "target_j_invariant": str(
                answer["target_curve"].j_invariant()
            ),
            "target_a4": str(answer["target_curve"].a4()),
            "target_a6": str(answer["target_curve"].a6()),
            "cover_degree": int(answer["degree"]),
            "x_coordinate": rational_function_record(
                answer["x_coordinate"]
            ),
            "y_coefficient": rational_function_record(
                answer["y_coefficient"]
            ),
            "pullback_eigenform": str(answer["eigenform"]),
            "elliptic_equation_identity": True,
            "linear_differential_pullback": True,
            "all_interpolation_samples_verified": True,
        }
        for index, answer in enumerate(recovered_maps)
    ],
    "phase_timings_seconds": {
        name: float(value) for name, value in phase_timings.items()
    },
    "runtime_seconds": time.time() - started_at,
    "notes": [
        (
            "The formulas are on the Rosenhain model over "
            f"F_({field_order}^{level2_field.degree()})."
        ),
        (
            f"The base-field descent is tracked in workstream "
            f"{config['workstream']}."
        ),
        "The Y-coordinate is y times the recorded y_coefficient.",
    ],
}
output = root / "results" / config["output_filename"]
output.write_text(json.dumps(result, indent=2) + "\n")

print(f"DEGREE{prime}_MAPS verified")
print("samples", len(batch_source_x))
print(
    "map_degrees",
    [answer["degree"] for answer in recovered_maps],
)
print(
    "x_degree_pairs",
    [
        (
            answer["x_coordinate"].numerator().degree(),
            answer["x_coordinate"].denominator().degree(),
        )
        for answer in recovered_maps
    ],
)
print(
    "differential_degrees",
    [answer["eigenform"].degree() for answer in recovered_maps],
)
print("result", output)
