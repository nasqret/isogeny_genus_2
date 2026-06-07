"""
Finite-field certificates for prime-degree Frey-Kani synthesis.

For elliptic curves with rational full n-torsion, a matrix between chosen
torsion bases is an anti-isometry exactly when its determinant has the unique
value that inverts the two basis Weil pairings.
"""


def admissible_full_torsion_traces(prime, field_order):
    """
    Return Hasse traces compatible with full rational prime-torsion.

    If E[prime] is rational over F_q, then q is 1 modulo prime and
    prime^2 divides #E(F_q)=q+1-trace.
    """
    prime = ZZ(prime)
    field_order = ZZ(field_order)
    assert prime.is_prime()
    assert field_order.is_prime()
    assert field_order % prime == 1

    hasse_bound = ZZ(4*field_order).isqrt()
    modulus = prime^2
    minimum_multiplier = (
        (field_order + 1 - hasse_bound + modulus - 1)//modulus
    )
    maximum_multiplier = (
        field_order + 1 + hasse_bound
    )//modulus
    return [
        field_order + 1 - modulus*multiplier
        for multiplier in range(
            minimum_multiplier,
            maximum_multiplier + 1,
        )
        if abs(
            field_order + 1 - modulus*multiplier
        ) <= hasse_bound
    ]


def has_full_rational_prime_torsion(elliptic_curve, prime):
    """Test whether E(F_q) contains (Z/prime Z)^2."""
    prime = ZZ(prime)
    invariants = elliptic_curve.abelian_group().invariants()
    return (
        len(invariants) == 2
        and all(value % prime == 0 for value in invariants)
    )


def deterministic_prime_torsion_basis(elliptic_curve, prime):
    """Return a reproducible basis of full rational prime-torsion."""
    prime = ZZ(prime)
    assert has_full_rational_prime_torsion(
        elliptic_curve,
        prime,
    )
    finite_field = elliptic_curve.base_field()
    assert finite_field.is_prime_field()
    invariants = elliptic_curve.abelian_group().invariants()
    projector = ZZ(max(invariants)//prime)

    first = None
    for x_integer in range(finite_field.cardinality()):
        x_value = finite_field(x_integer)
        rhs = (
            x_value^3
            + elliptic_curve.a4()*x_value
            + elliptic_curve.a6()
        )
        if not rhs.is_square():
            continue
        y_value = rhs.sqrt()
        if ZZ(-y_value) < ZZ(y_value):
            y_value = -y_value
        point = projector*elliptic_curve(x_value, y_value)
        if point == elliptic_curve(0):
            continue
        assert point.order() == prime
        if first is None:
            first = point
            continue
        pairing = first.weil_pairing(point, prime)
        if pairing.multiplicative_order() == prime:
            return first, point

    raise ValueError("failed to find a rational prime-torsion basis")


def search_prime_frey_kani_curves(
    prime,
    field_order,
    curves_per_trace=1,
):
    """
    Search the prime-field j-line for full rational prime-torsion curves.

    Both the canonical model returned by EllipticCurve_from_j and its
    quadratic twist are tested. The output is grouped by Frobenius trace.
    """
    prime = ZZ(prime)
    field_order = ZZ(field_order)
    curves_per_trace = ZZ(curves_per_trace)
    assert curves_per_trace >= 1

    finite_field = GF(field_order)
    traces = admissible_full_torsion_traces(prime, field_order)
    target_orders = {
        field_order + 1 - trace: trace for trace in traces
    }
    answers = {trace: [] for trace in traces}
    seen_models = set()
    twist_parameter = finite_field.multiplicative_generator()
    assert not twist_parameter.is_square()

    for j_integer in range(field_order):
        curve = EllipticCurve_from_j(finite_field(j_integer))
        for model in (
            curve,
            curve.quadratic_twist(twist_parameter),
        ):
            model_key = (
                model.a4(),
                model.a6(),
                model.cardinality(),
            )
            if model_key in seen_models:
                continue
            seen_models.add(model_key)
            cardinality = model_key[2]
            if cardinality not in target_orders:
                continue
            trace = target_orders[cardinality]
            if len(answers[trace]) >= curves_per_trace:
                continue
            if not has_full_rational_prime_torsion(model, prime):
                continue
            answers[trace].append(
                {
                    "curve": model,
                    "j": model.j_invariant(),
                    "trace": trace,
                    "cardinality": cardinality,
                    "group_invariants": (
                        model.abelian_group().invariants()
                    ),
                    "torsion_basis": (
                        deterministic_prime_torsion_basis(
                            model,
                            prime,
                        )
                    ),
                    "cm_squareclass": ZZ(
                        trace^2 - 4*field_order
                    ).squarefree_part(),
                }
            )
        if all(
            len(entries) >= curves_per_trace
            for entries in answers.values()
        ):
            break

    return {
        "prime": prime,
        "field_order": field_order,
        "admissible_traces": traces,
        "curves_by_trace": answers,
        "complete": all(
            len(entries) >= curves_per_trace
            for entries in answers.values()
        ),
    }


def fixed_determinant_matrices(prime, determinant):
    """Enumerate GL(2,F_prime) matrices with the prescribed determinant."""
    field = GF(prime)
    determinant = field(determinant)
    assert determinant != 0

    matrices = []
    for a in field:
        for b in field:
            if a == 0 and b == 0:
                continue
            if a != 0:
                for parameter in field:
                    c = a*parameter
                    d = determinant/a + b*parameter
                    matrices.append(
                        matrix(field, 2, 2, [a, b, c, d])
                    )
            else:
                c = -determinant/b
                for d in field:
                    matrices.append(
                        matrix(field, 2, 2, [a, b, c, d])
                    )

    assert len(matrices) == prime*(prime^2 - 1)
    return matrices


def pairing_compatible_determinant(pairing1, pairing2, prime):
    """Find d with pairing1*pairing2^d=1."""
    solutions = [
        d
        for d in range(1, prime)
        if pairing1*pairing2^d == 1
    ]
    assert len(solutions) == 1
    return ZZ(solutions[0])


def apply_torsion_matrix(matrix_value, basis):
    """Apply a 2 by 2 residue matrix to a torsion basis."""
    P, Q = basis
    coefficients = [
        [ZZ(matrix_value[row, column]) for column in range(2)]
        for row in range(2)
    ]
    return (
        coefficients[0][0]*P + coefficients[0][1]*Q,
        coefficients[1][0]*P + coefficients[1][1]*Q,
    )


def certify_prime_frey_kani_graph(
    elliptic_curve_1,
    elliptic_curve_2,
    prime,
    basis_1,
    basis_2,
    anti_isometry_matrix,
):
    """
    Certify a prime-degree Frey-Kani graph and irreducibility criterion.

    The irreducibility conclusion uses the strong sufficient condition that
    the two ordinary elliptic curves have different geometric endomorphism
    fields, hence no nonzero geometric homomorphisms between them.
    """
    assert prime.is_prime()
    assert elliptic_curve_1.base_field() == elliptic_curve_2.base_field()
    finite_field = elliptic_curve_1.base_field()
    characteristic = finite_field.characteristic()
    assert characteristic != prime

    P1, P2 = basis_1
    Q1, Q2 = basis_2
    for point in (P1, P2, Q1, Q2):
        assert point.order() == prime

    pairing1 = P1.weil_pairing(P2, prime)
    pairing2 = Q1.weil_pairing(Q2, prime)
    assert pairing1.multiplicative_order() == prime
    assert pairing2.multiplicative_order() == prime

    required_determinant = pairing_compatible_determinant(
        pairing1, pairing2, prime
    )
    matrix_field = GF(prime)
    matrix_value = matrix(matrix_field, anti_isometry_matrix)
    assert matrix_value.det() == matrix_field(required_determinant)

    psiP1, psiP2 = apply_torsion_matrix(
        matrix_value, (Q1, Q2)
    )
    assert pairing1*psiP1.weil_pairing(psiP2, prime) == 1

    graph = {
        (
            a*P1 + b*P2,
            a*psiP1 + b*psiP2,
        )
        for a in range(prime)
        for b in range(prime)
    }
    assert len(graph) == prime^2

    matrices = fixed_determinant_matrices(
        prime, required_determinant
    )
    assert len(matrices) == prime*(prime^2 - 1)

    cardinality1 = elliptic_curve_1.cardinality()
    cardinality2 = elliptic_curve_2.cardinality()
    trace1 = characteristic + 1 - cardinality1
    trace2 = characteristic + 1 - cardinality2
    discriminant1 = trace1^2 - 4*characteristic
    discriminant2 = trace2^2 - 4*characteristic
    cm_squareclass1 = ZZ(discriminant1).squarefree_part()
    cm_squareclass2 = ZZ(discriminant2).squarefree_part()
    assert trace1 % characteristic != 0
    assert trace2 % characteristic != 0
    assert cm_squareclass1 != cm_squareclass2

    R.<T> = PolynomialRing(ZZ)
    weil_polynomial = (
        (T^2 - trace1*T + characteristic)
        * (T^2 - trace2*T + characteristic)
    )

    return {
        "required_determinant": required_determinant,
        "anti_isometry_count": len(matrices),
        "graph_size": len(graph),
        "pairing1": pairing1,
        "pairing2_after_map": psiP1.weil_pairing(psiP2, prime),
        "cardinalities": (cardinality1, cardinality2),
        "traces": (trace1, trace2),
        "cm_squareclasses": (cm_squareclass1, cm_squareclass2),
        "weil_polynomial": weil_polynomial,
        "geometrically_nonisogenous": True,
        "frey_kani_irreducible": True,
        "geometric_jacobian": True,
    }
