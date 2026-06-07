/*
Independent degree-19 Frey-Kani anti-isometry certificate.
*/

Q := Integers();
n := 19;
F := GF(11743);
E1 := EllipticCurve([F | 0, 0, 0, 8444, 6205]);
E2 := EllipticCurve([F | 0, 0, 0, 4036, 11557]);

assert #E1 eq 11552;
assert #E2 eq 11913;
assert Invariants(AbelianGroup(E1)) eq [19, 608];
assert Invariants(AbelianGroup(E2)) eq [19, 627];

P1 := E1![2689, 8983, 1];
P2 := E1![6025, 7701, 1];
Q1 := E2![7067, 8512, 1];
Q2 := E2![1751, 5524, 1];
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
assert compatible_determinants eq [16];

R := Integers(n);
anti_isometry_matrix := Matrix(R, 2, 2, [1, 0, 0, 16]);
assert Determinant(anti_isometry_matrix) eq R!16;
psiP1 := Q1;
psiP2 := 16*Q2;
assert pairing1*WeilPairing(psiP1, psiP2, n) eq 1;

graph := {
    <a*P1+b*P2, a*psiP1+b*psiP2>
    : a, b in [0..n-1]
};
assert #graph eq n^2;

anti_isometry_count := 0;
for a, b, c, d in [0..n-1] do
    matrix_value := Matrix(R, 2, 2, [a, b, c, d]);
    if Determinant(matrix_value) eq R!16 then
        anti_isometry_count +:= 1;
    end if;
end for;
assert anti_isometry_count eq n*(n^2-1);

trace1 := #F+1-#E1;
trace2 := #F+1-#E2;
assert trace1 eq 192;
assert trace2 eq -169;
assert trace1^2-4*#F eq -38^2*7;
assert trace2^2-4*#F eq -19^2*51;
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
print "CM_SQUARECLASSES", -7, -51;
print "WEIL_POLYNOMIAL", weil_polynomial;
print "B020_DEGREE19_ANTI_ISOMETRY_VERIFIED";
quit;
