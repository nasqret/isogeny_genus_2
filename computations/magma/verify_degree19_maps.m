/*
Static independent verification of both descended degree-19 maps.
Generated from results/sage_degree19_descended_maps.json.
*/

Fq := GF(11743);
P<x> := PolynomialRing(Fq);
R := FieldOfFractions(P);

source_polynomial := 9500*x^6 + 7591*x^5 + 6679*x^4 + 7190*x^3 + 1439*x^2 + 4884*x + 3417;
assert IsSquarefree(source_polynomial);
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;

E1 := EllipticCurve([Fq | 0, 0, 0, 8444, 6205]);
X1 := R!(
    (7020*x^19 + 4094*x^18 + 4735*x^17 + 10096*x^16 + 2119*x^15 + 3671*x^14 + 11435*x^13 + 7111*x^12 + 6868*x^11 + 6826*x^10 + 9171*x^9 + 8609*x^8 + 6382*x^7 + 3858*x^6 + 843*x^5 + 9149*x^4 + 10157*x^3 + 1163*x^2 + 5138*x + 11350)
    /
    (x^19 + 10302*x^18 + 1557*x^17 + 9413*x^16 + 5773*x^15 + 8405*x^14 + 10302*x^13 + 7590*x^12 + 1370*x^11 + 11080*x^10 + 1091*x^9 + 6309*x^8 + 4664*x^7 + 9377*x^6 + 2654*x^5 + 11156*x^4 + 9365*x^3 + 7378*x^2 + 2264*x + 2648)
);
Y1_multiplier := R!(
    (4076*x^27 + 1044*x^26 + 9583*x^25 + 3350*x^24 + 6465*x^23 + 5520*x^22 + 5336*x^21 + 7775*x^20 + 11312*x^19 + 1562*x^18 + 9416*x^17 + 5611*x^16 + 9764*x^15 + 8925*x^14 + 5648*x^13 + 9879*x^12 + 5175*x^11 + 6723*x^10 + 3401*x^9 + 582*x^8 + 1075*x^7 + 9861*x^6 + 883*x^5 + 6720*x^4 + 8208*x^3 + 2787*x^2 + 1818*x + 2585)
    /
    (x^30 + 4825*x^29 + 6443*x^28 + 3299*x^27 + 2803*x^26 + 7106*x^25 + 8088*x^24 + 7982*x^23 + 11434*x^22 + 703*x^21 + 10976*x^20 + 7020*x^19 + 2988*x^18 + 1145*x^17 + 3927*x^16 + 613*x^15 + 6322*x^14 + 9487*x^13 + 278*x^12 + 11353*x^11 + 11366*x^10 + 10664*x^9 + 11091*x^8 + 1709*x^7 + 9260*x^6 + 5094*x^5 + 10201*x^4 + 2058*x^3 + 5352*x^2 + 4595*x + 5226)
);
assert R!source_polynomial*Y1_multiplier^2 eq
    X1^3 + (8444)*X1 + (6205);
assert Derivative(X1)/(2*Y1_multiplier) eq 10395*x + 6513;
X1K :=
    Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1MultiplierK :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
Y1K := y*Y1MultiplierK;
assert Y1K^2 eq X1K^3 + (8444)*X1K + (6205);
map1 := map< C -> E1 | [X1K, Y1K, K!1] >;
degree1 := Degree(map1);
assert degree1 eq 19;

E2 := EllipticCurve([Fq | 0, 0, 0, 4036, 11557]);
X2 := R!(
    (9924*x^19 + 1970*x^18 + 9031*x^17 + 4827*x^16 + 7487*x^15 + 2083*x^14 + 6700*x^13 + 7556*x^12 + 4979*x^11 + 10242*x^10 + 1594*x^9 + 5738*x^8 + 7990*x^7 + 1775*x^6 + 4021*x^5 + 4603*x^4 + 4223*x^3 + 5036*x^2 + 9882*x + 7208)
    /
    (x^19 + 11015*x^18 + 8696*x^17 + 8276*x^16 + 378*x^15 + 9143*x^14 + 131*x^13 + 6519*x^12 + 870*x^11 + 10508*x^10 + 4732*x^9 + 9480*x^8 + 7465*x^7 + 2201*x^6 + 2654*x^5 + 6922*x^4 + 6309*x^3 + 631*x^2 + 2954*x + 2618)
);
Y2_multiplier := R!(
    (7714*x^27 + 3042*x^26 + 7246*x^25 + 1882*x^24 + 937*x^23 + 121*x^22 + 1436*x^21 + 3976*x^20 + 3003*x^19 + 7566*x^18 + 7161*x^17 + 8449*x^16 + 1707*x^15 + 8098*x^14 + 5056*x^13 + 7759*x^12 + 5381*x^11 + 2440*x^10 + 5089*x^9 + 9187*x^8 + 1511*x^7 + 8551*x^6 + 9575*x^5 + 10622*x^4 + 11569*x^3 + 6260*x^2 + 9500*x + 5989)
    /
    (x^30 + 10317*x^29 + 7511*x^28 + 1908*x^27 + 10645*x^26 + 10997*x^25 + 6231*x^24 + 11113*x^23 + 3983*x^22 + 11222*x^21 + 957*x^20 + 3928*x^19 + 3475*x^18 + 5527*x^17 + 7350*x^16 + 8741*x^15 + 3846*x^14 + 10667*x^13 + 5292*x^12 + 8322*x^11 + 2144*x^10 + 4932*x^9 + 11469*x^8 + 4200*x^7 + 8511*x^6 + 6535*x^5 + 2863*x^4 + 10951*x^3 + 8816*x^2 + 3676*x + 8316)
);
assert R!source_polynomial*Y2_multiplier^2 eq
    X2^3 + (4036)*X2 + (11557);
assert Derivative(X2)/(2*Y2_multiplier) eq 5397*x + 10364;
X2K :=
    Evaluate(Numerator(X2), t)/Evaluate(Denominator(X2), t);
Y2MultiplierK :=
    Evaluate(Numerator(Y2_multiplier), t)
    / Evaluate(Denominator(Y2_multiplier), t);
Y2K := y*Y2MultiplierK;
assert Y2K^2 eq X2K^3 + (4036)*X2K + (11557);
map2 := map< C -> E2 | [X2K, Y2K, K!1] >;
degree2 := Degree(map2);
assert degree2 eq 19;

print "B020_DEGREE19_MAPS_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
print "eigenform_1", 10395*x + 6513;
print "eigenform_2", 5397*x + 10364;
quit;
