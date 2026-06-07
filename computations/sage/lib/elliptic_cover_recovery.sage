"""
Degree-independent recovery of hyperelliptic-to-elliptic maps.

The main entry point is ``recover_elliptic_cover``.  It reconstructs the
elliptic X-coordinate from:

* a hyperelliptic model y^2 = F(x);
* an elliptic target E;
* a pulled-back invariant differential c*h(x)*dx/y;
* a source expansion point and its image on E;
* the degree of the cover, or explicit numerator/denominator bounds.

All arithmetic is exact.  A returned candidate is accepted only after the
identity induced by the invariant differential and the elliptic equation is
verified in the rational function field of the source.
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
    if base_field.characteristic() != 0:
        raise NotImplementedError(
            "formal integration currently requires characteristic zero"
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
