Q := Rationals();
P<x> := PolynomialRing(Q);

F :=
    x^6
    + 19/5*x^5
    + 42/5*x^4
    + 309/20*x^3
    + 63/4*x^2
    + 15*x
    + 25/4;

X := HyperellipticCurve(F);
Eprime := EllipticCurve([Q | 0, 0, 0, 25, 375]);
K := FunctionField(X);
t := K.1;
y := K.2;

den := t^3 + 4/5*t^2 + 2*t + 5/4;
zprime := (-6*t^3 - 6*t^2 - 35/4*t + 25/4)/den;
wprime :=
    (-3*t^3 + 55/2*t^2 + 25/2*t + 125/8)
    / den^2;

pi_prime := map< X -> Eprime | [zprime, y*wprime, 1] >;
degree := Degree(pi_prime);

assert degree eq 3;
assert jInvariant(Eprime) eq 6912/247;

print "C019_VERIFIED";
print "degree", degree;
print "j_invariant", jInvariant(Eprime);
quit;
