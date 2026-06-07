"""
Transport the recovered degree-13 maps to the fixed F_8009 sextic.

The Rosenhain curve and the fixed sextic have the same geometric branch
set.  An isomorphism is therefore obtained by enumerating the 120 Mobius
transformations determined by the images of infinity, 0, and 1.  The
transported elliptic maps are then tested for Frobenius descent and exact
function-field identities on the fixed base-field model.
"""

import json
import time
from datetime import datetime
from pathlib import Path


started_at = time.time()
root = Path.cwd()
load(
    str(
        root
        / "computations"
        / "sage"
        / "lib"
        / "frey_kani_theta_gluing.sage"
    )
)

base_field = GF(8009)
base_ring = PolynomialRing(base_field, "X")
X = base_ring.gen()
base_polynomial = (
    6042*X^6
    + 4620*X^5
    + 6357*X^4
    + 3661*X^3
    + 4018*X^2
    + 5767*X
    + 84
)
elliptic_curves = [
    EllipticCurve(base_field, [5553, 5419]),
    EllipticCurve(base_field, [2531, 1402]),
]
torsion_bases = [
    (
        elliptic_curves[0](3600, 411),
        elliptic_curves[0](5265, 3005),
    ),
    (
        elliptic_curves[1](6171, 1633),
        elliptic_curves[1](3628, 2373),
    ),
]
theta_data = frey_kani_theta_quotient(
    elliptic_curves[0],
    elliptic_curves[1],
    ZZ(13),
    torsion_bases[0],
    torsion_bases[1],
    matrix(GF(13), [[1, 0], [0, 3]]),
    extension_degree=12,
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
assert len(base_roots) == 6
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
    (root / "results" / "sage_degree13_maps.json").read_text()
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


for transported_x, transported_y_coefficient in transported_maps:
    assert all(
        value^base_field.cardinality() == value
        for value in coefficients(transported_x)
    )
    assert all(
        value^base_field.cardinality() == value
        for value in coefficients(transported_y_coefficient)
    )


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

hasse_power = base_polynomial^((8009 - 1)//2)
hasse_witt = matrix(
    base_field,
    [
        [hasse_power[8008], hasse_power[8007]],
        [hasse_power[16017], hasse_power[16016]],
    ],
)
expected_eigenvectors = [
    vector(base_field, [1, 3779]),
    vector(base_field, [1, 7873]),
]
expected_eigenvalues = [base_field(67), base_field(-102)]

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
    "workstream": "B014",
    "status": "verified",
    "scope": (
        "transport and descent of both degree-13 maps to the fixed "
        "F_8009 sextic"
    ),
    "base_field": "F_8009",
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
        "transported_coefficients_frobenius_fixed": True,
        "coefficients_descended_to_base_field": True,
        "both_cover_degrees_equal_13": all(
            record["cover_degree"] == 13
            for record in descended_records
        ),
        "both_elliptic_identities_verified": True,
        "both_differential_eigendirections_verified": True,
    },
    "remaining_step": (
        "generalize the synthesis search to prime degrees 17 and 19"
    ),
}
output = root / "results" / "sage_degree13_descended_maps.json"
output.write_text(json.dumps(result, indent=2) + "\n")

print("DEGREE13_DESCENT verified")
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
