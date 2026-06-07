/*
Independent degree-17 Frey-Kani anti-isometry certificate.
*/

Q := Integers();
n := 17;
F := GF(8263);
E1 := EllipticCurve([F | 0, 0, 0, 0, 1728]);
E2 := EllipticCurve([F | 0, 0, 0, 6442, 3171]);

assert #E1 eq 8092;
assert #E2 eq 8381;
assert Invariants(AbelianGroup(E1)) eq [34, 238];
assert Invariants(AbelianGroup(E2)) eq [17, 493];

P1 := E1![3198, 717, 1];
P2 := E1![1807, 564, 1];
Q1 := E2![7342, 3211, 1];
Q2 := E2![4793, 6460, 1];
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
assert compatible_determinants eq [6];

R := Integers(n);
anti_isometry_matrix := Matrix(R, 2, 2, [1, 0, 0, 6]);
assert Determinant(anti_isometry_matrix) eq R!6;
psiP1 := Q1;
psiP2 := 6*Q2;
assert pairing1*WeilPairing(psiP1, psiP2, n) eq 1;

graph := {
    <a*P1+b*P2, a*psiP1+b*psiP2>
    : a, b in [0..n-1]
};
assert #graph eq n^2;

anti_isometry_count := 0;
for a, b, c, d in [0..n-1] do
    matrix_value := Matrix(R, 2, 2, [a, b, c, d]);
    if Determinant(matrix_value) eq R!6 then
        anti_isometry_count +:= 1;
    end if;
end for;
assert anti_isometry_count eq n*(n^2-1);

trace1 := #F+1-#E1;
trace2 := #F+1-#E2;
assert trace1 eq 172;
assert trace2 eq -117;
assert trace1^2-4*#F eq -34^2*3;
assert trace2^2-4*#F eq -17^2*67;
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
print "CM_SQUARECLASSES", -3, -67;
print "WEIL_POLYNOMIAL", weil_polynomial;
print "B019_DEGREE17_ANTI_ISOMETRY_VERIFIED";
quit;
