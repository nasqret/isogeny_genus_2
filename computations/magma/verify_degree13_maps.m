/*
Independent verification of the two descended degree-13 elliptic maps.
*/

Fq := GF(8009);
P<x> := PolynomialRing(Fq);
R := FieldOfFractions(P);

source_polynomial :=
    6042*x^6 + 4620*x^5 + 6357*x^4 + 3661*x^3
    + 4018*x^2 + 5767*x + 84;
assert IsSquarefree(source_polynomial);
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;

E1 := EllipticCurve([Fq | 0, 0, 0, 5553, 5419]);
X1 := R!(
    (
        5906*x^13 + 4158*x^12 + 3323*x^11 + 3418*x^10
        + 5730*x^9 + 4250*x^8 + 2268*x^7 + 4252*x^6
        + 7994*x^5 + 7700*x^4 + 4577*x^3 + 625*x^2
        + 7198*x + 4967
    )
    /
    (
        x^13 + 979*x^12 + 7294*x^11 + 4438*x^10
        + 7303*x^9 + 3178*x^8 + 6515*x^7 + 6976*x^6
        + 4345*x^5 + 374*x^4 + 7102*x^3 + 4570*x^2
        + 7701*x + 6150
    )
);
Y1_multiplier := R!(
    (
        2627*x^18 + 4723*x^17 + 3488*x^16 + 3478*x^15
        + 3530*x^14 + 5498*x^13 + 466*x^12 + 6169*x^11
        + 412*x^10 + 5180*x^9 + 6512*x^8 + 2830*x^7
        + 4192*x^6 + 7758*x^5 + 2528*x^4 + 350*x^3
        + 4593*x^2 + 255*x + 6715
    )
    /
    (
        x^21 + 761*x^20 + 2521*x^19 + 4884*x^18
        + 7057*x^17 + 2946*x^16 + 7539*x^15 + 4387*x^14
        + 3943*x^13 + 7861*x^12 + 3100*x^11 + 2017*x^10
        + 7946*x^9 + 5074*x^8 + 7392*x^7 + 5375*x^6
        + 1118*x^5 + 6017*x^4 + 7418*x^3 + 2972*x^2
        + 1722*x + 217
    )
);
assert R!source_polynomial*Y1_multiplier^2 eq
    X1^3 + 5553*X1 + 5419;
assert Derivative(X1)/(2*Y1_multiplier) eq 618*x + 1045;
X1K := Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1MultiplierK :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
Y1K := y*Y1MultiplierK;
assert Y1K^2 eq X1K^3 + 5553*X1K + 5419;
map1 := map< C -> E1 | [X1K, Y1K, K!1] >;

E2 := EllipticCurve([Fq | 0, 0, 0, 2531, 1402]);
X2 := R!(
    (
        6344*x^13 + 3137*x^12 + 5764*x^11 + 2070*x^10
        + 1195*x^9 + 4096*x^8 + 1991*x^7 + 754*x^6
        + 1334*x^5 + 3696*x^4 + 6920*x^3 + 7752*x^2
        + 4676*x + 3581
    )
    /
    (
        x^13 + 5831*x^12 + 1552*x^11 + 388*x^10
        + 5355*x^9 + 4213*x^8 + 7021*x^7 + 3652*x^6
        + 6616*x^5 + 3272*x^4 + 6260*x^3 + 4568*x^2
        + 3430*x + 4700
    )
);
Y2_multiplier := R!(
    (
        7231*x^17 + 5663*x^16 + 6979*x^15 + 4729*x^14
        + 7118*x^13 + 499*x^12 + 3394*x^11 + 4074*x^10
        + 2495*x^9 + 5894*x^8 + 6431*x^7 + 6687*x^6
        + 5346*x^5 + 690*x^4 + 2735*x^3 + 4566*x^2
        + 6028*x + 4910
    )
    /
    (
        x^20 + 512*x^19 + 2695*x^18 + 1329*x^17
        + 4144*x^16 + 4571*x^15 + 7138*x^14 + 4731*x^13
        + 1012*x^12 + 7970*x^11 + 6144*x^10 + 5760*x^9
        + 3959*x^8 + 5487*x^7 + 7449*x^6 + 6640*x^5
        + 5781*x^4 + 1832*x^3 + 7958*x^2 + 7122*x
        + 7075
    )
);
assert R!source_polynomial*Y2_multiplier^2 eq
    X2^3 + 2531*X2 + 1402;
assert Derivative(X2)/(2*Y2_multiplier) eq 209*x + 6653;
X2K := Evaluate(Numerator(X2), t)/Evaluate(Denominator(X2), t);
Y2MultiplierK :=
    Evaluate(Numerator(Y2_multiplier), t)
    / Evaluate(Denominator(Y2_multiplier), t);
Y2K := y*Y2MultiplierK;
assert Y2K^2 eq X2K^3 + 2531*X2K + 1402;
map2 := map< C -> E2 | [X2K, Y2K, K!1] >;

degree1 := Degree(map1);
degree2 := Degree(map2);
assert degree1 eq 13;
assert degree2 eq 13;

print "B014_DEGREE13_MAPS_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
print "eigenform_1", 618*x + 1045;
print "eigenform_2", 209*x + 6653;
quit;
