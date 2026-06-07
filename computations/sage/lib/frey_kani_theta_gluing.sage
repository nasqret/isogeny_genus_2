"""
Theta-coordinate reconstruction of finite-field Frey-Kani quotients.

The implementation uses the Sage branch of AVIsogenies for level-2 theta
arithmetic.  Elliptic Kummer coordinates and decomposable-product addition
are supplied explicitly, so the entry point is parameterized by elliptic
curves, torsion bases, and an anti-isometry matrix.
"""

import os
import sys
from pathlib import Path


def load_avisogenies_sage(repository_root=None):
    """Import the pinned external AVIsogenies dependency."""
    if repository_root is None:
        repository_root = Path.cwd()
    dependency = Path(
        os.environ.get(
            "AVISOGENIES_SAGE",
            str(Path(repository_root) / ".deps" / "avisogenies-sage"),
        )
    )
    if not dependency.exists():
        raise RuntimeError(
            "AVIsogenies is missing. Run "
            "./scripts/setup-avisogenies-sage.sh first."
        )
    sys.path.insert(0, str(dependency))
    from avisogenies_sage import KummerVariety
    from avisogenies_sage.theta_point import KummerVarietyPoint

    return KummerVariety, KummerVarietyPoint


def projective_tensor(left, right):
    """Kronecker product in binary theta-coordinate order."""
    return [a*b for a in left for b in right]


def elliptic_level2_theta_model(curve, extension_field, KummerVariety):
    """
    Construct a level-2 elliptic Kummer model and its point map.

    If the cubic roots are e0, e1, e_lambda and
    lambda=(e_lambda-e0)/(e1-e0), choose t with

        lambda = 4*t^2/(1+t^2)^2.

    The theta null is [1,t].  For Legendre coordinate X, the point has
    projective Kummer coordinates

        [(1+t^2)X-2t^2, t*((1+t^2)X-2)].
    """
    curve_extension = curve.change_ring(extension_field)
    polynomial_ring = PolynomialRing(extension_field, "x")
    x = polynomial_ring.gen()
    cubic = (
        x^3
        + extension_field(curve.a4())*x
        + extension_field(curve.a6())
    )
    roots = cubic.roots(multiplicities=False)
    assert len(roots) == 3
    e0, e1, e_lambda = roots
    scale = e1 - e0
    legendre_lambda = (e_lambda - e0)/scale

    theta_ring = PolynomialRing(extension_field, "t")
    t_variable = theta_ring.gen()
    theta_polynomial = (
        legendre_lambda*(1 + t_variable^2)^2 - 4*t_variable^2
    )
    theta_roots = theta_polynomial.roots(multiplicities=False)
    assert theta_roots
    theta_parameter = next(
        value
        for value in theta_roots
        if value != 0 and value^4 != 1
    )
    kummer = KummerVariety(
        extension_field,
        1,
        [extension_field(1), theta_parameter],
    )

    def point_coordinates(point):
        if point.is_zero():
            return kummer(0)
        legendre_x = (extension_field(point[0]) - e0)/scale
        first = (
            (1 + theta_parameter^2)*legendre_x
            - 2*theta_parameter^2
        )
        second = theta_parameter*(
            (1 + theta_parameter^2)*legendre_x - 2
        )
        return kummer([first, second])

    return {
        "curve": curve_extension,
        "roots": roots,
        "lambda": legendre_lambda,
        "theta_parameter": theta_parameter,
        "kummer": kummer,
        "point": point_coordinates,
    }


def assert_elliptic_kummer_sum(model, left, right):
    """Check normal addition against the underlying elliptic curve."""
    expected = [
        model["point"](left + right),
        model["point"](left - right),
    ]
    actual = list(model["point"](left) + model["point"](right))
    assert all(
        any(value == candidate for candidate in actual)
        for value in expected
    )


def extend_elliptic_point(point, extended_curve, extension_field):
    """Coerce an affine elliptic point into the chosen extension."""
    if point.is_zero():
        return extended_curve(0)
    return extended_curve(
        extension_field(point[0]),
        extension_field(point[1]),
    )


def apply_torsion_matrix_over_integers(matrix_value, basis):
    """Apply a residue-class matrix to an elliptic torsion basis."""
    first, second = basis
    coefficients = [
        [ZZ(matrix_value[row, column]) for column in range(2)]
        for row in range(2)
    ]
    return (
        coefficients[0][0]*first + coefficients[0][1]*second,
        coefficients[1][0]*first + coefficients[1][1]*second,
    )


def _sage_10_compatible_lift(self, prime, other=None, add=None):
    """
    AVIsogenies compatibility shim for Sage 10.8 scalar dispatch.

    This is algebraically the package's compatible-lift normalization, but
    invokes its public Montgomery multiplication method directly.
    """
    if add is None:
        if other is not None:
            raise ValueError(
                "A list of sums is required when other points are supplied."
            )
        middle = ZZ((prime - 1)/2)
        left = self._mult(middle)
        right = self._mult(middle + 1)
        ratios = [
            left[-index]/right[position]
            for position, index in enumerate(self.scheme()._D)
        ]
        assert len(set(ratios)) == 1
        return ratios[0]

    lift = _sage_10_compatible_lift(self, prime)
    deltas = [lift]
    for point, point_sum in zip(other, add):
        translated, _ = self.diff_multadd(prime, point_sum, point)
        ratios = [
            coordinate/translated_coordinate
            for coordinate, translated_coordinate in zip(point, translated)
        ]
        assert len(set(ratios)) == 1
        deltas.append(ratios[0]/lift^(prime - 1))
    return deltas


def frey_kani_theta_quotient(
    elliptic_curve_1,
    elliptic_curve_2,
    prime,
    basis_1,
    basis_2,
    anti_isometry_matrix,
    extension_degree,
    repository_root=None,
):
    """
    Compute the quotient theta null and Rosenhain model.

    The current finite-field constructor assumes that both elliptic curves
    are defined over the same prime field and that ``extension_degree`` is
    divisible by the splitting degrees of both 2-division polynomials and
    the required theta-parameter equations.
    """
    assert prime.is_prime()
    base_field = elliptic_curve_1.base_field()
    assert base_field == elliptic_curve_2.base_field()
    assert base_field.degree() == 1
    assert base_field.characteristic() != prime

    KummerVariety, KummerVarietyPoint = load_avisogenies_sage(
        repository_root
    )
    extension_field = GF(
        base_field.characteristic()^extension_degree,
        "theta_extension",
    )
    extended_curve_1 = elliptic_curve_1.change_ring(extension_field)
    extended_curve_2 = elliptic_curve_2.change_ring(extension_field)
    extended_basis_1 = tuple(
        extend_elliptic_point(
            point, extended_curve_1, extension_field
        )
        for point in basis_1
    )
    extended_basis_2 = tuple(
        extend_elliptic_point(
            point, extended_curve_2, extension_field
        )
        for point in basis_2
    )
    image_basis = apply_torsion_matrix_over_integers(
        anti_isometry_matrix,
        extended_basis_2,
    )

    model_1 = elliptic_level2_theta_model(
        elliptic_curve_1, extension_field, KummerVariety
    )
    model_2 = elliptic_level2_theta_model(
        elliptic_curve_2, extension_field, KummerVariety
    )
    for model, basis in (
        (model_1, extended_basis_1),
        (model_2, extended_basis_2),
    ):
        for point in basis:
            assert model["point"](point)._mult(prime) == model["kummer"](0)
        assert_elliptic_kummer_sum(model, basis[0], basis[1])
        assert_elliptic_kummer_sum(model, basis[0], 2*basis[1])

    product_null = projective_tensor(
        list(model_1["kummer"].theta_null_point()),
        list(model_2["kummer"].theta_null_point()),
    )
    product = KummerVariety(extension_field, 2, product_null)

    def product_point(left, right):
        return product(
            projective_tensor(
                list(model_1["point"](left)),
                list(model_2["point"](right)),
            )
        )

    graph_basis = [
        product_point(extended_basis_1[index], image_basis[index])
        for index in range(2)
    ]
    graph_sum = product_point(
        extended_basis_1[0] + extended_basis_1[1],
        image_basis[0] + image_basis[1],
    )
    graph_difference = product_point(
        extended_basis_1[0] - extended_basis_1[1],
        image_basis[0] - image_basis[1],
    )
    for point in graph_basis + [graph_sum]:
        assert point._mult(prime) == product(0)

    original_add = KummerVarietyPoint._add
    original_compatible_lift = KummerVarietyPoint.compatible_lift

    def product_aware_add(self, other, idxi0=0):
        if self.scheme() == product:
            if (
                self == graph_basis[0] and other == graph_basis[1]
            ) or (
                self == graph_basis[1] and other == graph_basis[0]
            ):
                return graph_sum, graph_difference
        return original_add(self, other, idxi0)

    KummerVarietyPoint._add = product_aware_add
    KummerVarietyPoint.compatible_lift = _sage_10_compatible_lift
    try:
        actual_sums = list(graph_basis[0] + graph_basis[1])
        assert any(graph_sum == candidate for candidate in actual_sums)
        assert any(
            graph_difference == candidate for candidate in actual_sums
        )
        quotient, _ = product.isogeny(
            prime,
            graph_basis,
            check=False,
        )
    finally:
        KummerVarietyPoint._add = original_add
        KummerVarietyPoint.compatible_lift = original_compatible_lift

    analytic_quotient = quotient.with_theta_basis("F(2,2)^2")
    quotient_curve = analytic_quotient.curve()
    return {
        "extension_field": extension_field,
        "elliptic_theta_models": (model_1, model_2),
        "product": product,
        "graph_basis": graph_basis,
        "quotient": quotient,
        "analytic_quotient": analytic_quotient,
        "quotient_curve": quotient_curve,
    }
