/*
Independent Mestre reconstruction and twist selection for the degree-13
Frey-Kani quotient.
*/

Q := Integers();
F := GF(8009);
P<T> := PolynomialRing(Q);
target_weil :=
    T^4 + 35*T^3 + 9184*T^2 + 280315*T + 64144081;
target_l :=
    64144081*T^4 + 280315*T^3 + 9184*T^2 + 35*T + 1;
target_invariants := [F | 2419, 7563, 6738, 5346];

initial_curve :=
    HyperellipticCurveFromIgusaClebsch(target_invariants);
initial_l := PolynomialRing(Q)!LPolynomial(initial_curve);
f, h := HyperellipticPolynomials(initial_curve);
assert h eq 0;

if initial_l eq target_l then
    quotient_curve := initial_curve;
    twist_factor := F!1;
else
    twist_factor := PrimitiveElement(F);
    assert not IsSquare(twist_factor);
    quotient_curve := HyperellipticCurve(twist_factor*f);
end if;

assert IsNonsingular(quotient_curve);
assert Genus(quotient_curve) eq 2;
actual_l := PolynomialRing(Q)!LPolynomial(quotient_curve);
assert actual_l eq target_l;

expected_f :=
    PolynomialRing(F)!
    [84, 5767, 4018, 3661, 6357, 4620, 6042];
fixed_curve := HyperellipticCurve(expected_f);
assert IsNonsingular(fixed_curve);
assert Genus(fixed_curve) eq 2;
assert G2Invariants(fixed_curve) eq G2Invariants(quotient_curve);
assert PolynomialRing(Q)!LPolynomial(fixed_curve) eq target_l;

print "INPUT_IGUSA_CLEBSCH", target_invariants;
print "MESTRE_INITIAL_L_POLYNOMIAL", initial_l;
print "TWIST_FACTOR", twist_factor;
print "MESTRE_QUOTIENT_CURVE", quotient_curve;
print "QUOTIENT_G2_INVARIANTS", G2Invariants(quotient_curve);
print "QUOTIENT_L_POLYNOMIAL", actual_l;
print "QUOTIENT_WEIL_POLYNOMIAL", target_weil;
print "FIXED_BASE_FIELD_CURVE", fixed_curve;
print "B014_DEGREE13_CURVE_RECONSTRUCTED";
