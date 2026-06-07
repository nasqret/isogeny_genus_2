/*
Static independent verification of both descended degree-17 maps.
Generated from results/sage_degree17_descended_maps.json.
*/

Fq := GF(8263);
P<x> := PolynomialRing(Fq);
R := FieldOfFractions(P);

source_polynomial := 5422*x^6 + 4306*x^5 + 4875*x^4 + 5667*x^3 + 6314*x^2 + 4554*x + 6050;
assert IsSquarefree(source_polynomial);
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;

E1 := EllipticCurve([Fq | 0, 0, 0, 0, 1728]);
X1 := R!(
    (704*x^17 + 7579*x^16 + 2649*x^15 + 6672*x^14 + 1717*x^13 + 7914*x^12 + 80*x^11 + 5824*x^10 + 2282*x^9 + 7339*x^8 + 5209*x^7 + 3879*x^6 + 3957*x^5 + 5391*x^4 + 7864*x^3 + 3650*x^2 + 6758*x + 6124)
    /
    (x^17 + 5393*x^16 + 4776*x^15 + 2701*x^14 + 6800*x^13 + 7521*x^12 + 6565*x^11 + 5506*x^10 + 4357*x^9 + 7590*x^8 + 5997*x^7 + 5572*x^6 + 3524*x^5 + 7198*x^4 + 7073*x^3 + 3002*x^2 + 522*x + 851)
);
Y1_multiplier := R!(
    (3452*x^24 + 2420*x^23 + 1284*x^22 + 868*x^21 + 5003*x^20 + 6876*x^19 + 482*x^18 + 4478*x^17 + 3694*x^16 + 5928*x^15 + 6585*x^14 + 3681*x^13 + 3145*x^12 + 330*x^11 + 5937*x^10 + 1418*x^9 + 96*x^8 + 949*x^7 + 5821*x^6 + 8222*x^5 + 7692*x^4 + 4131*x^3 + 2275*x^2 + 6739*x + 3103)
    /
    (x^27 + 8131*x^26 + 6431*x^25 + 4491*x^24 + 6237*x^23 + 7635*x^22 + 374*x^21 + 6131*x^20 + 1506*x^19 + 3726*x^18 + 7234*x^17 + 4736*x^16 + 7558*x^15 + 6119*x^14 + 4756*x^13 + 4147*x^12 + 3481*x^11 + 2602*x^10 + 1868*x^9 + 628*x^8 + 2399*x^7 + 6562*x^6 + 43*x^5 + 2440*x^4 + 1657*x^3 + 617*x^2 + 7540*x + 4682)
);
assert R!source_polynomial*Y1_multiplier^2 eq
    X1^3 + (0)*X1 + (1728);
assert Derivative(X1)/(2*Y1_multiplier) eq 2757*x + 403;
X1K :=
    Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1MultiplierK :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
Y1K := y*Y1MultiplierK;
assert Y1K^2 eq X1K^3 + (0)*X1K + (1728);
map1 := map< C -> E1 | [X1K, Y1K, K!1] >;
degree1 := Degree(map1);
assert degree1 eq 17;

E2 := EllipticCurve([Fq | 0, 0, 0, 6442, 3171]);
X2 := R!(
    (591*x^17 + 2778*x^16 + 5481*x^15 + 3888*x^14 + 3298*x^13 + 2309*x^12 + 7700*x^11 + 4094*x^10 + 4091*x^9 + 5011*x^8 + 7422*x^7 + 4946*x^6 + 4143*x^5 + 3184*x^4 + 5494*x^3 + 4346*x^2 + 2030*x + 5859)
    /
    (x^17 + 7005*x^16 + 1765*x^15 + 6241*x^14 + 6925*x^13 + 6170*x^12 + 6388*x^11 + 1273*x^10 + 3389*x^9 + 513*x^8 + 1143*x^7 + 4129*x^6 + 2111*x^5 + 2178*x^4 + 4850*x^3 + 327*x^2 + 2776*x + 5238)
);
Y2_multiplier := R!(
    (1098*x^24 + 4924*x^23 + 6872*x^22 + 6819*x^21 + 3517*x^20 + 2979*x^19 + 232*x^18 + 5837*x^17 + 219*x^16 + 6538*x^15 + 8002*x^14 + 133*x^13 + 7331*x^12 + 3615*x^11 + 3059*x^10 + 755*x^9 + 2063*x^8 + 2067*x^7 + 4033*x^6 + 7175*x^5 + 5873*x^4 + 267*x^3 + 1842*x^2 + 7516*x + 7346)
    /
    (x^27 + 6405*x^26 + 4977*x^25 + 1226*x^24 + 3500*x^23 + 2398*x^22 + 6585*x^21 + 2791*x^20 + 5673*x^19 + 1023*x^18 + 2834*x^17 + 3960*x^16 + 1020*x^15 + 999*x^14 + 6044*x^13 + 4085*x^12 + 4042*x^11 + 5604*x^10 + 6384*x^9 + 8110*x^8 + 1133*x^7 + 1828*x^6 + 7296*x^5 + 1006*x^4 + 4958*x^3 + 1055*x^2 + 1646*x + 2877)
);
assert R!source_polynomial*Y2_multiplier^2 eq
    X2^3 + (6442)*X2 + (3171);
assert Derivative(X2)/(2*Y2_multiplier) eq 789*x + 6701;
X2K :=
    Evaluate(Numerator(X2), t)/Evaluate(Denominator(X2), t);
Y2MultiplierK :=
    Evaluate(Numerator(Y2_multiplier), t)
    / Evaluate(Denominator(Y2_multiplier), t);
Y2K := y*Y2MultiplierK;
assert Y2K^2 eq X2K^3 + (6442)*X2K + (3171);
map2 := map< C -> E2 | [X2K, Y2K, K!1] >;
degree2 := Degree(map2);
assert degree2 eq 17;

print "B019_DEGREE17_MAPS_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
print "eigenform_1", 2757*x + 403;
print "eigenform_2", 789*x + 6701;
quit;
