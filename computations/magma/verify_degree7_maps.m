Q := Rationals();
P<x> := PolynomialRing(Q);
F := FieldOfFractions(P);

F1 := x^3 + 23*x^2 + 552*x + 17940;
F2 := x^3 - 46/5*x^2 + 3013/4*x - 25645/4;
source_polynomial := F1*F2;
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;

E1 := EllipticCurve([
    Q | 0, 0, 0, -7876003275, -272222678576250
]);
E2 := EllipticCurve([
    Q | 0, 0, 0, -20353275, 35382561750
]);

c1 := 49/12;
A1 :=
    x^7
    + 2415/2*x^5
    + 7245/2*x^4
    + 41306965/192*x^3
    + 393877001/96*x^2
    - 90651235955/768*x
    + 1179635972075/768;
B1 := F2;
X1 := F!(576/2401*A1/B1);
Y1_multiplier := Derivative(X1)/(2*c1);

c2 := -49/60;
quadratic_pole_factor := x^2 - 115/24*x + 7475/24;
A2 :=
    10465/4*x^7
    + 197225/8*x^6
    + 164727955/64*x^5
    + 1305770375/64*x^4
    + 36305600625/64*x^3
    - 1306013384375/64*x^2
    - 232046932796875/16;
B2 := F1*quadratic_pole_factor^2;
X2 := F!(A2/B2);
Y2_multiplier := Derivative(X2)/(2*c2*x);

assert F!source_polynomial*Derivative(X1)^2 eq
    4*c1^2*(X1^3 - 7876003275*X1 - 272222678576250);
assert F!source_polynomial*Derivative(X2)^2 eq
    4*c2^2*x^2*(X2^3 - 20353275*X2 + 35382561750);

X1K :=
    Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1_multiplier_K :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
X2K :=
    Evaluate(Numerator(X2), t)/Evaluate(Denominator(X2), t);
Y2_multiplier_K :=
    Evaluate(Numerator(Y2_multiplier), t)
    / Evaluate(Denominator(Y2_multiplier), t);

map1 := map< C -> E1 |
    [X1K, y*Y1_multiplier_K, K!1]
>;
map2 := map< C -> E2 |
    [X2K, y*Y2_multiplier_K, K!1]
>;

degree1 := Degree(map1);
degree2 := Degree(map2);
assert degree1 eq 7;
assert degree2 eq 7;

print "B008_B010_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
quit;
