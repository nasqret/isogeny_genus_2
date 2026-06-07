/*
Independent degree-23 Frey-Kani anti-isometry certificate.
*/

Q := Integers();
n := 23;
F := GF(21943);
E1 := EllipticCurve([F | 0, 0, 0, 18008, 21189]);
E2 := EllipticCurve([F | 0, 0, 0, 6198, 5070]);

assert #E1 eq 21689;
assert #E2 eq 22218;
assert Invariants(AbelianGroup(E1)) eq [23, 943];
assert Invariants(AbelianGroup(E2)) eq [23, 966];

P1 := E1![95, 1862, 1];
P2 := E1![18951, 3611, 1];
Q1 := E2![1554, 11740, 1];
Q2 := E2![1716, 21748, 1];
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
assert compatible_determinants eq [1];

R := Integers(n);
anti_isometry_matrix := IdentityMatrix(R, 2);
psiP1 := Q1;
psiP2 := Q2;
assert pairing1*WeilPairing(psiP1, psiP2, n) eq 1;

graph := {
    <a*P1+b*P2, a*psiP1+b*psiP2>
    : a, b in [0..n-1]
};
assert #graph eq n^2;

anti_isometry_count := 0;
for a, b, c, d in [0..n-1] do
    matrix_value := Matrix(R, 2, 2, [a, b, c, d]);
    if Determinant(matrix_value) eq R!1 then
        anti_isometry_count +:= 1;
    end if;
end for;
assert anti_isometry_count eq n*(n^2-1);

trace1 := #F+1-#E1;
trace2 := #F+1-#E2;
assert trace1 eq 255;
assert trace2 eq -274;
assert trace1^2-4*#F eq -23^2*43;
assert trace2^2-4*#F eq -46^2*6;
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
print "CM_SQUARECLASSES", -43, -6;
print "WEIL_POLYNOMIAL", weil_polynomial;
print "B021_DEGREE23_ANTI_ISOMETRY_VERIFIED";
quit;
