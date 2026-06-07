"""
Degree-independent recovery of hyperelliptic-to-elliptic maps.

The main entry points are ``recover_elliptic_cover`` and
``discover_elliptic_cover``.  The first reconstructs the elliptic
X-coordinate from:

* a hyperelliptic model y^2 = F(x);
* an elliptic target E;
* a pulled-back invariant differential c*h(x)*dx/y;
* a source expansion point and its image on E;
* the degree of the cover, or explicit numerator/denominator bounds.

The discovery wrapper can determine the differential scale exactly and,
over the rationals, search a bounded part of the target Mordell-Weil group
for the image of the selected source point.

Even-degree maps whose elliptic X-coordinate is not fixed by the
hyperelliptic involution are represented as ``A(x)+y*B(x)``.  Their scale can
be discovered over good finite fields and reconstructed by CRT.

All arithmetic is exact.  A returned candidate is accepted only after the
identity induced by the invariant differential and the elliptic equation is
verified in the full function field of the source.
"""


def _series_absolute_precision(series):
    precision = series.precision_absolute()
    if precision is Infinity:
        raise ValueError("the local series must have finite precision")
    return ZZ(precision)


def _coerce_source_point(source_point):
    if source_point is None:
        return None
    if len(source_point) != 2:
        raise ValueError("source_point must be a pair (x0, y0)")
    return tuple(source_point)


def hyperelliptic_local_data(
    source_polynomial,
    precision,
    source_point=None,
    infinity_branch=1,
):
    """
    Construct exact local expansions on y^2 = F(x).

    If ``source_point`` is omitted, the expansion is at infinity.  Degree-six
    and degree-five hyperelliptic models are supported.  For a degree-six
    model, ``infinity_branch`` chooses one of the two square-root branches.

    A finite source point must be non-Weierstrass, since x-x0 is used as the
    local parameter.
    """
    F = source_polynomial
    polynomial_ring = F.parent()
    base_field = polynomial_ring.base_ring()
    x = polynomial_ring.gen()
    degree = F.degree()
    precision = ZZ(precision)
    source_point = _coerce_source_point(source_point)

    if precision < 8:
        raise ValueError("precision must be at least 8")
    characteristic = ZZ(base_field.characteristic())
    if characteristic != 0 and precision >= characteristic:
        raise ValueError(
            "finite-characteristic formal integration requires precision "
            "strictly below the characteristic"
        )

    L = LaurentSeriesRing(
        base_field,
        names=("t",),
        default_prec=precision,
    )
    t = L.gen()
    P = PowerSeriesRing(
        base_field,
        names=("t",),
        default_prec=precision,
    )
    tp = P.gen()

    if source_point is not None:
        x0 = base_field(source_point[0])
        y0 = base_field(source_point[1])
        if y0 == 0:
            raise NotImplementedError(
                "finite Weierstrass expansion points are not supported"
            )
        if y0^2 != F(x0):
            raise ValueError("source_point does not lie on y^2 = F(x)")
        x_series = L(x0 + t).add_bigoh(precision)
        regular_y = P(F(x0 + tp)).sqrt()
        y_series = L(regular_y)
        if y_series[0] != y0:
            y_series = -y_series
        if y_series[0] != y0:
            raise ValueError(
                "the requested finite square-root branch is unavailable"
            )
        dx_dt = L(1)
        label = "finite"
        at_infinity = False
    elif degree == 6:
        normalized = P(
            sum(F[i]*tp^(6-i) for i in range(7))
        ).add_bigoh(precision)
        regular_y = L(normalized.sqrt())
        branch = base_field(infinity_branch)
        if branch not in (base_field(1), base_field(-1)):
            raise ValueError("infinity_branch must be 1 or -1")
        regular_y *= branch
        x_series = L(t^-1)
        y_series = (t^-3*regular_y).add_bigoh(precision-3)
        dx_dt = L(-t^-2)
        label = "infinity_plus" if branch == 1 else "infinity_minus"
        at_infinity = True
    elif degree == 5:
        normalized = P(
            sum(F[i]*tp^(10-2*i) for i in range(6))
        ).add_bigoh(precision)
        regular_y = L(normalized.sqrt())
        branch = base_field(infinity_branch)
        if branch not in (base_field(1), base_field(-1)):
            raise ValueError("infinity_branch must be 1 or -1")
        regular_y *= branch
        x_series = L(t^-2)
        y_series = (t^-5*regular_y).add_bigoh(precision-5)
        dx_dt = L(-2*t^-3)
        label = "infinity"
        at_infinity = True
    else:
        raise NotImplementedError(
            "only degree-five and degree-six source models are supported"
        )

    assert y_series^2 == L(F(x_series))
    return {
        "ring": L,
        "parameter": t,
        "x": x_series,
        "y": y_series,
        "dx_dt": dx_dt,
        "label": label,
        "at_infinity": at_infinity,
        "source_variable": x,
    }


def integrate_eigenform(
    source_polynomial,
    eigenform,
    local_data,
):
    """
    Integrate h(x) dx/y at the selected source point with constant zero.
    """
    F = source_polynomial
    Kx = F.parent().fraction_field()
    h = Kx(eigenform)
    if h == 0:
        raise ValueError("eigenform must be nonzero")

    x_series = local_data["x"]
    y_series = local_data["y"]
    dx_dt = local_data["dx_dt"]
    omega = (
        h(x_series)*dx_dt/y_series
    ).add_bigoh(_series_absolute_precision(y_series))
    if omega.valuation() < 0:
        raise ValueError(
            "the supplied differential is not holomorphic at the source point"
        )
    integral = omega.integral()
    return integral.add_bigoh(_series_absolute_precision(omega)+1)


def elliptic_target_x_series(
    target_curve,
    logarithm_series,
    precision,
    target_center=None,
):
    """
    Expand the elliptic X-coordinate of P+R(t).

    Here R(t) is the formal point whose formal logarithm is
    ``logarithm_series`` and P is ``target_center``.  If P is omitted, it is
    the elliptic origin.
    """
    E = target_curve
    precision = ZZ(precision)
    center = E(0) if target_center is None else E(target_center)
    formal_group = E.formal_group()
    formal_parameter = formal_group.log(precision).reverse()(
        logarithm_series
    )
    formal_x = formal_group.x(precision)(formal_parameter)

    if center.is_zero():
        return formal_x, center

    formal_y = formal_group.y(precision)(formal_parameter)
    point_x = center[0]
    point_y = center[1]
    slope = (formal_y-point_y)/(formal_x-point_x)
    translated_x = (
        slope^2
        + E.a1()*slope
        - E.a2()
        - point_x
        - formal_x
    )
    return translated_x.add_bigoh(
        _series_absolute_precision(formal_x)
    ), center


def rational_reconstruct_from_series(
    source_x_series,
    target_x_series,
    numerator_degree,
    denominator_degree,
    polynomial_ring,
):
    """
    Recover A(x)/B(x) from A(x(t))-X(t)B(x(t)) = O(t^N).

    This homogeneous linear reconstruction works at finite source points and
    at either type of hyperelliptic infinity.
    """
    numerator_degree = ZZ(numerator_degree)
    denominator_degree = ZZ(denominator_degree)
    if numerator_degree < 0 or denominator_degree < 0:
        raise ValueError("degree bounds must be nonnegative")

    x = polynomial_ring.gen()
    base_field = polynomial_ring.base_ring()
    source_powers = [
        source_x_series^i
        for i in range(max(numerator_degree, denominator_degree)+1)
    ]
    basis = [
        source_powers[i]
        for i in range(numerator_degree+1)
    ] + [
        -target_x_series*source_powers[j]
        for j in range(denominator_degree+1)
    ]

    minimum_exponent = min(series.valuation() for series in basis)
    finite_precisions = [
        series.precision_absolute()
        for series in basis
        if series.precision_absolute() is not Infinity
    ]
    if not finite_precisions:
        raise ValueError("the reconstruction needs a truncated target series")
    maximum_exponent = ZZ(min(finite_precisions))
    unknown_count = len(basis)
    if maximum_exponent-minimum_exponent < unknown_count-1:
        raise ValueError(
            "insufficient local precision for rational reconstruction"
        )

    rows = []
    for exponent in range(minimum_exponent, maximum_exponent):
        row = [series[exponent] for series in basis]
        if any(coefficient != 0 for coefficient in row):
            rows.append(row)

    matrix_system = matrix(base_field, rows)
    kernel = matrix_system.right_kernel()
    if kernel.dimension() != 1:
        raise ValueError(
            "reconstruction kernel has dimension "
            f"{kernel.dimension()}, expected 1"
        )

    vector = kernel.basis()[0]
    numerator = polynomial_ring(
        sum(vector[i]*x^i for i in range(numerator_degree+1))
    )
    offset = numerator_degree+1
    denominator = polynomial_ring(
        sum(
            vector[offset+j]*x^j
            for j in range(denominator_degree+1)
        )
    )
    if denominator == 0:
        raise ValueError("reconstruction produced a zero denominator")

    common_factor = numerator.gcd(denominator)
    numerator //= common_factor
    denominator //= common_factor
    leading = denominator.leading_coefficient()
    numerator /= leading
    denominator /= leading
    return polynomial_ring.fraction_field()(numerator/denominator)


def _symbolic_rational_candidate(
    source_x_series,
    target_x_series,
    numerator_degree,
    denominator_degree,
    polynomial_ring,
):
    """
    Construct the generic rational candidate from the first independent rows.

    At a generic symbolic scale the full reconstruction system has trivial
    kernel.  The first ``unknown_count-1`` independent equations instead
    produce a one-dimensional candidate whose exact identity residual cuts
    out the valid scales.
    """
    numerator_degree = ZZ(numerator_degree)
    denominator_degree = ZZ(denominator_degree)
    x = polynomial_ring.gen()
    base_field = polynomial_ring.base_ring()
    source_powers = [
        source_x_series^i
        for i in range(max(numerator_degree, denominator_degree)+1)
    ]
    basis = [
        source_powers[i]
        for i in range(numerator_degree+1)
    ] + [
        -target_x_series*source_powers[j]
        for j in range(denominator_degree+1)
    ]
    unknown_count = len(basis)
    minimum_exponent = min(series.valuation() for series in basis)
    finite_precisions = [
        series.precision_absolute()
        for series in basis
        if series.precision_absolute() is not Infinity
    ]
    if not finite_precisions:
        raise ValueError("the symbolic solve needs a truncated target series")
    maximum_exponent = ZZ(min(finite_precisions))

    independent_rows = []
    system = None
    current_rank = 0
    for exponent in range(minimum_exponent, maximum_exponent):
        row = [series[exponent] for series in basis]
        if not any(coefficient != 0 for coefficient in row):
            continue
        trial = matrix(base_field, independent_rows+[row])
        trial_rank = trial.rank()
        if trial_rank > current_rank:
            independent_rows.append(row)
            current_rank = trial_rank
        if current_rank == unknown_count-1:
            system = trial
            break

    if system is None:
        raise ValueError(
            "insufficient independent local equations for symbolic recovery"
        )
    kernel = system.right_kernel()
    if kernel.dimension() != 1:
        raise ValueError(
            "symbolic reconstruction kernel has dimension "
            f"{kernel.dimension()}, expected 1"
        )

    vector = kernel.basis()[0]
    numerator = polynomial_ring(
        sum(vector[i]*x^i for i in range(numerator_degree+1))
    )
    offset = numerator_degree+1
    denominator = polynomial_ring(
        sum(
            vector[offset+j]*x^j
            for j in range(denominator_degree+1)
        )
    )
    if denominator == 0:
        raise ValueError("symbolic reconstruction has zero denominator")
    return polynomial_ring.fraction_field()(numerator/denominator)


def elliptic_cover_identity(
    source_polynomial,
    target_curve,
    eigenform,
    differential_scale,
    x_coordinate,
):
    """
    Return the exact residual for the map and differential identity.
    """
    F = source_polynomial
    Kx = F.parent().fraction_field()
    E = target_curve
    X = Kx(x_coordinate)
    h = Kx(eigenform)
    c = F.base_ring()(differential_scale)
    b2 = E.a1()^2 + 4*E.a2()
    b4 = 2*E.a4() + E.a1()*E.a3()
    b6 = E.a3()^2 + 4*E.a6()
    completed_square_rhs = (
        4*X^3 + b2*X^2 + 2*b4*X + b6
    )
    return Kx(
        F*X.derivative()^2
        - c^2*h^2*completed_square_rhs
    )


def elliptic_cover_y_data(
    target_curve,
    eigenform,
    differential_scale,
    x_coordinate,
):
    """
    Return M(x), N(x) such that Y = y*M(x)+N(x).
    """
    E = target_curve
    X = x_coordinate
    Kx = X.parent()
    h = Kx(eigenform)
    c = Kx.base_ring()(differential_scale)
    multiplier = X.derivative()/(2*c*h)
    offset = -(E.a1()*X+E.a3())/2
    return Kx(multiplier), Kx(offset)


def rational_function_degree(value):
    value = value.parent()(value)
    return max(
        value.numerator().degree(),
        value.denominator().degree(),
    )


def _quadratic_function_add(left, right):
    return (left[0]+right[0], left[1]+right[1])


def _quadratic_function_scale(scalar, value):
    return (scalar*value[0], scalar*value[1])


def _quadratic_function_multiply(left, right, source_polynomial):
    return (
        left[0]*right[0]
        + source_polynomial*left[1]*right[1],
        left[0]*right[1]+left[1]*right[0],
    )


def _quadratic_function_power(value, exponent, source_polynomial):
    exponent = ZZ(exponent)
    if exponent < 0:
        raise ValueError("quadratic-function exponent must be nonnegative")
    one = value[0].parent()(1)
    answer = (one, one.parent()(0))
    base = value
    while exponent:
        if exponent % 2:
            answer = _quadratic_function_multiply(
                answer,
                base,
                source_polynomial,
            )
        base = _quadratic_function_multiply(
            base,
            base,
            source_polynomial,
        )
        exponent //= 2
    return answer


def _quadratic_function_derivative(value, source_polynomial):
    """
    Differentiate a+b*y in QQ(x,y), where y^2=F(x).
    """
    a, b = value
    F = source_polynomial
    return (
        a.derivative(),
        b.derivative()+b*F.derivative()/(2*F),
    )


def _quadratic_function_is_zero(value):
    return value[0] == 0 and value[1] == 0


def _quadratic_function_candidate_from_series(
    source_x_series,
    source_y_series,
    target_x_series,
    numerator_degree,
    y_numerator_degree,
    denominator_degree,
    polynomial_ring,
):
    """
    Recover X=(A(x)+y*B(x))/D(x) from one exact local expansion.
    """
    numerator_degree = ZZ(numerator_degree)
    y_numerator_degree = ZZ(y_numerator_degree)
    denominator_degree = ZZ(denominator_degree)
    if min(
        numerator_degree,
        y_numerator_degree,
        denominator_degree,
    ) < 0:
        raise ValueError("quadratic reconstruction degrees must be nonnegative")

    x = polynomial_ring.gen()
    base_field = polynomial_ring.base_ring()
    maximum_degree = max(
        numerator_degree,
        y_numerator_degree,
        denominator_degree,
    )
    source_powers = [
        source_x_series^i
        for i in range(maximum_degree+1)
    ]
    basis = [
        source_powers[i]
        for i in range(numerator_degree+1)
    ] + [
        source_y_series*source_powers[i]
        for i in range(y_numerator_degree+1)
    ] + [
        -target_x_series*source_powers[i]
        for i in range(denominator_degree+1)
    ]
    minimum_exponent = min(series.valuation() for series in basis)
    finite_precisions = [
        series.precision_absolute()
        for series in basis
        if series.precision_absolute() is not Infinity
    ]
    if not finite_precisions:
        raise ValueError(
            "quadratic reconstruction needs a truncated target series"
        )
    maximum_exponent = ZZ(min(finite_precisions))

    rows = []
    for exponent in range(minimum_exponent, maximum_exponent):
        row = [series[exponent] for series in basis]
        if not any(coefficient != 0 for coefficient in row):
            continue
        rows.append(row)

    system = matrix(base_field, rows)
    kernel = system.right_kernel()
    if kernel.dimension() != 1:
        raise ValueError(
            "quadratic reconstruction kernel has dimension "
            f"{kernel.dimension()}, expected 1"
        )

    vector = kernel.basis()[0]
    a_offset = numerator_degree+1
    b_offset = a_offset+y_numerator_degree+1
    numerator = polynomial_ring(
        sum(vector[i]*x^i for i in range(a_offset))
    )
    y_numerator = polynomial_ring(
        sum(
            vector[a_offset+i]*x^i
            for i in range(y_numerator_degree+1)
        )
    )
    denominator = polynomial_ring(
        sum(
            vector[b_offset+i]*x^i
            for i in range(denominator_degree+1)
        )
    )
    if denominator == 0:
        raise ValueError(
            "quadratic reconstruction produced a zero denominator"
        )

    common = numerator.gcd(y_numerator).gcd(denominator)
    if not common.is_constant():
        numerator //= common
        y_numerator //= common
        denominator //= common
    Kx = polynomial_ring.fraction_field()
    return (
        Kx(numerator/denominator),
        Kx(y_numerator/denominator),
    )


def general_elliptic_cover_identity(
    source_polynomial,
    target_curve,
    eigenform,
    differential_scale,
    x_coordinate,
):
    """
    Certify a general pullback X=a(x)+y*b(x).

    The returned pair is the coefficient of 1 and y in the completed-square
    Weierstrass equation.  Both entries vanish exactly when the elliptic
    equation and differential pullback hold.
    """
    F = source_polynomial
    E = target_curve
    Kx = F.parent().fraction_field()
    X = (Kx(x_coordinate[0]), Kx(x_coordinate[1]))
    h = Kx(eigenform)
    c = Kx.base_ring()(differential_scale)
    derivative = _quadratic_function_derivative(X, F)
    completed_y = (
        F*derivative[1]/(c*h),
        derivative[0]/(c*h),
    )

    b2 = E.a1()^2+4*E.a2()
    b4 = 2*E.a4()+E.a1()*E.a3()
    b6 = E.a3()^2+4*E.a6()
    rhs = _quadratic_function_add(
        _quadratic_function_scale(
            4,
            _quadratic_function_power(X, 3, F),
        ),
        _quadratic_function_add(
            _quadratic_function_scale(
                b2,
                _quadratic_function_power(X, 2, F),
            ),
            _quadratic_function_add(
                _quadratic_function_scale(2*b4, X),
                (Kx(b6), Kx(0)),
            ),
        ),
    )
    lhs = _quadratic_function_power(completed_y, 2, F)
    return (
        Kx(lhs[0]-rhs[0]),
        Kx(lhs[1]-rhs[1]),
    )


def general_elliptic_cover_y_coordinate(
    source_polynomial,
    target_curve,
    eigenform,
    differential_scale,
    x_coordinate,
):
    """
    Return Y=c(x)+y*d(x) for a certified general elliptic cover.
    """
    F = source_polynomial
    E = target_curve
    Kx = F.parent().fraction_field()
    X = (Kx(x_coordinate[0]), Kx(x_coordinate[1]))
    h = Kx(eigenform)
    c = Kx.base_ring()(differential_scale)
    derivative = _quadratic_function_derivative(X, F)
    completed_y = (
        F*derivative[1]/(c*h),
        derivative[0]/(c*h),
    )
    correction = (
        E.a1()*X[0]+E.a3(),
        E.a1()*X[1],
    )
    return (
        Kx((completed_y[0]-correction[0])/2),
        Kx((completed_y[1]-correction[1])/2),
    )


def general_x_coordinate_degree(
    source_polynomial,
    x_coordinate,
):
    """
    Compute [QQ(C):QQ(X)] from X=a(x)+y*b(x) by elimination.
    """
    F = source_polynomial
    polynomial_ring = F.parent()
    base_field = polynomial_ring.base_ring()
    x = polynomial_ring.gen()
    a = polynomial_ring.fraction_field()(x_coordinate[0])
    b = polynomial_ring.fraction_field()(x_coordinate[1])
    common_denominator = lcm(
        a.denominator(),
        b.denominator(),
    )
    A = polynomial_ring(a*common_denominator)
    B = polynomial_ring(b*common_denominator)
    D = polynomial_ring(common_denominator)
    parameter_ring = PolynomialRing(base_field, names=("target_x",))
    target_x = parameter_ring.gen()
    coefficient_ring = PolynomialRing(parameter_ring, names=(str(x),))
    base_factor = (D^2).gcd(D*A).gcd(A^2-B^2*F)
    relation = (
        (target_x*coefficient_ring(D)-coefficient_ring(A))^2
        - coefficient_ring(B)^2*coefficient_ring(F)
    )
    if not base_factor.is_constant():
        relation = relation.quo_rem(coefficient_ring(base_factor))[0]
    return ZZ(relation.degree())


def recover_general_elliptic_cover(
    source_polynomial,
    target_curve,
    eigenform,
    differential_scale,
    cover_degree,
    degree_bounds,
    infinity_branch=1,
    precision=None,
):
    """
    Reconstruct and certify X=A(x)+y*B(x) for a known differential scale.
    """
    F = source_polynomial
    E = target_curve
    degree = ZZ(cover_degree)
    numerator_degree, y_numerator_degree, denominator_degree = (
        ZZ(value) for value in degree_bounds
    )
    if precision is None:
        precision = max(
            32,
            numerator_degree
            + y_numerator_degree
            + denominator_degree
            + 12,
        )
    precision = ZZ(precision)
    local_data = hyperelliptic_local_data(
        F,
        precision,
        infinity_branch=infinity_branch,
    )
    integral = integrate_eigenform(F, eigenform, local_data)
    target_x_series, _ = elliptic_target_x_series(
        E,
        F.base_ring()(differential_scale)*integral,
        precision,
        target_center=E(0),
    )
    x_coordinate = _quadratic_function_candidate_from_series(
        local_data["x"],
        local_data["y"],
        target_x_series,
        numerator_degree,
        y_numerator_degree,
        denominator_degree,
        F.parent(),
    )
    residual = general_elliptic_cover_identity(
        F,
        E,
        eigenform,
        differential_scale,
        x_coordinate,
    )
    if not _quadratic_function_is_zero(residual):
        raise ValueError("the reconstructed general map failed certification")
    x_degree = general_x_coordinate_degree(F, x_coordinate)
    if x_degree != 2*degree:
        raise ValueError(
            f"general X-coordinate has degree {x_degree}, expected {2*degree}"
        )
    return {
        "verified": True,
        "x_coordinate": x_coordinate,
        "y_coordinate": general_elliptic_cover_y_coordinate(
            F,
            E,
            eigenform,
            differential_scale,
            x_coordinate,
        ),
        "differential_scale": F.base_ring()(differential_scale),
        "degree_bounds": (
            numerator_degree,
            y_numerator_degree,
            denominator_degree,
        ),
        "x_coordinate_degree": x_degree,
        "cover_degree": degree,
        "infinity_branch": ZZ(infinity_branch),
        "target_center": E(0),
    }


def discover_general_scale_by_crt(
    source_polynomial,
    target_curve,
    eigenform,
    cover_degree,
    degree_bounds,
    primes,
    infinity_branch=1,
    precision=None,
):
    """
    Discover c^2 modulo good primes and reconstruct c over QQ.

    This avoids a large symbolic solve over QQ(c).  Every modular residue is
    accepted only after the full quadratic-function identity is checked.
    """
    F = source_polynomial
    E = target_curve
    degree = ZZ(cover_degree)
    if F.base_ring() is not QQ or E.base_ring() is not QQ:
        raise NotImplementedError(
            "CRT scale discovery currently requires rational input"
        )
    numerator_degree, y_numerator_degree, denominator_degree = (
        ZZ(value) for value in degree_bounds
    )
    if precision is None:
        precision = max(
            32,
            numerator_degree
            + y_numerator_degree
            + denominator_degree
            + 12,
        )
    precision = ZZ(precision)

    certificates = []
    for prime in primes:
        prime = ZZ(prime)
        if not prime.is_prime():
            raise ValueError(f"{prime} is not prime")
        if prime <= precision:
            raise ValueError(
                f"prime {prime} must exceed precision {precision}"
            )
        finite_field = GF(prime)
        finite_ring = PolynomialRing(
            finite_field,
            names=(str(F.parent().gen()),),
        )
        finite_source = finite_ring(F)
        if finite_source.discriminant() == 0:
            raise ValueError(f"source has bad reduction at {prime}")
        finite_target = E.change_ring(finite_field)
        local_data = hyperelliptic_local_data(
            finite_source,
            precision,
            infinity_branch=infinity_branch,
        )
        finite_eigenform = _change_rational_function_ring(
            F.parent().fraction_field()(eigenform),
            finite_ring,
        )
        integral = integrate_eigenform(
            finite_source,
            finite_eigenform,
            local_data,
        )

        matches = []
        for scale in finite_field:
            if scale == 0:
                continue
            try:
                target_x_series, _ = elliptic_target_x_series(
                    finite_target,
                    scale*integral,
                    precision,
                    target_center=finite_target(0),
                )
                candidate = _quadratic_function_candidate_from_series(
                    local_data["x"],
                    local_data["y"],
                    target_x_series,
                    numerator_degree,
                    y_numerator_degree,
                    denominator_degree,
                    finite_ring,
                )
                residual = general_elliptic_cover_identity(
                    finite_source,
                    finite_target,
                    finite_eigenform,
                    scale,
                    candidate,
                )
                if (
                    _quadratic_function_is_zero(residual)
                    and general_x_coordinate_degree(
                        finite_source,
                        candidate,
                    ) == 2*degree
                ):
                    matches.append(scale)
            except (ArithmeticError, ValueError, ZeroDivisionError):
                continue
        square_classes = sorted(set(scale^2 for scale in matches))
        if len(square_classes) != 1:
            raise ValueError(
                f"expected one certified scale square at {prime}, "
                f"found {square_classes}"
            )
        certificates.append(
            {
                "prime": prime,
                "scale_roots": matches,
                "scale_square": square_classes[0],
            }
        )

    moduli = [certificate["prime"] for certificate in certificates]
    residues = [
        ZZ(certificate["scale_square"])
        for certificate in certificates
    ]
    modulus = prod(moduli)
    scale_square = QQ(
        rational_reconstruction(
            crt(residues, moduli),
            modulus,
        )
    )
    if not scale_square.is_square():
        raise ValueError(
            f"reconstructed scale square {scale_square} is not rationally "
            "square"
        )
    return {
        "verified": True,
        "scale": scale_square.sqrt(),
        "scale_square": scale_square,
        "crt_modulus": modulus,
        "certificates": certificates,
    }


def _degree_bound_candidates(
    cover_degree,
    local_data,
    target_x_series,
):
    degree = ZZ(cover_degree)
    if degree < 1:
        raise ValueError("cover_degree must be positive")

    if local_data["at_infinity"]:
        source_pole_order = -local_data["x"].valuation()
        target_valuation = target_x_series.valuation()
        if target_valuation % source_pole_order == 0:
            degree_difference = -target_valuation // source_pole_order
            if degree_difference >= 0:
                candidate = (degree, degree-degree_difference)
            else:
                candidate = (degree+degree_difference, degree)
            if min(candidate) >= 0:
                return [candidate]

    candidates = [(degree, denominator) for denominator in range(degree+1)]
    candidates.extend(
        (numerator, degree) for numerator in range(degree)
    )
    return candidates


def _normalize_degree_bounds(degree_bounds):
    if degree_bounds is None:
        return None
    if len(degree_bounds) == 2 and all(
        not isinstance(value, (tuple, list))
        for value in degree_bounds
    ):
        return [tuple(ZZ(value) for value in degree_bounds)]
    return [
        tuple(ZZ(value) for value in pair)
        for pair in degree_bounds
    ]


def _change_rational_function_ring(value, polynomial_ring):
    source = value.parent()(value)
    target_field = polynomial_ring.fraction_field()
    return target_field(
        polynomial_ring(source.numerator())
        / polynomial_ring(source.denominator())
    )


def _center_key(point):
    if point.is_zero():
        return ("origin",)
    return tuple(str(coordinate) for coordinate in point)


def mordell_weil_center_candidates(
    target_curve,
    coefficient_bound,
    priority_multiple=None,
):
    """
    Enumerate a bounded exact Mordell-Weil box over QQ.

    The origin is first.  For rank one, negative and positive small multiples
    are followed by the requested priority multiple, typically the cover
    degree.  Torsion translates and higher-rank boxes are also supported.
    """
    E = target_curve
    if E.base_ring() is not QQ:
        raise NotImplementedError(
            "automatic Mordell-Weil center search currently requires QQ"
        )
    coefficient_bound = ZZ(coefficient_bound)
    if coefficient_bound < 0:
        raise ValueError("coefficient_bound must be nonnegative")

    torsion_points = list(E.torsion_points())
    free_generators = list(E.gens())
    rank = len(free_generators)
    coefficient_vectors = [tuple(ZZ(0) for _ in range(rank))]

    if rank == 1:
        priority = []
        for value in range(1, coefficient_bound+1):
            priority.extend([-ZZ(value), ZZ(value)])
            if value == 1 and priority_multiple is not None:
                special = ZZ(priority_multiple)
                if 1 < special <= coefficient_bound:
                    priority.extend([-special, special])
        seen_coefficients = set()
        coefficient_vectors = [(ZZ(0),)]
        seen_coefficients.add((ZZ(0),))
        for value in priority:
            vector = (value,)
            if vector not in seen_coefficients:
                coefficient_vectors.append(vector)
                seen_coefficients.add(vector)
    elif rank > 1:
        coefficient_vectors = sorted(
            cartesian_product(
                [range(-coefficient_bound, coefficient_bound+1)]*rank
            ),
            key=lambda vector: (
                max(abs(ZZ(value)) for value in vector),
                sum(abs(ZZ(value)) for value in vector),
                tuple(ZZ(value) for value in vector),
            ),
        )

    points = []
    seen_points = set()
    for coefficients in coefficient_vectors:
        free_point = E(0)
        for coefficient, generator in zip(
            coefficients,
            free_generators,
        ):
            free_point += coefficient*generator
        for torsion_point in torsion_points:
            point = free_point+torsion_point
            key = _center_key(point)
            if key not in seen_points:
                points.append(point)
                seen_points.add(key)
    if _center_key(E(0)) not in seen_points:
        points.insert(0, E(0))
    else:
        origin_index = next(
            index
            for index, point in enumerate(points)
            if point.is_zero()
        )
        points.insert(0, points.pop(origin_index))
    return points


def _scale_polynomial_for_center(
    source_polynomial,
    target_curve,
    eigenform,
    cover_degree,
    degree_bounds,
    source_point,
    infinity_branch,
    target_center,
    precision,
):
    base_field = source_polynomial.base_ring()
    scale_ring = PolynomialRing(base_field, names=("scale",))
    scale = scale_ring.gen()
    symbolic_field = scale_ring.fraction_field()
    source_ring = PolynomialRing(
        symbolic_field,
        names=(str(source_polynomial.parent().gen()),),
    )
    symbolic_source = source_ring(source_polynomial)
    symbolic_eigenform = _change_rational_function_ring(
        source_polynomial.parent().fraction_field()(eigenform),
        source_ring,
    )
    symbolic_target = target_curve.change_ring(symbolic_field)
    if target_center.is_zero():
        symbolic_center = symbolic_target(0)
    else:
        symbolic_center = symbolic_target(
            symbolic_field(target_center[0]),
            symbolic_field(target_center[1]),
        )
    symbolic_source_point = (
        None
        if source_point is None
        else tuple(symbolic_field(value) for value in source_point)
    )

    local_data = hyperelliptic_local_data(
        symbolic_source,
        precision,
        source_point=symbolic_source_point,
        infinity_branch=infinity_branch,
    )
    integral = integrate_eigenform(
        symbolic_source,
        symbolic_eigenform,
        local_data,
    )
    target_x_series, _ = elliptic_target_x_series(
        symbolic_target,
        scale*integral,
        precision,
        target_center=symbolic_center,
    )
    normalized_bounds = _normalize_degree_bounds(degree_bounds)
    if normalized_bounds is None:
        bounds_candidates = _degree_bound_candidates(
            cover_degree,
            local_data,
            target_x_series,
        )
    else:
        bounds_candidates = normalized_bounds

    scale_polynomials = []
    failures = []
    for bounds in bounds_candidates:
        try:
            candidate_x = _symbolic_rational_candidate(
                local_data["x"],
                target_x_series,
                bounds[0],
                bounds[1],
                source_ring,
            )
            residual = elliptic_cover_identity(
                symbolic_source,
                symbolic_target,
                symbolic_eigenform,
                scale,
                candidate_x,
            )
            coefficient_polynomials = [
                scale_ring(coefficient.numerator())
                for coefficient in residual.numerator().coefficients()
                if coefficient != 0
            ]
            if not coefficient_polynomials:
                raise ValueError(
                    "symbolic residual vanished identically in the scale"
                )
            common = coefficient_polynomials[0]
            for polynomial in coefficient_polynomials[1:]:
                common = common.gcd(polynomial)
                if common.is_constant():
                    break
            while common != 0 and common[0] == 0:
                common //= scale
            if common.is_constant():
                failures.append(
                    {
                        "bounds": tuple(int(value) for value in bounds),
                        "reason": "scale equations have no common root",
                    }
                )
                continue
            scale_polynomials.append((common.monic(), bounds))
        except (ArithmeticError, ValueError, ZeroDivisionError) as error:
            failures.append(
                {
                    "bounds": tuple(int(value) for value in bounds),
                    "reason": str(error),
                }
            )
    return scale_polynomials, failures


def discover_elliptic_cover(
    source_polynomial,
    target_curve,
    eigenform,
    cover_degree,
    degree_bounds=None,
    source_point=None,
    infinity_branch=1,
    target_centers=None,
    mordell_weil_bound=None,
    symbolic_precision=None,
):
    """
    Discover the differential scale and target center, then certify the map.

    If ``target_centers`` is omitted, the origin is tested first.  Over QQ,
    a bounded Mordell-Weil search follows.  The bound defaults to the cover
    degree.  Over other fields explicit center candidates are required unless
    the source point maps to the origin.
    """
    F = source_polynomial
    E = target_curve
    base_field = F.base_ring()
    degree = ZZ(cover_degree)
    if symbolic_precision is None:
        symbolic_precision = max(20, 2*degree+10)
    symbolic_precision = ZZ(symbolic_precision)

    if target_centers is None:
        centers = [E(0)]
        use_mordell_weil_search = True
    else:
        centers = [E(point) for point in target_centers]
        use_mordell_weil_search = False

    attempts = []
    discoveries = []
    visited = set()

    while centers:
        center = centers.pop(0)
        center_key = _center_key(center)
        if center_key in visited:
            continue
        visited.add(center_key)
        scale_data, failures = _scale_polynomial_for_center(
            F,
            E,
            eigenform,
            degree,
            degree_bounds,
            source_point,
            infinity_branch,
            center,
            symbolic_precision,
        )
        center_attempt = {
            "center": center,
            "scale_polynomials": [
                (polynomial, bounds)
                for polynomial, bounds in scale_data
            ],
            "failures": failures,
        }
        attempts.append(center_attempt)

        for scale_polynomial, bounds in scale_data:
            roots = scale_polynomial.roots(base_field)
            for scale, multiplicity in roots:
                if scale == 0:
                    continue
                try:
                    answer = recover_elliptic_cover(
                        F,
                        E,
                        eigenform,
                        scale,
                        cover_degree=degree,
                        degree_bounds=bounds,
                        source_point=source_point,
                        infinity_branch=infinity_branch,
                        target_center=center,
                    )
                except (ArithmeticError, ValueError, ZeroDivisionError):
                    continue
                answer["scale_polynomial"] = scale_polynomial
                answer["scale_root_multiplicity"] = ZZ(multiplicity)
                discoveries.append(answer)

        if discoveries:
            break
        if (
            not centers
            and use_mordell_weil_search
            and len(visited) == 1
        ):
            if base_field is not QQ:
                break
            search_bound = (
                degree
                if mordell_weil_bound is None
                else ZZ(mordell_weil_bound)
            )
            centers.extend(
                mordell_weil_center_candidates(
                    E,
                    search_bound,
                    priority_multiple=degree,
                )
            )

    unique = {}
    for answer in discoveries:
        key = (
            str(answer["x_coordinate"]),
            str(answer["y_multiplier"]),
            str(answer["y_offset"]),
        )
        unique[key] = answer
    answers = list(unique.values())
    if not answers:
        raise ValueError(
            "no certified map found in the target-center search; "
            f"attempted {len(attempts)} centers"
        )
    return {
        "verified": True,
        "maps": answers,
        "attempted_centers": attempts,
        "mordell_weil_bound": (
            None
            if not use_mordell_weil_search
            else (
                degree
                if mordell_weil_bound is None
                else ZZ(mordell_weil_bound)
            )
        ),
        "symbolic_precision": symbolic_precision,
    }


def discover_center_by_crt(
    source_polynomial,
    target_curve,
    eigenform,
    differential_scale,
    cover_degree,
    degree_bounds,
    primes,
    infinity_branch=1,
    precision=None,
    allow_partial=False,
    initial_state=None,
):
    """
    Recover a rational finite target center from modular map searches.

    The differential scale is assumed known.  At each good prime, every
    target point is tested until the exact finite-field map identity succeeds.
    The affine center coordinates are combined by CRT and rational
    reconstruction.  A lift is accepted only when it lies on the rational
    target and the full characteristic-zero map recovery succeeds.

    When ``allow_partial`` is true, return the accumulated CRT state and
    per-prime failures instead of raising if the supplied primes do not yet
    determine a certified rational center.  A partial result from an earlier
    call may be supplied as ``initial_state`` to resume the reconstruction
    without repeating its modular searches.
    """
    F = source_polynomial
    E = target_curve
    degree = ZZ(cover_degree)
    base_field = F.base_ring()
    if base_field is not QQ or E.base_ring() is not QQ:
        raise NotImplementedError(
            "CRT center discovery currently requires rational input"
        )
    normalized_bounds = _normalize_degree_bounds(degree_bounds)
    if normalized_bounds is None or len(normalized_bounds) != 1:
        raise ValueError("supply one explicit degree-bound pair")
    bounds = normalized_bounds[0]
    if precision is None:
        precision = max(32, 6*degree+20)
    precision = ZZ(precision)

    if initial_state is None:
        x_residue = ZZ(0)
        y_residue = ZZ(0)
        modulus = ZZ(1)
        certificates = []
        failures = []
    else:
        modulus = ZZ(initial_state["crt_modulus"])
        residues = initial_state["center_residues"]
        x_residue = ZZ(residues["x"]) % modulus
        y_residue = ZZ(residues["y"]) % modulus
        certificates = list(initial_state.get("certificates", []))
        failures = list(initial_state.get("failures", []))
        if modulus <= 0:
            raise ValueError("initial CRT modulus must be positive")

    for prime in primes:
        prime = ZZ(prime)
        if not prime.is_prime():
            raise ValueError(f"{prime} is not prime")
        if prime <= precision:
            raise ValueError(
                f"prime {prime} must exceed precision {precision}"
            )
        if gcd(modulus, prime) != 1:
            raise ValueError(
                f"prime {prime} already divides the CRT modulus"
            )
        finite_field = GF(prime)
        finite_ring = PolynomialRing(
            finite_field,
            names=(str(F.parent().gen()),),
        )
        finite_source = finite_ring(F)
        if finite_source.discriminant() == 0:
            failures.append({
                "prime": prime,
                "reason": "source has bad reduction",
            })
            continue
        try:
            finite_target = E.change_ring(finite_field)
        except (ArithmeticError, ValueError, ZeroDivisionError):
            failures.append({
                "prime": prime,
                "reason": "target has bad reduction",
            })
            continue
        if finite_target.discriminant() == 0:
            failures.append({
                "prime": prime,
                "reason": "target has bad reduction",
            })
            continue

        finite_eigenform = _change_rational_function_ring(
            F.parent().fraction_field()(eigenform),
            finite_ring,
        )
        finite_scale = finite_field(differential_scale)
        matches = []
        for point_index, center in enumerate(finite_target):
            try:
                answer = recover_elliptic_cover(
                    finite_source,
                    finite_target,
                    finite_eigenform,
                    finite_scale,
                    cover_degree=degree,
                    degree_bounds=bounds,
                    infinity_branch=infinity_branch,
                    target_center=center,
                    precision=precision,
                )
            except (ArithmeticError, ValueError, ZeroDivisionError):
                continue
            matches.append((center, answer, point_index+1))

        if len(matches) != 1:
            failures.append({
                "prime": prime,
                "reason": (
                    "expected one modular center, found "
                    f"{len(matches)}"
                ),
            })
            continue

        center, finite_answer, point_attempt_count = matches[0]
        if center.is_zero():
            try:
                answer = recover_elliptic_cover(
                    F,
                    E,
                    eigenform,
                    differential_scale,
                    cover_degree=degree,
                    degree_bounds=bounds,
                    infinity_branch=infinity_branch,
                    target_center=E(0),
                )
            except (ArithmeticError, ValueError, ZeroDivisionError):
                failures.append({
                    "prime": prime,
                    "reason": (
                        "modular center is the origin but the rational "
                        "origin failed certification"
                    ),
                })
                continue
            return {
                "verified": True,
                "map": answer,
                "target_center": E(0),
                "differential_scale": QQ(differential_scale),
                "crt_modulus": ZZ(1),
                "center_residues": None,
                "certificates": [],
                "failures": failures,
            }
        center_x = center[0]
        center_y = center[1]
        x_residue = CRT(
            x_residue,
            ZZ(center_x),
            modulus,
            prime,
        )
        y_residue = CRT(
            y_residue,
            ZZ(center_y),
            modulus,
            prime,
        )
        modulus *= prime
        certificate = {
            "prime": prime,
            "center_x": ZZ(center_x),
            "center_y": ZZ(center_y),
            "point_attempt_count": ZZ(point_attempt_count),
            "x_coordinate": finite_answer["x_coordinate"],
        }
        certificates.append(certificate)

        try:
            rational_x = x_residue.rational_reconstruction(modulus)
            rational_y = y_residue.rational_reconstruction(modulus)
        except ArithmeticError:
            continue
        try:
            rational_center = E(rational_x, rational_y)
        except (ArithmeticError, TypeError, ValueError):
            continue
        try:
            answer = recover_elliptic_cover(
                F,
                E,
                eigenform,
                differential_scale,
                cover_degree=degree,
                degree_bounds=bounds,
                infinity_branch=infinity_branch,
                target_center=rational_center,
            )
        except (ArithmeticError, ValueError, ZeroDivisionError):
            continue
        return {
            "verified": True,
            "map": answer,
            "target_center": rational_center,
            "differential_scale": QQ(differential_scale),
            "crt_modulus": modulus,
            "center_residues": {
                "x": x_residue,
                "y": y_residue,
            },
            "certificates": certificates,
            "failures": failures,
        }

    partial = {
        "verified": False,
        "map": None,
        "target_center": None,
        "differential_scale": QQ(differential_scale),
        "crt_modulus": modulus,
        "center_residues": {
            "x": x_residue,
            "y": y_residue,
        },
        "certificates": certificates,
        "failures": failures,
    }
    if allow_partial:
        return partial
    raise ValueError(
        "no rational target center reconstructed from supplied primes; "
        f"CRT modulus={modulus}"
    )


def _map_coefficient_vector(
    x_coordinate,
    degree_bounds,
    polynomial_ring,
    map_type,
):
    """
    Return a padded projective coefficient vector for an elliptic X-map.

    Rational maps use ``A/D``.  General maps use ``(A+y*B)/D``.  No
    normalization is imposed here because finite-field vectors are normalized
    at a common projective pivot by the CRT driver.
    """
    Kx = polynomial_ring.fraction_field()
    if map_type == "rational":
        numerator_degree, denominator_degree = (
            ZZ(value) for value in degree_bounds
        )
        X = Kx(x_coordinate)
        A = polynomial_ring(X.numerator())
        D = polynomial_ring(X.denominator())
        common = A.gcd(D)
        if not common.is_constant():
            A //= common
            D //= common
        return tuple(
            [A[i] for i in range(numerator_degree+1)]
            + [D[i] for i in range(denominator_degree+1)]
        )

    if map_type == "general":
        numerator_degree, y_numerator_degree, denominator_degree = (
            ZZ(value) for value in degree_bounds
        )
        a = Kx(x_coordinate[0])
        b = Kx(x_coordinate[1])
        common_denominator = lcm(a.denominator(), b.denominator())
        A = polynomial_ring(a*common_denominator)
        B = polynomial_ring(b*common_denominator)
        D = polynomial_ring(common_denominator)
        common = A.gcd(B).gcd(D)
        if not common.is_constant():
            A //= common
            B //= common
            D //= common
        return tuple(
            [A[i] for i in range(numerator_degree+1)]
            + [B[i] for i in range(y_numerator_degree+1)]
            + [D[i] for i in range(denominator_degree+1)]
        )

    raise ValueError("map_type must be 'rational' or 'general'")


def _normalize_projective_vector(vector, pivot_index=None):
    """
    Normalize a coefficient vector by one nonzero projective coordinate.
    """
    if pivot_index is None:
        nonzero_indices = [
            index
            for index, coefficient in enumerate(vector)
            if coefficient != 0
        ]
        if not nonzero_indices:
            raise ValueError("the map coefficient vector is zero")
        pivot_index = nonzero_indices[-1]
    pivot_index = ZZ(pivot_index)
    if not 0 <= pivot_index < len(vector):
        raise ValueError("projective pivot index is out of range")
    pivot = vector[pivot_index]
    if pivot == 0:
        raise ValueError("projective pivot vanishes")
    return (
        tuple(coefficient/pivot for coefficient in vector),
        pivot_index,
    )


def _map_from_coefficient_vector(
    coefficients,
    degree_bounds,
    polynomial_ring,
    map_type,
):
    """
    Rebuild a rational or quadratic-function X-coordinate from coefficients.
    """
    x = polynomial_ring.gen()
    Kx = polynomial_ring.fraction_field()
    if map_type == "rational":
        numerator_degree, denominator_degree = (
            ZZ(value) for value in degree_bounds
        )
        offset = numerator_degree+1
        A = polynomial_ring(sum(
            coefficients[i]*x^i
            for i in range(numerator_degree+1)
        ))
        D = polynomial_ring(sum(
            coefficients[offset+i]*x^i
            for i in range(denominator_degree+1)
        ))
        if D == 0:
            raise ValueError("reconstructed denominator is zero")
        return Kx(A/D)

    if map_type == "general":
        numerator_degree, y_numerator_degree, denominator_degree = (
            ZZ(value) for value in degree_bounds
        )
        b_offset = numerator_degree+1
        d_offset = b_offset+y_numerator_degree+1
        A = polynomial_ring(sum(
            coefficients[i]*x^i
            for i in range(numerator_degree+1)
        ))
        B = polynomial_ring(sum(
            coefficients[b_offset+i]*x^i
            for i in range(y_numerator_degree+1)
        ))
        D = polynomial_ring(sum(
            coefficients[d_offset+i]*x^i
            for i in range(denominator_degree+1)
        ))
        if D == 0:
            raise ValueError("reconstructed denominator is zero")
        return (Kx(A/D), Kx(B/D))

    raise ValueError("map_type must be 'rational' or 'general'")


def discover_coefficients_by_crt(
    source_polynomial,
    target_curve,
    eigenform,
    differential_scale,
    cover_degree,
    degree_bounds,
    primes,
    map_type="rational",
    source_point=None,
    infinity_branch=1,
    target_center=None,
    precision=None,
    allow_partial=False,
    initial_state=None,
):
    """
    Recover all coefficients of an elliptic X-map by modular CRT lifting.

    For ``map_type="rational"`` the reconstructed coordinate is ``A(x)/D(x)``.
    For ``map_type="general"`` it is ``A(x)/D(x)+y*B(x)/D(x)``.  Each modular
    candidate is accepted only after the complete finite-field map identity
    and degree check performed by the existing recovery routines.

    The padded coefficient vector is normalized projectively at one common
    nonzero coordinate, combined entrywise by CRT, and rationally
    reconstructed.  A characteristic-zero lift is returned only after the
    complete elliptic identity and map degree certify over QQ.  Partial state
    is resumable through ``initial_state``.
    """
    F = source_polynomial
    E = target_curve
    degree = ZZ(cover_degree)
    polynomial_ring = F.parent()
    if F.base_ring() is not QQ or E.base_ring() is not QQ:
        raise NotImplementedError(
            "CRT coefficient discovery currently requires rational input"
        )
    if map_type not in ("rational", "general"):
        raise ValueError("map_type must be 'rational' or 'general'")
    expected_bound_count = 2 if map_type == "rational" else 3
    if len(degree_bounds) != expected_bound_count:
        raise ValueError(
            f"{map_type} coefficient lifting needs "
            f"{expected_bound_count} degree bounds"
        )
    bounds = tuple(ZZ(value) for value in degree_bounds)
    if min(bounds) < 0:
        raise ValueError("degree bounds must be nonnegative")
    coefficient_count = sum(bound+1 for bound in bounds)
    if map_type == "general":
        if source_point is not None:
            raise NotImplementedError(
                "general coefficient lifting currently expands at infinity"
            )
        if target_center is not None and not target_center.is_zero():
            raise NotImplementedError(
                "general coefficient lifting currently requires the "
                "elliptic origin as target center"
            )
    if precision is None:
        precision = max(32, 6*degree+20)
    precision = ZZ(precision)

    if initial_state is None:
        modulus = ZZ(1)
        coefficient_residues = [ZZ(0)]*coefficient_count
        pivot_index = None
        certificates = []
        failures = []
    else:
        if initial_state.get("map_type") != map_type:
            raise ValueError("initial state has a different map type")
        if tuple(initial_state.get("degree_bounds", ())) != bounds:
            raise ValueError("initial state has different degree bounds")
        modulus = ZZ(initial_state["crt_modulus"])
        coefficient_residues = [
            ZZ(value) % modulus
            for value in initial_state["coefficient_residues"]
        ]
        if len(coefficient_residues) != coefficient_count:
            raise ValueError(
                "initial state has the wrong coefficient-vector length"
            )
        pivot_index = ZZ(initial_state["pivot_index"])
        certificates = list(initial_state.get("certificates", []))
        failures = list(initial_state.get("failures", []))
        if modulus <= 0:
            raise ValueError("initial CRT modulus must be positive")

    for prime in primes:
        prime = ZZ(prime)
        if not prime.is_prime():
            raise ValueError(f"{prime} is not prime")
        if prime <= precision:
            raise ValueError(
                f"prime {prime} must exceed precision {precision}"
            )
        if gcd(modulus, prime) != 1:
            raise ValueError(
                f"prime {prime} already divides the CRT modulus"
            )
        finite_field = GF(prime)
        finite_ring = PolynomialRing(
            finite_field,
            names=(str(polynomial_ring.gen()),),
        )
        try:
            finite_source = finite_ring(F)
        except (ArithmeticError, TypeError, ValueError, ZeroDivisionError):
            failures.append({
                "prime": prime,
                "reason": "source coefficients have bad reduction",
            })
            continue
        if finite_source.discriminant() == 0:
            failures.append({
                "prime": prime,
                "reason": "source has bad reduction",
            })
            continue
        try:
            finite_target = E.change_ring(finite_field)
        except (ArithmeticError, TypeError, ValueError, ZeroDivisionError):
            failures.append({
                "prime": prime,
                "reason": "target has bad reduction",
            })
            continue
        if finite_target.discriminant() == 0:
            failures.append({
                "prime": prime,
                "reason": "target has bad reduction",
            })
            continue
        try:
            finite_eigenform = _change_rational_function_ring(
                polynomial_ring.fraction_field()(eigenform),
                finite_ring,
            )
            finite_scale = finite_field(differential_scale)
            if target_center is None or target_center.is_zero():
                finite_center = finite_target(0)
            else:
                finite_center = finite_target(
                    finite_field(target_center[0]),
                    finite_field(target_center[1]),
                )
            if map_type == "rational":
                finite_answer = recover_elliptic_cover(
                    finite_source,
                    finite_target,
                    finite_eigenform,
                    finite_scale,
                    cover_degree=degree,
                    degree_bounds=bounds,
                    source_point=(
                        None
                        if source_point is None
                        else (
                            finite_field(source_point[0]),
                            finite_field(source_point[1]),
                        )
                    ),
                    infinity_branch=infinity_branch,
                    target_center=finite_center,
                    precision=precision,
                )
            else:
                finite_answer = recover_general_elliptic_cover(
                    finite_source,
                    finite_target,
                    finite_eigenform,
                    finite_scale,
                    degree,
                    bounds,
                    infinity_branch=infinity_branch,
                    precision=precision,
                )
            raw_vector = _map_coefficient_vector(
                finite_answer["x_coordinate"],
                bounds,
                finite_ring,
                map_type,
            )
            normalized_vector, used_pivot = (
                _normalize_projective_vector(
                    raw_vector,
                    pivot_index=pivot_index,
                )
            )
        except (
            ArithmeticError,
            TypeError,
            ValueError,
            ZeroDivisionError,
        ) as error:
            failures.append({
                "prime": prime,
                "reason": str(error),
            })
            continue

        if pivot_index is None:
            pivot_index = used_pivot
        coefficient_residues = [
            CRT(
                coefficient_residues[index],
                ZZ(normalized_vector[index]),
                modulus,
                prime,
            )
            for index in range(coefficient_count)
        ]
        modulus *= prime
        certificates.append({
            "prime": prime,
            "pivot_index": pivot_index,
            "coefficient_residues": [
                ZZ(value) for value in normalized_vector
            ],
        })

        try:
            rational_coefficients = [
                QQ(residue.rational_reconstruction(modulus))
                for residue in coefficient_residues
            ]
            candidate = _map_from_coefficient_vector(
                rational_coefficients,
                bounds,
                polynomial_ring,
                map_type,
            )
            if map_type == "rational":
                residual = elliptic_cover_identity(
                    F,
                    E,
                    eigenform,
                    differential_scale,
                    candidate,
                )
                actual_degree = rational_function_degree(candidate)
                if residual != 0 or actual_degree != degree:
                    continue
                y_multiplier, y_offset = elliptic_cover_y_data(
                    E,
                    eigenform,
                    differential_scale,
                    candidate,
                )
                map_answer = {
                    "verified": True,
                    "x_coordinate": candidate,
                    "y_multiplier": y_multiplier,
                    "y_offset": y_offset,
                    "identity_residual": residual,
                    "degree": actual_degree,
                    "degree_bounds": bounds,
                    "target_center": (
                        E(0) if target_center is None else target_center
                    ),
                    "differential_scale": QQ(differential_scale),
                }
            else:
                residual = general_elliptic_cover_identity(
                    F,
                    E,
                    eigenform,
                    differential_scale,
                    candidate,
                )
                actual_degree = general_x_coordinate_degree(F, candidate)
                if (
                    not _quadratic_function_is_zero(residual)
                    or actual_degree != 2*degree
                ):
                    continue
                map_answer = {
                    "verified": True,
                    "x_coordinate": candidate,
                    "y_coordinate": general_elliptic_cover_y_coordinate(
                        F,
                        E,
                        eigenform,
                        differential_scale,
                        candidate,
                    ),
                    "identity_residual": residual,
                    "x_coordinate_degree": actual_degree,
                    "cover_degree": degree,
                    "degree_bounds": bounds,
                    "target_center": E(0),
                    "differential_scale": QQ(differential_scale),
                }
        except (
            ArithmeticError,
            TypeError,
            ValueError,
            ZeroDivisionError,
        ):
            continue

        return {
            "verified": True,
            "map": map_answer,
            "map_type": map_type,
            "degree_bounds": bounds,
            "pivot_index": pivot_index,
            "coefficients": rational_coefficients,
            "crt_modulus": modulus,
            "coefficient_residues": coefficient_residues,
            "certificates": certificates,
            "failures": failures,
        }

    partial = {
        "verified": False,
        "map": None,
        "map_type": map_type,
        "degree_bounds": bounds,
        "pivot_index": pivot_index,
        "coefficients": None,
        "crt_modulus": modulus,
        "coefficient_residues": coefficient_residues,
        "certificates": certificates,
        "failures": failures,
    }
    if allow_partial:
        return partial
    raise ValueError(
        "no rational map coefficient vector reconstructed from supplied "
        f"primes; CRT modulus={modulus}"
    )


def recover_elliptic_cover(
    source_polynomial,
    target_curve,
    eigenform,
    differential_scale,
    cover_degree=None,
    degree_bounds=None,
    source_point=None,
    infinity_branch=1,
    target_center=None,
    precision=None,
):
    """
    Recover and certify a map from y^2=F(x) to an elliptic curve.

    Exactly one of ``cover_degree`` and ``degree_bounds`` should normally be
    supplied.  Explicit bounds may be a single pair ``(deg A, deg B)`` or a
    list of such pairs.
    """
    F = source_polynomial
    polynomial_ring = F.parent()
    base_field = polynomial_ring.base_ring()
    E = target_curve
    if E.base_ring() != base_field:
        raise ValueError("source and target must have the same base field")
    if F.degree() not in (5, 6):
        raise NotImplementedError(
            "the current implementation is specialized to genus 2"
        )
    if not F.is_squarefree():
        raise ValueError("source_polynomial must be squarefree")
    if cover_degree is None and degree_bounds is None:
        raise ValueError("supply cover_degree or degree_bounds")
    normalized_bounds = _normalize_degree_bounds(degree_bounds)

    if precision is None:
        degree_for_precision = (
            ZZ(cover_degree)
            if cover_degree is not None
            else max(max(pair) for pair in normalized_bounds)
        )
        precision = max(32, 6*degree_for_precision+20)
    precision = ZZ(precision)

    local_data = hyperelliptic_local_data(
        F,
        precision,
        source_point=source_point,
        infinity_branch=infinity_branch,
    )
    integral = integrate_eigenform(F, eigenform, local_data)
    logarithm_series = base_field(differential_scale)*integral
    target_x_series, center = elliptic_target_x_series(
        E,
        logarithm_series,
        precision,
        target_center=target_center,
    )

    if normalized_bounds is None:
        candidates = _degree_bound_candidates(
            cover_degree,
            local_data,
            target_x_series,
        )
    else:
        candidates = normalized_bounds

    failures = []
    recovered = []
    for numerator_degree, denominator_degree in candidates:
        try:
            X = rational_reconstruct_from_series(
                local_data["x"],
                target_x_series,
                numerator_degree,
                denominator_degree,
                polynomial_ring,
            )
        except (ArithmeticError, ValueError, ZeroDivisionError) as error:
            failures.append(
                {
                    "bounds": (
                        int(numerator_degree),
                        int(denominator_degree),
                    ),
                    "reason": str(error),
                }
            )
            continue

        residual = elliptic_cover_identity(
            F,
            E,
            eigenform,
            differential_scale,
            X,
        )
        actual_degree = rational_function_degree(X)
        expected_degree = (
            ZZ(cover_degree)
            if cover_degree is not None
            else max(numerator_degree, denominator_degree)
        )
        if residual != 0 or actual_degree != expected_degree:
            failures.append(
                {
                    "bounds": (
                        int(numerator_degree),
                        int(denominator_degree),
                    ),
                    "reason": (
                        "exact identity failed"
                        if residual != 0
                        else f"recovered degree {actual_degree}"
                    ),
                }
            )
            continue
        recovered.append(
            (
                X,
                (numerator_degree, denominator_degree),
            )
        )

    unique = {}
    for X, bounds in recovered:
        unique[str(X)] = (X, bounds)
    if len(unique) != 1:
        raise ValueError(
            "expected one certified reconstruction, found "
            f"{len(unique)}; failures={failures}"
        )

    X, used_bounds = next(iter(unique.values()))
    y_multiplier, y_offset = elliptic_cover_y_data(
        E,
        eigenform,
        differential_scale,
        X,
    )
    return {
        "verified": True,
        "source_polynomial": F,
        "target_curve": E,
        "eigenform": polynomial_ring.fraction_field()(eigenform),
        "differential_scale": base_field(differential_scale),
        "source_center": local_data["label"],
        "target_center": center,
        "precision": precision,
        "degree_bounds": tuple(ZZ(value) for value in used_bounds),
        "degree": rational_function_degree(X),
        "x_coordinate": X,
        "y_multiplier": y_multiplier,
        "y_offset": y_offset,
        "identity_residual": elliptic_cover_identity(
            F,
            E,
            eigenform,
            differential_scale,
            X,
        ),
        "failed_candidates": failures,
    }
