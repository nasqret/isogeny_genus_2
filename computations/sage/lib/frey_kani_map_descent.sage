"""Transport recovered Frey-Kani maps to a fixed base-field model."""

import json
import time
from datetime import datetime
from pathlib import Path


started_at = time.time()
root = Path.cwd()
config = FREY_KANI_MAP_DESCENT_CONFIG
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
base_field = GF(field_order)
base_ring = PolynomialRing(base_field, "X")
X = base_ring.gen()
base_polynomial = base_ring(
    config["source_coefficients"]
)
elliptic_curves = [
    EllipticCurve(base_field, coefficients)
    for coefficients in config["elliptic_coefficients"]
]
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
theta_data = frey_kani_theta_quotient(
    elliptic_curves[0],
    elliptic_curves[1],
    prime,
    torsion_bases[0],
    torsion_bases[1],
    matrix(GF(prime), config["anti_isometry_matrix"]),
    extension_degree=config.get("extension_degree", 12),
    repository_root=root,
)
extension_field = theta_data["extension_field"]
level2_field, _ = extension_field.extension(2, map=True)
level2_ring = PolynomialRing(level2_field, "u")
u = level2_ring.gen()
level2_fraction_field = level2_ring.fraction_field()
base_fraction_field = base_ring.fraction_field()

rosenhain_polynomial = level2_ring(
    [
        level2_field(value)
        for value in theta_data[
            "quotient_curve"
        ].hyperelliptic_polynomials()[0]
    ]
)
base_polynomial_24 = level2_ring(
    [level2_field(value) for value in base_polynomial]
)
rosenhain_roots = rosenhain_polynomial.roots(
    multiplicities=False
)
base_roots = base_polynomial_24.roots(multiplicities=False)
assert len(rosenhain_roots) == 5
assert level2_field(0) in rosenhain_roots
assert level2_field(1) in rosenhain_roots


def mobius_value(coefficients, value):
    a, b, c, d = coefficients
    denominator = c*value + d
    if denominator == 0:
        return None
    return (a*value + b)/denominator


def normalized_mobius_from_images(
    infinity_image,
    zero_image,
    one_image,
):
    d = (one_image - infinity_image)/(zero_image - one_image)
    return (
        infinity_image,
        zero_image*d,
        level2_field(1),
        d,
    )


if base_polynomial_24 == rosenhain_polynomial:
    # The deterministic theta normalization can already produce the requested
    # odd-degree model. In that case infinity is the sixth branch point and
    # the identity transport avoids an unnecessary projective root search.
    mobius_candidates = [
        (
            level2_field(1),
            level2_field(0),
            level2_field(0),
            level2_field(1),
        )
    ]
else:
    assert len(base_roots) == 6
    mobius_candidates = []
    for infinity_image in base_roots:
        for zero_image in base_roots:
            if zero_image == infinity_image:
                continue
            for one_image in base_roots:
                if one_image in [infinity_image, zero_image]:
                    continue
                coefficients = normalized_mobius_from_images(
                    infinity_image,
                    zero_image,
                    one_image,
                )
                finite_images = [
                    mobius_value(coefficients, root)
                    for root in rosenhain_roots
                ]
                if None in finite_images:
                    continue
                if set(finite_images + [infinity_image]) == set(base_roots):
                    if coefficients not in mobius_candidates:
                        mobius_candidates.append(coefficients)

assert len(mobius_candidates) == 1
a, b, c, d = mobius_candidates[0]
determinant = a*d - b*c
assert determinant != 0

transformed_base_polynomial = level2_ring(0)
for degree, coefficient in enumerate(base_polynomial_24):
    transformed_base_polynomial += (
        coefficient
        * (a*u + b)^degree
        * (c*u + d)^(6 - degree)
    )
scaling_square, remainder = transformed_base_polynomial.quo_rem(
    rosenhain_polynomial
)
assert remainder == 0
assert scaling_square.degree() == 0
scaling_square = scaling_square[0]
assert scaling_square.is_square()
scaling = scaling_square.sqrt()

map_data = json.loads(
    (root / "results" / config["map_input_filename"]).read_text()
)
z24 = level2_field.gen()


def parse_rational_function(record):
    numerator = level2_ring(
        sage_eval(
            record["numerator"],
            locals={"z24": z24, "u": u},
        )
    )
    denominator = level2_ring(
        sage_eval(
            record["denominator"],
            locals={"z24": z24, "u": u},
        )
    )
    return level2_fraction_field(numerator/denominator)


inverse_argument = level2_fraction_field(
    (d*u - b)/(-c*u + a)
)
rosenhain_y_over_base_y = level2_fraction_field(
    (c*inverse_argument + d)^3/scaling
)
transported_maps = []
for target_curve, record in zip(elliptic_curves, map_data["maps"]):
    rosenhain_x_map = parse_rational_function(record["x_coordinate"])
    rosenhain_y_coefficient = parse_rational_function(
        record["y_coefficient"]
    )
    transported_x = rosenhain_x_map(inverse_argument)
    transported_y_coefficient = (
        rosenhain_y_over_base_y
        * rosenhain_y_coefficient(inverse_argument)
    )
    elliptic_rhs = (
        transported_x^3
        + level2_field(target_curve.a4())*transported_x
        + level2_field(target_curve.a6())
    )
    assert (
        transported_y_coefficient^2*base_polynomial_24
        == elliptic_rhs
    )
    transported_maps.append(
        (transported_x, transported_y_coefficient)
    )


def coefficients(function):
    return (
        list(function.numerator())
        + list(function.denominator())
    )


def coefficients_are_frobenius_fixed(function):
    return all(
        value^base_field.cardinality() == value
        for value in coefficients(function)
    )


def frobenius_rational_function(function):
    return level2_fraction_field(
        level2_ring(
            [
                value^base_field.cardinality()
                for value in function.numerator()
            ]
        )
        / level2_ring(
            [
                value^base_field.cardinality()
                for value in function.denominator()
            ]
        )
    )


def frobenius_map(map_pair):
    return tuple(
        frobenius_rational_function(function)
        for function in map_pair
    )


def maps_are_equal(left, right):
    return left[0] == right[0] and left[1] == right[1]


def translate_by_two_torsion(
    x_map,
    y_coefficient,
    target_curve,
    torsion_x,
):
    if torsion_x is None:
        return x_map, y_coefficient
    translated_x = level2_fraction_field(
        y_coefficient^2*base_polynomial_24/(x_map - torsion_x)^2
        - x_map
        - torsion_x
    )
    translated_y_coefficient = level2_fraction_field(
        y_coefficient
        * ((x_map - translated_x)/(x_map - torsion_x) - 1)
    )
    assert (
        translated_y_coefficient^2*base_polynomial_24
        == (
            translated_x^3
            + level2_field(target_curve.a4())*translated_x
            + level2_field(target_curve.a6())
        )
    )
    return translated_x, translated_y_coefficient


descent_translations = []
frobenius_fixed_maps = []
descent_cocycle_records = []
target_x_ring = PolynomialRing(level2_field, "target_x")
target_x = target_x_ring.gen()
for map_index, (target_curve, transported_map) in enumerate(zip(
    elliptic_curves,
    transported_maps,
)):
    target_two_torsion = (
        target_x^3
        + level2_field(target_curve.a4())*target_x
        + level2_field(target_curve.a6())
    ).roots(multiplicities=False)
    assert len(target_two_torsion) == 3
    target_curve_extended = target_curve.change_ring(level2_field)
    target_two_torsion_points = [
        target_curve_extended(0)
    ] + [
        target_curve_extended(torsion_x, 0)
        for torsion_x in target_two_torsion
    ]

    def frobenius_point(point):
        if point.is_zero():
            return target_curve_extended(0)
        return target_curve_extended(
            point[0]^base_field.cardinality(),
            point[1]^base_field.cardinality(),
        )

    frobenius_permutation = []
    for point in target_two_torsion_points:
        conjugate = frobenius_point(point)
        frobenius_permutation.append(
            target_two_torsion_points.index(conjugate)
        )

    translated_frobenius_map = frobenius_map(transported_map)
    torsion_x_coordinates = [None] + target_two_torsion
    cocycle_candidates = []
    for torsion_index, torsion_x in enumerate(torsion_x_coordinates):
        candidate = translate_by_two_torsion(
            transported_map[0],
            transported_map[1],
            target_curve,
            torsion_x,
        )
        if maps_are_equal(candidate, translated_frobenius_map):
            cocycle_candidates.append(torsion_index)
    assert len(cocycle_candidates) == 1
    cocycle_index = cocycle_candidates[0]
    cocycle_point = target_two_torsion_points[cocycle_index]

    cocycle_norm = target_curve_extended(0)
    conjugate = cocycle_point
    for _ in range(level2_field.degree()):
        cocycle_norm += conjugate
        conjugate = frobenius_point(conjugate)
    assert cocycle_norm.is_zero()

    descending_candidates = []
    for torsion_index, torsion_x in enumerate(torsion_x_coordinates):
        candidate = translate_by_two_torsion(
            transported_map[0],
            transported_map[1],
            target_curve,
            torsion_x,
        )
        if (
            coefficients_are_frobenius_fixed(candidate[0])
            and coefficients_are_frobenius_fixed(candidate[1])
        ):
            correction_point = target_two_torsion_points[torsion_index]
            assert cocycle_point == (
                correction_point - frobenius_point(correction_point)
            )
            descending_candidates.append(
                (torsion_index, torsion_x, candidate)
            )
    print(
        "DESCENT_TRANSLATION_CANDIDATES",
        map_index,
        len(descending_candidates),
    )
    assert descending_candidates
    identity_candidate = next(
        (
            candidate
            for candidate in descending_candidates
            if candidate[0] == 0
        ),
        None,
    )
    selected_index, torsion_x, descending_map = (
        identity_candidate
        if identity_candidate is not None
        else descending_candidates[0]
    )

    rational_two_torsion_indices = [
        index
        for index, point in enumerate(target_two_torsion_points)
        if frobenius_point(point) == point
    ]
    correction_indices = [
        candidate[0] for candidate in descending_candidates
    ]
    selected_point = target_two_torsion_points[selected_index]
    expected_correction_indices = {
        target_two_torsion_points.index(
            selected_point + target_two_torsion_points[index]
        )
        for index in rational_two_torsion_indices
    }
    assert set(correction_indices) == expected_correction_indices

    descent_translations.append(torsion_x)
    frobenius_fixed_maps.append(descending_map)
    descent_cocycle_records.append(
        {
            "frobenius_translation_index": cocycle_index,
            "frobenius_translation_x": (
                None
                if cocycle_index == 0
                else str(target_two_torsion[cocycle_index - 1])
            ),
            "frobenius_action_on_two_torsion": frobenius_permutation,
            "rational_two_torsion_indices": rational_two_torsion_indices,
            "correction_candidate_indices": correction_indices,
            "selected_correction_index": selected_index,
            "selected_correction_x": (
                None if torsion_x is None else str(torsion_x)
            ),
            "direct_descent": cocycle_index == 0,
            "cocycle_norm_zero": True,
            "selected_coboundary_equation_verified": True,
            "correction_coset_equals_rational_two_torsion": True,
        }
    )

transported_maps = frobenius_fixed_maps


def descend_element(value):
    assert value^base_field.cardinality() == value
    representative = value.polynomial()
    assert representative.degree() <= 0
    return base_field(representative[0])


def descend_polynomial(polynomial):
    return base_ring(
        [descend_element(value) for value in polynomial]
    )


def descend_rational_function(function):
    numerator = descend_polynomial(function.numerator())
    denominator = descend_polynomial(function.denominator())
    descended = base_fraction_field(numerator/denominator)
    scale = descended.denominator().leading_coefficient()
    return base_fraction_field(
        (descended.numerator()/scale)
        / (descended.denominator()/scale)
    )


descended_maps = [
    (
        descend_rational_function(x_map),
        descend_rational_function(y_coefficient),
    )
    for x_map, y_coefficient in transported_maps
]

hasse_power = base_polynomial^((field_order - 1)//2)
hasse_witt = matrix(
    base_field,
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
expected_eigenvectors = [
    vector(base_field, coordinates)
    for coordinates in config["hasse_witt_eigenvectors"]
]
expected_eigenvalues = [
    base_field(value) for value in config["frobenius_traces"]
]

descended_records = []
for index, (
    target_curve,
    (x_map, y_coefficient),
) in enumerate(zip(elliptic_curves, descended_maps)):
    elliptic_rhs = (
        x_map^3
        + target_curve.a4()*x_map
        + target_curve.a6()
    )
    assert y_coefficient^2*base_polynomial == elliptic_rhs
    eigenform = base_fraction_field(
        x_map.derivative()/(2*y_coefficient)
    )
    assert eigenform.denominator().degree() == 0
    eigenform_polynomial = base_ring(
        eigenform.numerator()/eigenform.denominator()[0]
    )
    assert eigenform_polynomial.degree() == 1
    eigenvector = vector(
        base_field,
        [
            eigenform_polynomial[0],
            eigenform_polynomial[1],
        ],
    )
    eigenvector /= eigenvector[0]
    assert eigenvector == expected_eigenvectors[index]
    assert hasse_witt*eigenvector == (
        expected_eigenvalues[index]*eigenvector
    )
    descended_records.append(
        {
            "factor_index": index,
            "target_j_invariant": str(target_curve.j_invariant()),
            "target_a4": str(target_curve.a4()),
            "target_a6": str(target_curve.a6()),
            "cover_degree": int(
                max(
                    x_map.numerator().degree(),
                    x_map.denominator().degree(),
                )
            ),
            "x_coordinate": {
                "numerator": str(x_map.numerator()),
                "denominator": str(x_map.denominator()),
                "numerator_degree": int(
                    x_map.numerator().degree()
                ),
                "denominator_degree": int(
                    x_map.denominator().degree()
                ),
            },
            "y_coefficient": {
                "numerator": str(y_coefficient.numerator()),
                "denominator": str(y_coefficient.denominator()),
                "numerator_degree": int(
                    y_coefficient.numerator().degree()
                ),
                "denominator_degree": int(
                    y_coefficient.denominator().degree()
                ),
            },
            "pullback_eigenform": str(eigenform_polynomial),
            "normalized_eigenvector": [
                int(eigenvector[0]),
                int(eigenvector[1]),
            ],
            "hasse_witt_eigenvalue": int(
                expected_eigenvalues[index]
            ),
            "target_two_torsion_translation_x": (
                None
                if descent_translations[index] is None
                else str(descent_translations[index])
            ),
            "descent_cocycle": descent_cocycle_records[index],
            "elliptic_equation_identity": True,
            "linear_differential_pullback": True,
            "coefficients_in_base_field": True,
        }
    )

result = {
    "generated_at": datetime.now().astimezone().isoformat(
        timespec="seconds"
    ),
    "engine": "SageMath 10.8",
    "runtime_seconds": time.time() - started_at,
    "workstream": config["workstream"],
    "status": "verified",
    "scope": (
        f"transport and descent of both degree-{prime} maps to the fixed "
        f"F_{field_order} hyperelliptic model"
    ),
    "base_field": f"F_{field_order}",
    "source_curve": str(base_polynomial),
    "source_equation": "Y^2 = source_curve",
    "rosenhain_field_degree": int(level2_field.degree()),
    "rosenhain_to_base_isomorphism": {
        "x_coordinate": (
            f"({a}*u + ({b}))/({c}*u + ({d}))"
        ),
        "y_coordinate": (
            f"({scaling})*v/({c}*u + ({d}))^3"
        ),
        "mobius_coefficients": [
            str(a), str(b), str(c), str(d)
        ],
        "determinant": str(determinant),
        "hyperelliptic_scaling": str(scaling),
        "branch_set_verified": True,
        "curve_equation_identity": True,
    },
    "hasse_witt_matrix": [
        [int(value) for value in row] for row in hasse_witt.rows()
    ],
    "maps": descended_records,
    "certificate": {
        "unique_mobius_class": True,
        "all_frobenius_translation_cocycles_identified": True,
        "all_cocycle_norms_zero": True,
        "all_selected_coboundary_equations_verified": True,
        "all_correction_cosets_verified": True,
        "selected_translated_coefficients_frobenius_fixed": True,
        "coefficients_descended_to_base_field": True,
        f"both_cover_degrees_equal_{prime}": all(
            record["cover_degree"] == prime
            for record in descended_records
        ),
        "both_elliptic_identities_verified": True,
        "both_differential_eigendirections_verified": True,
        "two_torsion_descent_cocycle_resolved": True,
    },
    "remaining_step": config["remaining_step"],
}
output = root / "results" / config["output_filename"]
output.write_text(json.dumps(result, indent=2) + "\n")

print(f"DEGREE{prime}_DESCENT verified")
print("mobius", (a, b, c, d))
print("scaling", scaling)
print(
    "x_degree_pairs",
    [
        (
            x_map.numerator().degree(),
            x_map.denominator().degree(),
        )
        for x_map, _ in descended_maps
    ],
)
print(
    "y_degree_pairs",
    [
        (
            y_coefficient.numerator().degree(),
            y_coefficient.denominator().degree(),
        )
        for _, y_coefficient in descended_maps
    ],
)
print(
    "eigenvectors",
    [
        record["normalized_eigenvector"]
        for record in descended_records
    ],
)
print("result", output)
