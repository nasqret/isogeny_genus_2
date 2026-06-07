"""
Discover elliptic targets and eigenforms for split genus-2 Jacobians.

This layer is designed for explicit Hilbert-modular families where candidate
j-invariants are known but the rational twists, eigenform lines, scales,
centers, and maps are not.

Target twists are filtered by exact Frobenius-factor compatibility.  The
remaining candidates are passed to the exact map-recovery library, so finite
Euler evidence is discovery data rather than the final proof.
"""


def source_frobenius_trace_pairs(
    source_polynomial,
    prime_bound,
    prime_start=5,
):
    """
    Return good primes where the genus-2 Frobenius polynomial splits.

    Each certificate stores the two elliptic traces, with multiplicity.
    """
    F = source_polynomial
    if F.base_ring() is not QQ:
        raise NotImplementedError(
            "Frobenius target discovery currently requires a rational source"
        )
    discriminant = QQ(F.discriminant())
    certificates = []
    for prime in prime_range(prime_start, prime_bound):
        if (
            discriminant.numerator() % prime == 0
            or discriminant.denominator() % prime == 0
        ):
            continue
        finite_curve = HyperellipticCurve(F.change_ring(GF(prime)))
        frobenius = finite_curve.frobenius_polynomial()
        traces = []
        for factor_polynomial, multiplicity in frobenius.factor():
            if (
                factor_polynomial.degree() != 2
                or factor_polynomial[2] != 1
                or factor_polynomial[0] != prime
            ):
                traces = []
                break
            traces.extend(
                [-ZZ(factor_polynomial[1])]*multiplicity
            )
        if len(traces) == 2:
            certificates.append(
                {
                    "prime": ZZ(prime),
                    "traces": tuple(sorted(traces)),
                    "frobenius_polynomial": frobenius,
                }
            )
    if not certificates:
        raise ValueError("no split good Frobenius polynomials were found")
    return certificates


def discriminant_supported_twist_classes(source_polynomial):
    """
    Enumerate signed squarefree classes supported on the source discriminant.

    Rational source models may have bad reduction at primes occurring in the
    denominator of the discriminant, so both numerator and denominator
    supports are required.
    """
    F = source_polynomial
    discriminant = QQ(F.discriminant())
    support = sorted(set(
        ZZ(prime)
        for value in (
            abs(discriminant.numerator()),
            discriminant.denominator(),
        )
        for prime, _ in factor(value)
    ))
    classes = []
    for mask in range(2^len(support)):
        value = ZZ(1)
        for index, prime in enumerate(support):
            if mask & (1 << index):
                value *= prime
        classes.extend([value, -value])
    return support, classes


def discover_target_twists_from_j(
    source_polynomial,
    j_invariants,
    prime_bound=80,
    prime_start=5,
    minimum_matching_primes=5,
):
    """
    Discover rational quadratic twists compatible with source Euler factors.

    The search is exhaustive among signed squarefree classes supported on the
    source discriminant.  Exact maps must still be constructed before a
    target is accepted as a factor in characteristic zero.
    """
    F = source_polynomial
    support, twist_classes = discriminant_supported_twist_classes(F)
    frobenius_data = source_frobenius_trace_pairs(
        F,
        prime_bound,
        prime_start=prime_start,
    )
    if len(frobenius_data) < minimum_matching_primes:
        raise ValueError("insufficient split Frobenius primes")

    targets = []
    for j_value in j_invariants:
        j_value = QQ(j_value)
        base_curve = EllipticCurve_from_j(j_value)
        compatible = []
        seen_models = set()
        for twist_class in twist_classes:
            curve = (
                base_curve
                .quadratic_twist(twist_class)
                .global_minimal_model()
            )
            model_key = tuple(curve.a_invariants())
            if model_key in seen_models:
                continue
            seen_models.add(model_key)

            trace_certificates = []
            is_compatible = True
            for certificate in frobenius_data:
                prime = certificate["prime"]
                if curve.discriminant() % prime == 0:
                    is_compatible = False
                    break
                trace = (
                    prime + 1
                    - curve.change_ring(GF(prime)).cardinality()
                )
                if trace not in certificate["traces"]:
                    is_compatible = False
                    break
                trace_certificates.append(
                    {
                        "prime": prime,
                        "trace": ZZ(trace),
                        "allowed_traces": certificate["traces"],
                    }
                )
            if is_compatible:
                compatible.append(
                    {
                        "j_invariant": j_value,
                        "twist_square_class": ZZ(twist_class),
                        "curve": curve,
                        "trace_certificates": trace_certificates,
                    }
                )

        if not compatible:
            raise ValueError(
                f"no discriminant-supported twist found for j={j_value}"
            )
        targets.append(
            {
                "j_invariant": j_value,
                "compatible_twists": compatible,
            }
        )

    return {
        "verified_search": True,
        "bad_prime_support": support,
        "twist_class_count": len(twist_classes),
        "frobenius_data": frobenius_data,
        "targets": targets,
    }


def projective_linear_eigenforms(polynomial_ring, height_bound):
    """
    Enumerate primitive lines [r:s] for (r+s*x) dx/y.

    Coordinate axes are tested before mixed lines because they occur
    frequently in normalized examples.
    """
    x = polynomial_ring.gen()
    height_bound = ZZ(height_bound)
    if height_bound < 1:
        raise ValueError("height_bound must be positive")

    pairs = []
    for r in range(-height_bound, height_bound+1):
        for s in range(-height_bound, height_bound+1):
            if r == 0 and s == 0:
                continue
            divisor = gcd(abs(ZZ(r)), abs(ZZ(s)))
            if divisor != 1:
                continue
            if r < 0 or (r == 0 and s < 0):
                continue
            pairs.append((ZZ(r), ZZ(s)))
    pairs.sort(
        key=lambda pair: (
            0 if pair[0]*pair[1] == 0 else 1,
            0 if pair == (1, 0) else 1,
            max(abs(pair[0]), abs(pair[1])),
            abs(pair[0])+abs(pair[1]),
            pair,
        )
    )
    return [
        {
            "coefficients": pair,
            "eigenform": polynomial_ring(pair[0]+pair[1]*x),
        }
        for pair in pairs
    ]


def _canonical_map_for_x_coordinate(maps):
    grouped = {}
    for answer in maps:
        grouped.setdefault(str(answer["x_coordinate"]), []).append(answer)
    canonical = []
    for candidates in grouped.values():
        positive = [
            answer
            for answer in candidates
            if answer["differential_scale"] > 0
        ]
        canonical.append(positive[0] if positive else candidates[0])
    return canonical


def discover_target_eigenform_and_map(
    source_polynomial,
    target_curve,
    cover_degree,
    eigenform_height_bound=1,
    mordell_weil_bound=None,
    symbolic_precision=None,
):
    """
    Search bounded eigenform lines and target centers, then certify a map.
    """
    F = source_polynomial
    E = target_curve
    polynomial_ring = F.parent()
    eigenforms = projective_linear_eigenforms(
        polynomial_ring,
        eigenform_height_bound,
    )
    eigenform_stages = [
        [
            data
            for data in eigenforms
            if data["coefficients"][0]*data["coefficients"][1] == 0
        ],
        [
            data
            for data in eigenforms
            if data["coefficients"][0]*data["coefficients"][1] != 0
        ],
    ]
    eigenform_stages = [stage for stage in eigenform_stages if stage]

    attempted = []
    finite_centers = None
    for eigenform_stage in eigenform_stages:
        for center in [E(0)]:
            for eigenform_data in eigenform_stage:
                try:
                    discovery = discover_elliptic_cover(
                        F,
                        E,
                        eigenform_data["eigenform"],
                        cover_degree,
                        target_centers=[center],
                        symbolic_precision=symbolic_precision,
                    )
                    maps = _canonical_map_for_x_coordinate(
                        discovery["maps"]
                    )
                except (
                    ArithmeticError,
                    ValueError,
                    ZeroDivisionError,
                ) as error:
                    attempted.append(
                        {
                            "center": center,
                            "eigenform_coefficients": (
                                eigenform_data["coefficients"]
                            ),
                            "success": False,
                            "reason": str(error),
                        }
                    )
                    continue
                attempted.append(
                    {
                        "center": center,
                        "eigenform_coefficients": (
                            eigenform_data["coefficients"]
                        ),
                        "success": True,
                    }
                )
                return {
                    "verified": True,
                    "target_curve": E,
                    "eigenform": eigenform_data["eigenform"],
                    "eigenform_coefficients": (
                        eigenform_data["coefficients"]
                    ),
                    "maps": maps,
                    "attempted": attempted,
                }

        if E.base_ring() is not QQ:
            break
        if finite_centers is None:
            center_bound = (
                ZZ(cover_degree)
                if mordell_weil_bound is None
                else ZZ(mordell_weil_bound)
            )
            finite_centers = [
                point
                for point in mordell_weil_center_candidates(
                    E,
                    center_bound,
                    priority_multiple=cover_degree,
                )
                if not point.is_zero()
            ]
        for center in finite_centers:
            for eigenform_data in eigenform_stage:
                try:
                    discovery = discover_elliptic_cover(
                        F,
                        E,
                        eigenform_data["eigenform"],
                        cover_degree,
                        target_centers=[center],
                        symbolic_precision=symbolic_precision,
                    )
                    maps = _canonical_map_for_x_coordinate(
                        discovery["maps"]
                    )
                except (
                    ArithmeticError,
                    ValueError,
                    ZeroDivisionError,
                ) as error:
                    attempted.append(
                        {
                            "center": center,
                            "eigenform_coefficients": (
                                eigenform_data["coefficients"]
                            ),
                            "success": False,
                            "reason": str(error),
                        }
                    )
                    continue
                attempted.append(
                    {
                        "center": center,
                        "eigenform_coefficients": (
                            eigenform_data["coefficients"]
                        ),
                        "success": True,
                    }
                )
                return {
                    "verified": True,
                    "target_curve": E,
                    "eigenform": eigenform_data["eigenform"],
                    "eigenform_coefficients": (
                        eigenform_data["coefficients"]
                    ),
                    "maps": maps,
                    "attempted": attempted,
                }

    if E.base_ring() is not QQ:
        raise ValueError(
            "no origin-centered map found; supply number-field centers"
        )

    raise ValueError(
        "no certified map found in the bounded eigenform/center search"
    )


def discover_covers_from_j_invariants(
    source_polynomial,
    j_invariants,
    cover_degree,
    prime_bound=80,
    eigenform_height_bound=1,
    mordell_weil_bound=None,
    symbolic_precision=None,
):
    """
    End-to-end discovery from candidate j-invariants to exact maps.
    """
    target_search = discover_target_twists_from_j(
        source_polynomial,
        j_invariants,
        prime_bound=prime_bound,
    )
    covers = []
    for target_data in target_search["targets"]:
        certified = []
        for twist_data in target_data["compatible_twists"]:
            short_curve = twist_data["curve"].short_weierstrass_model()
            try:
                map_data = discover_target_eigenform_and_map(
                    source_polynomial,
                    short_curve,
                    cover_degree,
                    eigenform_height_bound=eigenform_height_bound,
                    mordell_weil_bound=mordell_weil_bound,
                    symbolic_precision=symbolic_precision,
                )
            except (
                ArithmeticError,
                ValueError,
                ZeroDivisionError,
            ):
                continue
            certified.append(
                {
                    "twist_data": twist_data,
                    "short_curve": short_curve,
                    "map_data": map_data,
                }
            )
        if not certified:
            raise ValueError(
                "Euler-compatible twists produced no exact map for "
                f"j={target_data['j_invariant']}"
            )
        covers.extend(certified)
    return {
        "verified": True,
        "target_search": target_search,
        "covers": covers,
    }
