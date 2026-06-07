load "computations/magma/lib/splitting_kernel.m";

K<a> := GF(79^2);
P<x> := PolynomialRing(K);
F := FieldOfFractions(P);

source_polynomial :=
    x^6
    + 8*x^4
    + 20*x^3
    + 68*x^2
    + 240*x
    + 396;
C := HyperellipticCurve(source_polynomial);
KC := FunctionField(C);
t := KC.1;
y := KC.2;

E1 := EllipticCurve([K | 0, -1, 0, -5833, 207037]);
E2 := EllipticCurve([K | 0, -1, 0, 7, -3]);

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
X1K := Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1_multiplier_K :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
Y1K := y*Y1_multiplier_K;
assert Y1K^2 eq X1K^3 - X1K^2 - 5833*X1K + 207037;
phi1 := map< C -> E1 | [X1K, Y1K, KC!1] >;
assert Degree(phi1) eq 8;

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
phi2 := map< C -> E2 | [X2K, Y2K, KC!1] >;
assert Degree(phi2) eq 8;

graph_matrix, invariants1, invariants2,
    pairing1, pairing2, kernel_count :=
    CertifySplittingKernel(phi1, phi2, 8);

print "B018_DEGREE8_SPLITTING_KERNEL_VERIFIED";
print "base_field_size", #K;
print "target_1_group_invariants", invariants1;
print "target_2_group_invariants", invariants2;
print "graph_matrix_mod_8", graph_matrix;
print "pairing_1", pairing1;
print "pairing_2", pairing2;
print "kernel_count", kernel_count;
quit;
