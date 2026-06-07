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
