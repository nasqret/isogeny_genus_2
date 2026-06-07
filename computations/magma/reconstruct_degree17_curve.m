/*
Independent Mestre reconstruction and twist selection for the degree-17
Frey-Kani quotient.
*/

SetSeed(1);
Q := Integers();
F := GF(8263);
P<T> := PolynomialRing(Q);
target_weil :=
    T^4 - 55*T^3 - 3598*T^2 - 454465*T + 68277169;
target_l :=
    68277169*T^4 - 454465*T^3 - 3598*T^2 - 55*T + 1;

// Normalized from Kohel invariants (893,1328,7156) by setting I2=1.
target_igusa_clebsch := [F | 1, 4851, 430, 7240];
initial_curve :=
    HyperellipticCurveFromIgusaClebsch(target_igusa_clebsch);
initial_l := P!LPolynomial(initial_curve);

if initial_l eq target_l then
    quotient_curve := initial_curve;
    twist_selected := false;
else
    quotient_curve :=
        QuadraticTwist(initial_curve, PrimitiveElement(F));
    twist_selected := true;
end if;

assert IsNonsingular(quotient_curve);
assert Genus(quotient_curve) eq 2;
assert P!LPolynomial(quotient_curve) eq target_l;

expected_f :=
    PolynomialRing(F)!
    [6050, 4554, 6314, 5667, 4875, 4306, 5422];
fixed_curve := HyperellipticCurve(expected_f);
assert IsNonsingular(fixed_curve);
assert Genus(fixed_curve) eq 2;
assert IsIsomorphic(fixed_curve, quotient_curve);
assert G2Invariants(fixed_curve) eq [F | 4393, 3171, 8140];
assert P!LPolynomial(fixed_curve) eq target_l;

print "NORMALIZED_IGUSA_CLEBSCH", target_igusa_clebsch;
print "INITIAL_L_POLYNOMIAL", initial_l;
print "TWIST_SELECTED", twist_selected;
print "QUOTIENT_G2_INVARIANTS", G2Invariants(quotient_curve);
print "QUOTIENT_L_POLYNOMIAL", P!LPolynomial(quotient_curve);
print "QUOTIENT_WEIL_POLYNOMIAL", target_weil;
print "FIXED_BASE_FIELD_CURVE", fixed_curve;
print "B019_DEGREE17_CURVE_RECONSTRUCTED";
quit;
