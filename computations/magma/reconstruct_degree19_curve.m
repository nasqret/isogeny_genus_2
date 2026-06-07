/*
Independent Mestre reconstruction and twist selection for the degree-19
Frey-Kani quotient.
*/

SetSeed(1);
Q := Integers();
F := GF(11743);
P<T> := PolynomialRing(Q);
target_weil :=
    T^4 - 23*T^3 - 8962*T^2 - 270089*T + 137898049;
target_l :=
    137898049*T^4 - 270089*T^3 - 8962*T^2 - 23*T + 1;

// Normalized from Kohel invariants (11336,8788,9369) by setting I2=1.
target_igusa_clebsch := [F | 1, 3992, 8409, 8638];
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
    [3417, 4884, 1439, 7190, 6679, 7591, 9500];
fixed_curve := HyperellipticCurve(expected_f);
assert IsNonsingular(fixed_curve);
assert Genus(fixed_curve) eq 2;
assert IsIsomorphic(fixed_curve, quotient_curve);
assert G2Invariants(fixed_curve) eq [F | 8456, 11363, 10925];
assert P!LPolynomial(fixed_curve) eq target_l;

print "NORMALIZED_IGUSA_CLEBSCH", target_igusa_clebsch;
print "INITIAL_L_POLYNOMIAL", initial_l;
print "TWIST_SELECTED", twist_selected;
print "QUOTIENT_CURVE", quotient_curve;
print "QUOTIENT_G2_INVARIANTS", G2Invariants(quotient_curve);
print "QUOTIENT_L_POLYNOMIAL", P!LPolynomial(quotient_curve);
print "QUOTIENT_WEIL_POLYNOMIAL", target_weil;
print "FIXED_BASE_FIELD_CURVE", fixed_curve;
print "B020_DEGREE19_CURVE_RECONSTRUCTED";
quit;
