/*
Independent degree-29 Frey-Kani anti-isometry certificate.
*/

Q := Integers();
n := 29;
F := GF(50867);
E1 := EllipticCurve([F | 0, 0, 0, 18068, 28770]);
E2 := EllipticCurve([F | 0, 0, 0, 16732, 29860]);

assert #E1 eq 50460;
assert #E2 eq 51301;
assert Invariants(AbelianGroup(E1)) eq [29, 1740];
assert Invariants(AbelianGroup(E2)) eq [29, 1769];

P1 := E1![24954, 13946, 1];
P2 := E1![40497, 37256, 1];
Q1 := E2![45037, 16292, 1];
Q2 := E2![32423, 11221, 1];
assert Order(P1) eq n;
assert Order(P2) eq n;
assert Order(Q1) eq n;
assert Order(Q2) eq n;
assert IsLinearlyIndependent(P1, P2, n);
assert IsLinearlyIndependent(Q1, Q2, n);

pairing1 := WeilPairing(P1, P2, n);
pairing2 := WeilPairing(Q1, Q2, n);
compatible_determinants := [
    d : d in [1..n-1] | pairing1*pairing2^d eq 1
];
assert compatible_determinants eq [24];

R := Integers(n);
anti_isometry_matrix := Matrix(R, 2, 2, [1, 0, 0, 24]);
assert Determinant(anti_isometry_matrix) eq R!24;
psiP1 := Q1;
psiP2 := 24*Q2;
assert pairing1*WeilPairing(psiP1, psiP2, n) eq 1;

graph := {
    <a*P1+b*P2, a*psiP1+b*psiP2>
    : a, b in [0..n-1]
};
assert #graph eq n^2;

anti_isometry_count := 0;
for a, b, c, d in [0..n-1] do
    matrix_value := Matrix(R, 2, 2, [a, b, c, d]);
    if Determinant(matrix_value) eq R!24 then
        anti_isometry_count +:= 1;
    end if;
end for;
assert anti_isometry_count eq n*(n^2-1);

trace1 := #F+1-#E1;
trace2 := #F+1-#E2;
assert trace1 eq 408;
assert trace2 eq -433;
assert trace1^2-4*#F eq -58^2*11;
assert trace2^2-4*#F eq -29^2*19;
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
print "CM_SQUARECLASSES", -11, -19;
print "WEIL_POLYNOMIAL", weil_polynomial;
print "B024_DEGREE29_ANTI_ISOMETRY_VERIFIED";
quit;
