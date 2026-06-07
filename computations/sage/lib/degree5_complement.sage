"""
Complementary elliptic quotient for the generic degree-5 Frey-Kani map.

The input parameters ``a,b`` may lie in any exact field of characteristic
different from 2, 3, and 5.  A root ``c`` of the fourth-critical-point
quadratic and a point on the normalization conic are supplied by the caller.
The routines below then:

1. normalize the off-diagonal self-fiber product;
2. recover its common value under the degree-5 rational map;
3. form the orientation double cover; and
4. compute the j-invariant from its squarefree binary quartic.
"""


def degree5_map_polynomials(base_field, a, b, variable):
    """Return the three distinguished quadratics and map numerator/denominator."""
    a = base_field(a)
    b = base_field(b)
    x = variable
    F1 = x^2 + (a^2 + 2*a + 2*b)*x + 2*a*b + b^2
    F2 = (2*a + 1)*x^2 + (a^2 + 2*a*b + 2*b)*x + b^2
    F3 = x^2 - (a^2 - 2*b)*x + b^2
    numerator = x*F1^2
    denominator = F2^2
    assert numerator - denominator == (x - 1)*F3^2
    return {
        "F1": F1,
        "F2": F2,
        "F3": F3,
        "numerator": numerator,
        "denominator": denominator,
    }


def degree5_critical_polynomial(base_field, a, b, variable):
    """Return the compact quadratic for the fourth critical point."""
    a = base_field(a)
    b = base_field(b)
    c = variable
    return (
        (2*a + 1)*c^2
        + (2*b - 2*a*b - 2*a - a^2)*c
        + b^2
        + 2*a*b
    )


def degree5_normalization_conic_coefficients(base_field, a, b):
    """Return L,M,N for y^2=L*m^2+M*m+N."""
    a = base_field(a)
    b = base_field(b)
    return (
        a^4 + 2*a^3 + 2*a^2*b + a^2 + b^2,
        2*b*(a + b)*(a^2 + b),
        b^3*(2*a + b),
    )


def _degree5_pair_relation(base_field, a, b):
    """Return the off-diagonal relation in the elementary symmetric functions."""
    Rsp = PolynomialRing(base_field, names=("s", "p"))
    s, p = Rsp.gens()
    Rx = PolynomialRing(Rsp, names=("x",))
    x = Rx.gen()
    map_data = degree5_map_polynomials(Rsp, a, b, x)
    pair_polynomial = x^2 - s*x + p
    numerator_remainder = map_data["numerator"].mod(pair_polynomial)
    denominator_remainder = map_data["denominator"].mod(pair_polynomial)
    relation = Rsp(
        numerator_remainder[0]*denominator_remainder[1]
        - numerator_remainder[1]*denominator_remainder[0]
    )
    return relation


def degree5_projection_residual_coefficients(base_field, a, b, m):
    """
    Return A(m),B(m) for the residual equation A*r^2+B*r+C=0.

    These coefficients are the exact generic output of projection from the
    node over zero.  The discriminant identity below determines C when it is
    needed and is substantially cheaper than rebuilding the plane quartic
    over a tower of generic function fields.
    """
    K = base_field
    a = K(a)
    b = K(b)
    m = K(m)
    A = (
        a^2*m
        + 2*a*b*m
        + 2*a*m^2
        + b^2
        + 2*b*m
        + m^2
    )^2
    B = 4*a*(
        -a^5*m^3
        - 4*a^4*b*m^2
        - 2*a^3*b^2*m^2
        - 4*a^4*m^3
        - 2*a^3*b*m^3
        + a^4*b*m
        + a^2*b^3*m
        + a*b^4*m
        - 6*a^3*b*m^2
        + a^2*b^2*m^2
        + 2*a*b^3*m^2
        - 6*a^3*m^3
        + a*b^2*m^3
        + a^2*b^3
        + 2*a*b^4
        + b^5
        - a^2*b^2*m
        + 6*a*b^3*m
        + 3*b^4*m
        - 6*a^2*b*m^2
        + 6*a*b^2*m^2
        + 3*b^3*m^2
        - 4*a^2*m^3
        + 2*a*b*m^3
        + b^2*m^3
        + b^4
        - a*b^2*m
        + 3*b^3*m
        - 2*a*b*m^2
        + 3*b^2*m^2
        - a*m^3
        + b*m^3
    )
    return A, B


def degree5_canonical_conic_point(base_field, a, b, critical_point):
    """
    Return the normalization-conic point induced by the diagonal (c,c).

    The divided self-fiber contains the diagonal critical point because
    phi'(c)=0.  Projecting (s,p)=(2*c,c^2) from the node over zero gives m;
    the residual discriminant identity then gives y.
    """
    K = base_field
    a = K(a)
    b = K(b)
    c = K(critical_point)
    denominator = 2*a^2 + 3*a + 4*b
    r = 2*c + a^2 + 2*a + 2*b
    m = (
        (a + 2*b)*c - 2*b*(2*a + b)
    )/denominator
    y = (
        (
            a^3
            - 2*a^2*b
            + a^2
            - a*b
            - 2*b^2
        )*c
        + 2*a^2*b
        - 3*a*b^2
        - 2*b^3
    )/denominator
    assert m == (c^2 - 2*a*b - b^2)/r
    L, M, N = degree5_normalization_conic_coefficients(K, a, b)
    return {
        "m": K(m),
        "y": K(y),
        "projection_r": K(r),
        "conic_residual": K(y^2 - (L*m^2 + M*m + N)),
    }


def degree5_common_base_coordinate(base_field, a, b, s, p):
    """Return the common value z=phi(t1)=phi(t2) from symmetric data."""
    K = base_field
    a = K(a)
    b = K(b)
    s = K(s)
    p = K(p)
    numerator_remainder_constant = (
        p
        * (a^2 + 2*a + 2*b + s)
        * (
            -a^2*s
            - 4*a*b
            - 2*b^2
            - 2*a*s
            - 2*b*s
            - s^2
            + 2*p
        )
    )
    denominator_remainder_constant = (
        -a^4*p
        - 4*a^3*b*p
        - 4*a^2*b^2*p
        - 4*a^3*s*p
        - 8*a^2*b*s*p
        - 4*a^2*s^2*p
        + b^4
        - 4*a^2*b*p
        - 12*a*b^2*p
        - 2*a^2*s*p
        - 12*a*b*s*p
        - 4*a*s^2*p
        + 4*a^2*p^2
        - 6*b^2*p
        - 4*b*s*p
        - s^2*p
        + 4*a*p^2
        + p^2
    )
    return K(
        numerator_remainder_constant
        / denominator_remainder_constant
    )


def rational_function_square_class_polynomial(rational_function):
    """
    Represent a rational function's square class by a squarefree polynomial.

    Since n/d and n*d differ by the square d^2, numerator and denominator
    factors can be combined after independent squarefree reduction.
    """
    function_field = rational_function.parent()
    polynomial_ring = function_field.ring()
    numerator_squarefree = polynomial_ring(
        rational_function.numerator()
    ).squarefree_part()
    denominator_squarefree = polynomial_ring(
        rational_function.denominator()
    ).squarefree_part()
    common = gcd(numerator_squarefree, denominator_squarefree)
    return (
        (numerator_squarefree // common)
        * (denominator_squarefree // common)
    ).monic()


def multiply_squarefree_classes(left, right):
    """Multiply two squarefree polynomial classes modulo polynomial squares."""
    common = gcd(left, right)
    return ((left // common)*(right // common)).monic()


def degree5_complement_from_conic_point(
    coefficient_field,
    a,
    b,
    critical_point,
    conic_point,
    verify_pair_relation=True,
    verify_even_factor=True,
    materialize_orientation=True,
    verbose=False,
):
    """
    Construct the complementary elliptic j-invariant.

    ``conic_point`` is the affine pair ``(m0,y0)`` on
    ``y^2=L*m^2+M*m+N``.  The result contains exact equations and all
    intermediate certificates needed to replay the construction.
    """
    K = coefficient_field
    a = K(a)
    b = K(b)
    c = K(critical_point)
    m0, y0 = (K(conic_point[0]), K(conic_point[1]))
    L, M, N = degree5_normalization_conic_coefficients(K, a, b)
    assert y0^2 == L*m0^2 + M*m0 + N

    Rt = PolynomialRing(K, names=("t",))
    t = Rt.gen()
    Kt = Rt.fraction_field()

    # Parameterize the conic by lines of slope t through (m0,y0).
    m = Kt(
        m0
        + ((2*L*m0 + M) - 2*y0*t)/(t^2 - L)
    )
    y = Kt(y0 + t*(m - m0))
    assert y^2 == L*m^2 + M*m + N
    if verbose:
        print("degree5 complement: conic parameterized", flush=True)

    s0 = -(a^2 + 2*a + 2*b)
    p0 = 2*a*b + b^2
    residual_A, residual_B = degree5_projection_residual_coefficients(
        Kt, a, b, m
    )

    square_factor_1 = a*m + b + m
    square_factor_2 = (
        a^2*m + 2*a*b + b^2 + 2*a*m + b*m + b + m
    )
    projection_square_root = (
        4*a*square_factor_1*square_factor_2*y
    )
    r = Kt(
        (-residual_B + projection_square_root)/(2*residual_A)
    )
    s = Kt(s0 + r)
    p = Kt(p0 + m*r)
    if verify_pair_relation:
        pair_relation = _degree5_pair_relation(K, a, b)
        assert pair_relation(s=s, p=p) == 0
    if verbose:
        print("degree5 complement: pair curve parameterized", flush=True)

    z = degree5_common_base_coordinate(Kt, a, b, s, p)
    if verify_pair_relation:
        Rx = PolynomialRing(Kt, names=("x",))
        x = Rx.gen()
        map_data = degree5_map_polynomials(Kt, a, b, x)
        pair_polynomial = x^2 - s*x + p
        numerator_remainder = map_data["numerator"].mod(pair_polynomial)
        denominator_remainder = map_data["denominator"].mod(pair_polynomial)
        assert numerator_remainder[0] == z*denominator_remainder[0]
        assert numerator_remainder[1] == z*denominator_remainder[1]
    if verbose:
        print("degree5 complement: base coordinate recovered", flush=True)

    critical_map_data = degree5_map_polynomials(K, a, b, c)
    e = K(
        critical_map_data["numerator"]
        / critical_map_data["denominator"]
    )

    # Reduce the four orientation divisors independently before combining
    # their square classes.  This avoids expression swell from multiplying
    # rational functions whose large factors cancel modulo squares.
    zero_divisor = Kt(z)
    one_divisor = Kt(z - 1)
    branch_value_divisor = Kt(z - e)
    diagonal_divisor = Kt(s^2 - 4*p)
    if materialize_orientation:
        reduced_orientation = Kt(
            branch_value_divisor*diagonal_divisor
        )
    else:
        reduced_orientation = None
    full_orientation = None
    if verbose:
        print("degree5 complement: orientation function formed", flush=True)

    zero_polynomial = rational_function_square_class_polynomial(
        zero_divisor
    )
    one_polynomial = rational_function_square_class_polynomial(
        one_divisor
    )
    branch_value_polynomial = (
        rational_function_square_class_polynomial(
            branch_value_divisor
        )
    )
    if verbose:
        print(
            "degree5 complement: branch-value square class extracted",
            flush=True,
        )
    diagonal_polynomial = rational_function_square_class_polynomial(
        diagonal_divisor
    )
    if verbose:
        print(
            "degree5 complement: diagonal square class extracted",
            flush=True,
        )
    branch_quartic = zero_polynomial
    for component in (
        one_polynomial,
        branch_value_polynomial,
        diagonal_polynomial,
    ):
        branch_quartic = multiply_squarefree_classes(
            branch_quartic,
            component,
        )
    if verify_even_factor:
        direct_orientation = Kt(
            zero_divisor
            * one_divisor
            * branch_value_divisor
            * diagonal_divisor
        )
        assert (
            rational_function_square_class_polynomial(
                direct_orientation
            )
            == branch_quartic
        )
        full_orientation = direct_orientation
    if verbose:
        print(
            "degree5 complement: component degrees",
            zero_polynomial.degree(),
            one_polynomial.degree(),
            branch_value_polynomial.degree(),
            diagonal_polynomial.degree(),
            branch_quartic.degree(),
            flush=True,
        )
    assert branch_quartic.degree() in (3, 4)
    assert branch_quartic.is_squarefree()
    if verbose:
        print("degree5 complement: squarefree quartic extracted", flush=True)

    coefficients = [
        branch_quartic[index]
        for index in range(5)
    ]
    quartic_I = (
        12*coefficients[4]*coefficients[0]
        - 3*coefficients[3]*coefficients[1]
        + coefficients[2]^2
    )
    complement_j = K(
        256*quartic_I^3/branch_quartic.discriminant()
    )
    if verbose:
        print("degree5 complement: j-invariant computed", flush=True)

    return {
        "parameter": t,
        "conic_parameterization": {"m": m, "y": y},
        "pair_parameterization": {"s": s, "p": p},
        "base_coordinate": z,
        "branch_value": e,
        "full_orientation": full_orientation,
        "reduced_orientation": reduced_orientation,
        "zero_divisor": zero_divisor,
        "one_divisor": one_divisor,
        "branch_value_divisor": branch_value_divisor,
        "diagonal_divisor": diagonal_divisor,
        "zero_polynomial": zero_polynomial,
        "one_polynomial": one_polynomial,
        "branch_value_polynomial": branch_value_polynomial,
        "diagonal_polynomial": diagonal_polynomial,
        "branch_quartic": branch_quartic,
        "quartic_I": quartic_I,
        "complement_j": complement_j,
    }
