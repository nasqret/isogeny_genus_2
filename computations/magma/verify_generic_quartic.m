Q := Rationals();

parameters := [
    <-8, 16>,
    <1, 1>,
    <2, 3>
];

for parameter in parameters do
    p := Q!parameter[1];
    q := Q!parameter[2];
    delta := 8*p^3 + 27*q^2;
    assert q*delta ne 0;

    R<x> := PolynomialRing(Q);
    g := x^4 + p*x^2 + q*x;

    // Compute both discriminants independently from their defining
    // polynomials, then verify the factorization used by the covering map.
    Rt<t> := PolynomialRing(R);
    divided_difference := (t^4 + p*t^2 + q*t - g) div (t - x);
    fiber_polynomial := R!Discriminant(divided_difference);

    Rz<z> := PolynomialRing(Q);
    Rzt<T> := PolynomialRing(Rz);
    critical_discriminant :=
        Rz!Discriminant(T^4 + p*T^2 + q*T - z);

    assert Evaluate(critical_discriminant, g)
        eq Derivative(g)^2*fiber_polynomial;
    assert fiber_polynomial eq -(
        16*x^6
        + 32*p*x^4
        + 40*q*x^3
        + 20*p^2*x^2
        + 36*p*q*x
        + 4*p^3
        + 27*q^2
    );

    assert Degree(fiber_polynomial) eq 6;
    assert Discriminant(fiber_polynomial)
        eq -2^29*q^2*delta^4;
    assert Discriminant(Derivative(g)) eq -16*delta;
    assert Discriminant(critical_discriminant)
        eq -2^16*q^2*delta^3;

    X := HyperellipticCurve(fiber_polynomial);
    assert Genus(X) eq 2;

    // The off-diagonal self-fiber product is a nonsingular plane cubic.
    P2<U, V, W> := ProjectiveSpace(Q, 2);
    self_fiber :=
        U^3 + U^2*V + U*V^2 + V^3
        + p*(U + V)*W^2
        + q*W^3;
    D := Curve(P2, self_fiber);
    assert IsNonsingular(D);
    assert Genus(D) eq 1;

    point_at_infinity := D![1, -1, 0];
    E, birational_map := EllipticCurve(D, point_at_infinity);
    expected_j := -1024*p^6/(q^2*delta);
    assert jInvariant(E) eq expected_j;

    print "SPECIALIZATION_VERIFIED", p, q;
    print "fiber_discriminant", Discriminant(fiber_polynomial);
    print "complement_j", jInvariant(E);
end for;

print "C008_C011_MAGMA_VERIFIED";
quit;
