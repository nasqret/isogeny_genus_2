function FullTorsionBasis(E, n)
    A, toE := AbelianGroup(E);
    invariants := Invariants(A);
    assert #invariants eq 2;
    assert IsDivisibleBy(invariants[1], n);
    assert IsDivisibleBy(invariants[2], n);

    P := toE((invariants[1] div n)*A.1);
    Q := toE((invariants[2] div n)*A.2);
    assert Order(P) eq n;
    assert Order(Q) eq n;
    assert IsLinearlyIndependent(P, Q, n);
    return P, Q, invariants;
end function;


function PullbackTorsionClass(phi, P, J)
    E := Codomain(phi);
    divisor_class := Pullback(
        phi,
        Divisor(P)-Divisor(E!0)
    );
    return JacobianPoint(J, divisor_class);
end function;


function GraphImageCoefficients(U, V1, V2, n)
    solutions := [];
    for a, b in [0..n-1] do
        if U+a*V1+b*V2 eq Parent(U)!0 then
            Append(~solutions, <a, b>);
        end if;
    end for;
    assert #solutions eq 1;
    return solutions[1][1], solutions[1][2];
end function;


function CertifySplittingKernel(phi1, phi2, n)
    C := Domain(phi1);
    assert Domain(phi2) eq C;
    E1 := Codomain(phi1);
    E2 := Codomain(phi2);
    assert Characteristic(BaseRing(C)) notin PrimeDivisors(n);

    J := Jacobian(C);
    P1, P2, invariants1 := FullTorsionBasis(E1, n);
    Q1, Q2, invariants2 := FullTorsionBasis(E2, n);

    U1 := PullbackTorsionClass(phi1, P1, J);
    U2 := PullbackTorsionClass(phi1, P2, J);
    V1 := PullbackTorsionClass(phi2, Q1, J);
    V2 := PullbackTorsionClass(phi2, Q2, J);

    assert Order(U1) eq n;
    assert Order(U2) eq n;
    assert Order(V1) eq n;
    assert Order(V2) eq n;

    m11, m12 := GraphImageCoefficients(U1, V1, V2, n);
    m21, m22 := GraphImageCoefficients(U2, V1, V2, n);
    residue_ring := Integers(n);
    graph_matrix := Matrix(
        residue_ring,
        2,
        2,
        [m11, m12, m21, m22]
    );
    assert IsUnit(Determinant(graph_matrix));

    psiP1 := m11*Q1+m12*Q2;
    psiP2 := m21*Q1+m22*Q2;
    assert U1+PullbackTorsionClass(phi2, psiP1, J) eq J!0;
    assert U2+PullbackTorsionClass(phi2, psiP2, J) eq J!0;

    pairing1 := WeilPairing(P1, P2, n);
    pairing2 := WeilPairing(psiP1, psiP2, n);
    assert pairing1 ne 1;
    assert pairing1*pairing2 eq 1;

    kernel_count := 0;
    for a, b, c, d in [0..n-1] do
        if a*U1+b*U2+c*V1+d*V2 eq J!0 then
            kernel_count +:= 1;
        end if;
    end for;
    assert kernel_count eq n^2;

    return graph_matrix, invariants1, invariants2,
        pairing1, pairing2, kernel_count;
end function;
