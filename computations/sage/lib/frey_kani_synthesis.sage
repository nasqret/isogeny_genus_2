"""
Finite-field certificates for prime-degree Frey-Kani synthesis.

For elliptic curves with rational full n-torsion, a matrix between chosen
torsion bases is an anti-isometry exactly when its determinant has the unique
value that inverts the two basis Weil pairings.
"""


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
