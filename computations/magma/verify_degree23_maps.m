/*
Static independent verification of both descended degree-23 maps.
Generated from results/sage_degree23_descended_maps.json.
*/

Fq := GF(21943);
P<x> := PolynomialRing(Fq);
R := FieldOfFractions(P);

source_polynomial := 7036*x^6 + 9761*x^5 + 17544*x^4 + 6384*x^3 + 20690*x^2 + 11330*x + 14637;
assert IsSquarefree(source_polynomial);
C := HyperellipticCurve(source_polynomial);
K := FunctionField(C);
t := K.1;
y := K.2;

E1 := EllipticCurve([Fq | 0, 0, 0, 18008, 21189]);
X1 := R!(
    (15849*x^23 + 11771*x^22 + 19766*x^21 + 15128*x^20 + 17291*x^19 + 9188*x^18 + 17963*x^17 + 17300*x^16 + 16574*x^15 + 4533*x^14 + 8047*x^13 + 19879*x^12 + 9660*x^11 + 20570*x^10 + 13565*x^9 + 5011*x^8 + 864*x^7 + 13993*x^6 + 14360*x^5 + 10693*x^4 + 2165*x^3 + 7970*x^2 + 18163*x + 10172)
    /
    (x^23 + 13671*x^22 + 636*x^21 + 11280*x^20 + 3909*x^19 + 9077*x^18 + 17115*x^17 + 10077*x^16 + 19813*x^15 + 13223*x^14 + 7537*x^13 + 6148*x^12 + 8626*x^11 + 17115*x^10 + 21197*x^9 + 4033*x^8 + 19915*x^7 + 3776*x^6 + 16486*x^5 + 6958*x^4 + 17029*x^3 + 16446*x^2 + 15898*x + 1320)
);
Y1_multiplier := R!(
    (8434*x^33 + 161*x^32 + 11167*x^31 + 12343*x^30 + 13968*x^29 + 5005*x^28 + 13416*x^27 + 13563*x^26 + 16035*x^25 + 111*x^24 + 8340*x^23 + 356*x^22 + 4227*x^21 + 12274*x^20 + 8247*x^19 + 10603*x^18 + 8982*x^17 + 16571*x^16 + 9149*x^15 + 1792*x^14 + 21597*x^13 + 17164*x^12 + 21591*x^11 + 2346*x^10 + 502*x^9 + 20984*x^8 + 4248*x^7 + 6065*x^6 + 8031*x^5 + 21022*x^4 + 2409*x^3 + 7431*x^2 + 16550*x + 728)
    /
    (x^36 + 14608*x^35 + 19146*x^34 + 11*x^33 + 18043*x^32 + 9533*x^31 + 6586*x^30 + 17458*x^29 + 8794*x^28 + 1389*x^27 + 2369*x^26 + 5389*x^25 + 2647*x^24 + 14011*x^23 + 9613*x^22 + 18240*x^21 + 11328*x^20 + 15066*x^19 + 891*x^18 + 20009*x^17 + 20402*x^16 + 16204*x^15 + 11313*x^14 + 6841*x^13 + 15742*x^12 + 17436*x^11 + 21826*x^10 + 1900*x^9 + 17048*x^8 + 15861*x^7 + 17116*x^6 + 8992*x^5 + 21652*x^4 + 9520*x^3 + 18766*x^2 + 10552*x + 3608)
);
assert R!source_polynomial*Y1_multiplier^2 eq
    X1^3 + (18008)*X1 + (21189);
assert Derivative(X1)/(2*Y1_multiplier) eq 17002*x + 14908;
X1K :=
    Evaluate(Numerator(X1), t)/Evaluate(Denominator(X1), t);
Y1MultiplierK :=
    Evaluate(Numerator(Y1_multiplier), t)
    / Evaluate(Denominator(Y1_multiplier), t);
Y1K := y*Y1MultiplierK;
assert Y1K^2 eq X1K^3 + (18008)*X1K + (21189);
map1 := map< C -> E1 | [X1K, Y1K, K!1] >;
degree1 := Degree(map1);
assert degree1 eq 23;

E2 := EllipticCurve([Fq | 0, 0, 0, 6198, 5070]);
X2 := R!(
    (20850*x^23 + 20039*x^22 + 15277*x^21 + 10666*x^20 + 18153*x^19 + 11034*x^18 + 6276*x^17 + 9105*x^16 + 1211*x^15 + 10464*x^14 + 7831*x^13 + 13800*x^12 + 8727*x^11 + 17122*x^10 + 14411*x^9 + 19432*x^8 + 19697*x^7 + 2875*x^6 + 7284*x^5 + 14154*x^4 + 8785*x^3 + 9120*x^2 + 14156*x + 10785)
    /
    (x^23 + 13168*x^22 + 21510*x^21 + 21657*x^20 + 15901*x^19 + 1194*x^18 + 6897*x^17 + 12425*x^16 + 20757*x^15 + 10312*x^14 + 20750*x^13 + 10084*x^12 + 9979*x^11 + 3518*x^10 + 10897*x^9 + 6085*x^8 + 20771*x^7 + 20990*x^6 + 21325*x^5 + 602*x^4 + 4374*x^3 + 6070*x^2 + 1686*x + 10481)
);
Y2_multiplier := R!(
    (3375*x^32 + 4083*x^31 + 5160*x^30 + 13893*x^29 + 5331*x^28 + 6170*x^27 + 18377*x^26 + 7080*x^25 + 19894*x^24 + 7445*x^23 + 9827*x^22 + 3963*x^21 + 2932*x^20 + 19654*x^19 + 8174*x^18 + 21608*x^17 + 14948*x^16 + 2037*x^15 + 3913*x^14 + 5412*x^13 + 4988*x^12 + 21768*x^11 + 3532*x^10 + 8518*x^9 + 11321*x^8 + 19706*x^7 + 20639*x^6 + 11996*x^5 + 2570*x^4 + 14898*x^3 + 19897*x^2 + 16889*x + 8950)
    /
    (x^35 + 16302*x^34 + 715*x^33 + 16331*x^32 + 3143*x^31 + 20206*x^30 + 20434*x^29 + 16076*x^28 + 9514*x^27 + 3528*x^26 + 2312*x^25 + 12276*x^24 + 4182*x^23 + 21105*x^22 + 16994*x^21 + 11463*x^20 + 3615*x^19 + 21252*x^18 + 1110*x^17 + 13492*x^16 + 19569*x^15 + 11396*x^14 + 397*x^13 + 12366*x^12 + 18445*x^11 + 59*x^10 + 21029*x^9 + 5499*x^8 + 10283*x^7 + 18748*x^6 + 4335*x^5 + 20163*x^4 + 10475*x^3 + 3334*x^2 + 16245*x + 12835)
);
assert R!source_polynomial*Y2_multiplier^2 eq
    X2^3 + (6198)*X2 + (5070);
assert Derivative(X2)/(2*Y2_multiplier) eq 3687*x + 19153;
X2K :=
    Evaluate(Numerator(X2), t)/Evaluate(Denominator(X2), t);
Y2MultiplierK :=
    Evaluate(Numerator(Y2_multiplier), t)
    / Evaluate(Denominator(Y2_multiplier), t);
Y2K := y*Y2MultiplierK;
assert Y2K^2 eq X2K^3 + (6198)*X2K + (5070);
map2 := map< C -> E2 | [X2K, Y2K, K!1] >;
degree2 := Degree(map2);
assert degree2 eq 23;

print "B021_DEGREE23_MAPS_MAGMA_VERIFIED";
print "degree_1", degree1;
print "degree_2", degree2;
print "j_1", jInvariant(E1);
print "j_2", jInvariant(E2);
print "eigenform_1", 17002*x + 14908;
print "eigenform_2", 3687*x + 19153;
quit;
