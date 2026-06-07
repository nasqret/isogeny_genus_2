Q := Rationals();
P<x> := PolynomialRing(Q);
F := FieldOfFractions(P);

source_polynomial :=
    x^6
    - 6*x^5
    + 7*x^4
    + 28/9*x^3
    - 16/3*x^2
    - 16/9*x
    + 16/81;
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;

E1 := EllipticCurve([Q | 0, 0, 0, -27, 90]);
E2 := EllipticCurve([Q | 0, 0, 0, 81, -162]);

// First quotient: X is fixed by the hyperelliptic involution.
c1 := -1;
X1 := F!(
    (
        3*x^6
        - 30*x^5
        + 81*x^4
        - 296/3*x^3
        + 184/3*x^2
        - 848/27
    )
    /
    (
        x^6
        - 6*x^5
        + 9*x^4
        + 40/9*x^3
        - 40/3*x^2
        + 400/81
    )
);
Y1_multiplier := Derivative(X1)/(2*c1*x);
assert F!source_polynomial*Derivative(X1)^2 eq
    4*c1^2*x^2*(X1^3 - 27*X1 + 90);

X1K :=
    Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1_multiplier_K :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
Y1K := y*Y1_multiplier_K;
assert Y1K^2 eq X1K^3 - 27*X1K + 90;
map1 := map< C -> E1 | [X1K, Y1K, K!1] >;

// Complement: X=a(x)+y*b(x), recovered by finite-field scale discovery.
c2 := 2/3;
D2 :=
    x^8
    + 4*x^7
    + 63/10*x^6
    + 221/45*x^5
    + 6841/3600*x^4
    + 121/450*x^3
    - 109/4050*x^2
    - 14/2025*x
    + 1/2025;
A2 :=
    9/2*x^12
    - 693/20*x^10
    - 533/10*x^9
    + 2061/400*x^8
    + 6501/100*x^7
    + 7097/150*x^6
    + 221/50*x^5
    - 10621/1200*x^4
    - 17029/4050*x^3
    - 289/450*x^2
    + 22/2025*x
    + 161/18225;
B2 :=
    9/2*x^9
    + 27/2*x^8
    + 207/20*x^7
    - 9/4*x^6
    - 33/5*x^5
    - 7/2*x^4
    - 16/15*x^3
    - 1/3*x^2
    - 4/45*x
    - 4/405;
a2 := F!(A2/D2);
b2 := F!(B2/D2);

// From dX/(2Y)=c2*dx/y and y^2=source_polynomial.
Y2_rational := F!(
    (
        source_polynomial*Derivative(b2)
        + b2*Derivative(source_polynomial)/2
    )
    /
    (2*c2)
);
Y2_y_part := F!(Derivative(a2)/(2*c2));

a2K := Evaluate(Numerator(a2), t)/Evaluate(Denominator(a2), t);
b2K := Evaluate(Numerator(b2), t)/Evaluate(Denominator(b2), t);
Y2_rational_K :=
    Evaluate(Numerator(Y2_rational), t)
    / Evaluate(Denominator(Y2_rational), t);
Y2_y_part_K :=
    Evaluate(Numerator(Y2_y_part), t)
    / Evaluate(Denominator(Y2_y_part), t);
X2K := a2K+y*b2K;
Y2K := Y2_rational_K+y*Y2_y_part_K;
assert Y2K^2 eq X2K^3 + 81*X2K - 162;
map2 := map< C -> E2 | [X2K, Y2K, K!1] >;

degree1 := Degree(map1);
degree2 := Degree(map2);
assert degree1 eq 6;
assert degree2 eq 6;

print "B004_B010_B012_DEGREE6_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
quit;
