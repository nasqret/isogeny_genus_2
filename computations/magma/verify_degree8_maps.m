Q := Rationals();
P<x> := PolynomialRing(Q);
F := FieldOfFractions(P);

source_polynomial :=
    x^6
    + 8*x^4
    + 20*x^3
    + 68*x^2
    + 240*x
    + 396;
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;
AutC, aut_map, action := AutomorphismGroup(C);
assert #AutC eq 2;

E1 := EllipticCurve([Q | 0, -1, 0, -5833, 207037]);
E2 := EllipticCurve([Q | 0, -1, 0, 7, -3]);

// First quotient: X is fixed by the hyperelliptic involution.
c1 := 2;
X1 := F!(
    (
        x^8
        + 4*x^7
        + 12*x^6
        + 32*x^5
        + 87*x^4
        + 220*x^3
        + 444*x^2
        + 360*x
        - 8
    )
    /
    (
        x^4
        + 4*x^3
        + 8*x^2
        + 8*x
        + 4
    )
);
Y1_multiplier := Derivative(X1)/(2*c1);
assert F!source_polynomial*Derivative(X1)^2 eq
    4*c1^2*(X1^3 - X1^2 - 5833*X1 + 207037);

X1K :=
    Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1_multiplier_K :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
Y1K := y*Y1_multiplier_K;
assert Y1K^2 eq X1K^3 - X1K^2 - 5833*X1K + 207037;
map1 := map< C -> E1 | [X1K, Y1K, K!1] >;

// Complement: X=a(x)+y*b(x), recovered by finite-field CRT.
c2 := 2;
h2 := 1+2*x;
D2 :=
    x^14
    - 4357/6*x^13
    + 19073881/144*x^12
    - 2813911/12*x^11
    + 39147671/16*x^10
    - 3639411/4*x^9
    + 2204846577/64*x^8
    + 114019137/8*x^7
    + 2143443141/8*x^6
    + 1141792119/4*x^5
    + 1874926764*x^4
    + 2709574902*x^3
    + 7286423526*x^2
    + 6153417558*x
    + 7695324729;
A2 :=
    1/32*x^16
    - 545/24*x^15
    + 2374871/288*x^14
    - 1340413/72*x^13
    + 130908173/576*x^12
    - 379549/2*x^11
    + 4882501/8*x^10
    + 29575281/8*x^9
    - 272738241/64*x^8
    + 160175259/8*x^7
    + 327903147/16*x^6
    - 559978677/4*x^5
    + 11177353863/16*x^4
    + 379757241/4*x^3
    + 48029426523/4*x^2
    + 24660929115/2*x
    + 34937639928;
B2 :=
    1/32*x^13
    - 545/24*x^12
    + 1779/32*x^11
    - 7345/16*x^10
    + 9003/16*x^9
    - 223281/16*x^8
    + 14607*x^7
    - 1006587/8*x^6
    - 65367/16*x^5
    + 4825251/4*x^4
    - 11602035/8*x^3
    + 72584343/8*x^2
    - 17025795/4*x
    + 172364031/4;
a2 := F!(A2/D2);
b2 := F!(B2/D2);

// From dX/(2Y)=c2*h2*dx/y and y^2=source_polynomial.
Y2_rational := F!(
    (
        source_polynomial*Derivative(b2)
        + b2*Derivative(source_polynomial)/2
    )
    /
    (2*c2*h2)
);
Y2_y_part := F!(Derivative(a2)/(2*c2*h2));

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
assert Y2K^2 eq X2K^3 - X2K^2 + 7*X2K - 3;
map2 := map< C -> E2 | [X2K, Y2K, K!1] >;

degree1 := Degree(map1);
degree2 := Degree(map2);
assert degree1 eq 8;
assert degree2 eq 8;

print "B004_B010_B012_DEGREE8_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
print "source_automorphism_group_order", #AutC;
quit;
