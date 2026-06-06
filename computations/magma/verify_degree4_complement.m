Q := Rationals();
P2<U, V, W> := ProjectiveSpace(Q, 2);

self_fiber :=
    U^3 + U^2*V + U*V^2 + V^3
    - 8*(U + V)*W^2
    + 16*W^3;

D := Curve(P2, self_fiber);
assert IsNonsingular(D);
assert Genus(D) eq 1;

point_at_infinity := D![1, -1, 0];
E, birational_map := EllipticCurve(D, point_at_infinity);
target := EllipticCurve([Q | 0, 0, 0, -432, -8208]);

assert IsIsomorphic(E, target);
assert jInvariant(E) eq jInvariant(target);

print "C022_MAGMA_VERIFIED";
print "genus", Genus(D);
print "j_invariant", jInvariant(target);
quit;
