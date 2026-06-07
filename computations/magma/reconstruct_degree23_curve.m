/*
Independent Mestre reconstruction and twist selection for the degree-23
Frey-Kani quotient.
*/

SetSeed(1);
Q := Integers();
F := GF(21943);
P<T> := PolynomialRing(Q);
target_weil :=
    T^4 + 19*T^3 - 25984*T^2 + 416917*T + 481495249;
target_l :=
    481495249*T^4 + 416917*T^3 - 25984*T^2 + 19*T + 1;
target_igusa_clebsch := [F | 6652, 7299, 13559, 5703];

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
    [14637, 11330, 20690, 6384, 17544, 9761, 7036];
fixed_curve := HyperellipticCurve(expected_f);
assert IsNonsingular(fixed_curve);
assert Genus(fixed_curve) eq 2;
assert IsIsomorphic(fixed_curve, quotient_curve);
assert G2Invariants(fixed_curve) eq [F | 10058, 1654, 18404];
assert P!LPolynomial(fixed_curve) eq target_l;

print "IGUSA_CLEBSCH", target_igusa_clebsch;
print "INITIAL_L_POLYNOMIAL", initial_l;
print "TWIST_SELECTED", twist_selected;
print "QUOTIENT_CURVE", quotient_curve;
print "QUOTIENT_G2_INVARIANTS", G2Invariants(quotient_curve);
print "QUOTIENT_L_POLYNOMIAL", P!LPolynomial(quotient_curve);
print "QUOTIENT_WEIL_POLYNOMIAL", target_weil;
print "FIXED_BASE_FIELD_CURVE", fixed_curve;
print "B021_DEGREE23_CURVE_RECONSTRUCTED";
quit;
