Q := Rationals();
P<x> := PolynomialRing(Q);

assert (x^3 - 1) div (x - 1) eq x^2 + x + 1;
PolynomialDiscriminant := Discriminant(x^3 + 25*x + 375);
assert PolynomialDiscriminant eq -3859375;
assert 16*PolynomialDiscriminant eq -61750000;

print "MAGMA_SMOKE_OK";
quit;
