/*
S7 monodromy and quadratic-disjointness certificate for the compact
degree-7 quotient used by the full Galois-complement engine.
*/

Q := Rationals();
KT<T> := FunctionField(Q);
P<x> := PolynomialRing(KT);

N :=
    576/2401*x^7
    + 99360/343*x^5
    + 298080/343*x^4
    + 17702985/343*x^3
    + 337608858/343*x^2
    - 38850529695/1372*x
    + 3538907916225/9604;
D :=
    x^3
    - 46/5*x^2
    + 3013/4*x
    - 25645/4;
fiber := N-T*D;
assert IsIrreducible(fiber);

target_cubic :=
    T^3
    - 7876003275*T
    - 272222678576250;
fiber_discriminant := Discriminant(fiber);
assert fiber_discriminant eq
    828157741498368/117649*target_cubic^3;
discriminant_square_class := 2*target_cubic;
assert IsSquare(KT!(
    fiber_discriminant/discriminant_square_class
));
assert not IsSquare(KT!(
    target_cubic/discriminant_square_class
));

G, roots, root_map := GaloisGroup(fiber);
assert #G eq Factorial(7);
assert GroupName(G) eq "S7";
assert #DerivedGroup(G) eq Factorial(7) div 2;

// The unique quadratic subfield of the S7 closure has square class
// 2*target_cubic.  The elliptic base adjoins sqrt(target_cubic), so the
// two quadratic extensions are distinct and the base-changed group is S7.
print "B011_DEGREE7_MONODROMY_VERIFIED";
print "rational_map_group", GroupName(G);
print "rational_map_order", #G;
print "elliptic_base_group", "S7";
print "discriminant_square_class", "2*target_cubic";
quit;
