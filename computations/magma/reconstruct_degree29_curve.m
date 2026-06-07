/*
Independent Mestre reconstruction and twist selection for the degree-29
Frey-Kani quotient.
*/

SetSeed(1);
Q := Integers();
F := GF(50867);
P<T> := PolynomialRing(Q);
target_weil :=
    T^4 + 25*T^3 - 74930*T^2 + 1271675*T + 2587451689;
target_l :=
    2587451689*T^4 + 1271675*T^3 - 74930*T^2 + 25*T + 1;

// Normalized from Kohel invariants (15563,43108,4996) by setting I2=1.
target_igusa_clebsch := [F | 1, 21252, 39425, 6127];
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
    [31812, 234, 46765, 37221, 5530, 50615, 24513];
fixed_curve := HyperellipticCurve(expected_f);
assert IsNonsingular(fixed_curve);
assert Genus(fixed_curve) eq 2;
assert IsIsomorphic(fixed_curve, quotient_curve);
assert G2Invariants(fixed_curve) eq [F | 30806, 10408, 29480];
assert P!LPolynomial(fixed_curve) eq target_l;

print "NORMALIZED_IGUSA_CLEBSCH", target_igusa_clebsch;
print "INITIAL_L_POLYNOMIAL", initial_l;
print "TWIST_SELECTED", twist_selected;
print "QUOTIENT_CURVE", quotient_curve;
print "QUOTIENT_G2_INVARIANTS", G2Invariants(quotient_curve);
print "QUOTIENT_L_POLYNOMIAL", P!LPolynomial(quotient_curve);
print "QUOTIENT_WEIL_POLYNOMIAL", target_weil;
print "FIXED_BASE_FIELD_CURVE", fixed_curve;
print "B024_DEGREE29_CURVE_RECONSTRUCTED";
quit;
