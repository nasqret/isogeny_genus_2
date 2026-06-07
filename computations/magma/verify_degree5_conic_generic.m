/*
Decide generic splitting of the degree-5 normalization conic over the
fourth-critical-point field Q(a,b,c).
*/

Q := Rationals();
Fa<a> := FunctionField(Q);
F<b> := FunctionField(Fa);
Pc<C> := PolynomialRing(F);
critical_polynomial :=
    C^2
    + F!(
        (2*b - 2*a*b - 2*a - a^2)/(2*a + 1)
    )*C
    + F!((b^2 + 2*a*b)/(2*a + 1));
Kc<c> := ext<F | critical_polynomial>;

aa := Kc!a;
bb := Kc!b;
L := aa^4 + 2*aa^3 + 2*aa^2*bb + aa^2 + bb^2;
M := 2*bb*(aa + bb)*(aa^2 + bb);
N := bb^3*(2*aa + bb);
discriminant := M^2 - 4*L*N;

point_denominator := 2*aa^2 + 3*aa + 4*bb;
m :=
    ((aa + 2*bb)*c - 2*bb*(2*aa + bb))
    /point_denominator;
y :=
    (
        (
            aa^3 - 2*aa^2*bb + aa^2
            - aa*bb - 2*bb^2
        )*c
        + 2*aa^2*bb - 3*aa*bb^2 - 2*bb^3
    )/point_denominator;
assert y^2 eq L*m^2 + M*m + N;
"SOLUBLE", true;
"POINT_M", m;
"POINT_Y", y;
"VERIFIED", true;
