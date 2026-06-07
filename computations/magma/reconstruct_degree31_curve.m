/*
Independent reconstruction and twist selection for the degree-31
Frey-Kani quotient.
*/

SetSeed(1);
Q := Integers();
F := GF(64853);
P<T> := PolynomialRing(Q);
target_weil :=
    T^4 + 27*T^3 - 100992*T^2 + 1751031*T + 4205911609;
target_l :=
    4205911609*T^4 + 1751031*T^3 - 100992*T^2 + 27*T + 1;
target_igusa_clebsch := [F | 36614, 24694, 25370, 43295];

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
    [0, 18215, 18410, 40681, 52399, 1];
fixed_curve := HyperellipticCurve(expected_f);
assert IsNonsingular(fixed_curve);
assert Genus(fixed_curve) eq 2;
assert IsIsomorphic(fixed_curve, quotient_curve);
assert P!LPolynomial(fixed_curve) eq target_l;

print "IGUSA_CLEBSCH", target_igusa_clebsch;
print "INITIAL_L_POLYNOMIAL", initial_l;
print "TWIST_SELECTED", twist_selected;
print "QUOTIENT_G2_INVARIANTS", G2Invariants(quotient_curve);
print "QUOTIENT_L_POLYNOMIAL", P!LPolynomial(quotient_curve);
print "QUOTIENT_WEIL_POLYNOMIAL", target_weil;
print "FIXED_BASE_FIELD_CURVE", fixed_curve;
print "B025_DEGREE31_CURVE_RECONSTRUCTED";
quit;
