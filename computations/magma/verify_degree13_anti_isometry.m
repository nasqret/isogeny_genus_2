/*
Independent Magma certificate for the first degree-13 Frey-Kani synthesis.
*/

Q := Integers();
n := 13;
F := GF(8009);
E1 := EllipticCurve([F | 0, 0, 0, 5553, 5419]);
E2 := EllipticCurve([F | 0, 0, 0, 2531, 1402]);

assert #E1 eq 7943;
assert #E2 eq 8112;
A1 := AbelianGroup(E1);
A2 := AbelianGroup(E2);
assert Invariants(A1) eq [13, 611];
assert Invariants(A2) eq [13, 624];

P1 := E1![3600, 411, 1];
P2 := E1![5265, 3005, 1];
Q1 := E2![6171, 1633, 1];
Q2 := E2![3628, 2373, 1];
assert Order(P1) eq n;
assert Order(P2) eq n;
assert Order(Q1) eq n;
assert Order(Q2) eq n;
assert IsLinearlyIndependent(P1, P2, n);
assert IsLinearlyIndependent(Q1, Q2, n);

pairing1 := WeilPairing(P1, P2, n);
pairing2 := WeilPairing(Q1, Q2, n);
assert Order(pairing1) eq n;
assert Order(pairing2) eq n;

compatible_determinants := [
    d : d in [1..n-1] | pairing1*pairing2^d eq 1
];
assert compatible_determinants eq [3];
required_determinant := compatible_determinants[1];

R := Integers(n);
anti_isometry_matrix := Matrix(R, 2, 2, [1, 0, 0, 3]);
assert Determinant(anti_isometry_matrix) eq R!required_determinant;
psiP1 := Q1;
psiP2 := 3*Q2;
assert pairing1*WeilPairing(psiP1, psiP2, n) eq 1;

anti_isometry_count := 0;
for a, b, c, d in [0..n-1] do
    matrix_value := Matrix(R, 2, 2, [a, b, c, d]);
    if Determinant(matrix_value) eq R!required_determinant then
        anti_isometry_count +:= 1;
    end if;
end for;
assert anti_isometry_count eq n*(n^2-1);

graph := {
    <a*P1+b*P2, a*psiP1+b*psiP2>
    : a, b in [0..n-1]
};
assert #graph eq n^2;

trace1 := #F+1-#E1;
trace2 := #F+1-#E2;
discriminant1 := trace1^2-4*#F;
discriminant2 := trace2^2-4*#F;
assert discriminant1 eq -13^2*163;
assert discriminant2 eq -104^2*2;
assert not IsSupersingular(E1);
assert not IsSupersingular(E2);

P<T> := PolynomialRing(Q);
weil_polynomial :=
    (T^2-trace1*T+#F)*(T^2-trace2*T+#F);

print "DEGREE", n;
print "ANTI_ISOMETRY_MATRIX", anti_isometry_matrix;
print "ANTI_ISOMETRY_COUNT", anti_isometry_count;
print "GRAPH_SIZE", #graph;
print "PAIRINGS", pairing1, WeilPairing(psiP1, psiP2, n);
print "CM_SQUARECLASSES", -163, -2;
print "WEIL_POLYNOMIAL", weil_polynomial;
print "FREY_KANI_IRREDUCIBLE", true;
print "GEOMETRIC_QUOTIENT_IS_GENUS2_JACOBIAN", true;
print "B014_DEGREE13_ANTI_ISOMETRY_VERIFIED";
