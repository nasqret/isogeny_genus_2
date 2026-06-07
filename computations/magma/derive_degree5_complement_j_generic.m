/*
Generic complementary j-invariant for the two-parameter degree-5 family.

This is the Magma counterpart of
computations/sage/lib/degree5_complement.sage.  It works over Q(a,b),
adjoins the fourth critical point c, and uses the diagonal point (c,c)
to parametrize the normalization conic directly over Q(a,b,c).
*/

SetSeed(1);
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

Pt<t> := PolynomialRing(Kc);
Kt := FieldOfFractions(Pt);

aa := Kc!a;
bb := Kc!b;
cc := Kc!c;
L := aa^4 + 2*aa^3 + 2*aa^2*bb + aa^2 + bb^2;
M := 2*bb*(aa + bb)*(aa^2 + bb);
N := bb^3*(2*aa + bb);

function ProjectionResidualCoefficients(m_value, aa, bb)
    A_value :=
        (
            aa^2*m_value + 2*aa*bb*m_value + 2*aa*m_value^2
            + bb^2 + 2*bb*m_value + m_value^2
        )^2;
    B_value := 4*aa*(
        -aa^5*m_value^3
        - 4*aa^4*bb*m_value^2
        - 2*aa^3*bb^2*m_value^2
        - 4*aa^4*m_value^3
        - 2*aa^3*bb*m_value^3
        + aa^4*bb*m_value
        + aa^2*bb^3*m_value
        + aa*bb^4*m_value
        - 6*aa^3*bb*m_value^2
        + aa^2*bb^2*m_value^2
        + 2*aa*bb^3*m_value^2
        - 6*aa^3*m_value^3
        + aa*bb^2*m_value^3
        + aa^2*bb^3
        + 2*aa*bb^4
        + bb^5
        - aa^2*bb^2*m_value
        + 6*aa*bb^3*m_value
        + 3*bb^4*m_value
        - 6*aa^2*bb*m_value^2
        + 6*aa*bb^2*m_value^2
        + 3*bb^3*m_value^2
        - 4*aa^2*m_value^3
        + 2*aa*bb*m_value^3
        + bb^2*m_value^3
        + bb^4
        - aa*bb^2*m_value
        + 3*bb^3*m_value
        - 2*aa*bb*m_value^2
        + 3*bb^2*m_value^2
        - aa*m_value^3
        + bb*m_value^3
    );
    return A_value, B_value;
end function;

/* The diagonal critical point (c,c) supplies a canonical conic point. */
r0 := 2*cc + aa^2 + 2*aa + 2*bb;
point_denominator := 2*aa^2 + 3*aa + 4*bb;
m0 :=
    ((aa + 2*bb)*cc - 2*bb*(2*aa + bb))
    /point_denominator;
y0 :=
    (
        (
            aa^3 - 2*aa^2*bb + aa^2
            - aa*bb - 2*bb^2
        )*cc
        + 2*aa^2*bb - 3*aa*bb^2 - 2*bb^3
    )/point_denominator;
assert m0 eq (cc^2 - 2*aa*bb - bb^2)/r0;
assert y0^2 eq L*m0^2 + M*m0 + N;
"STAGE", "canonical conic point";

/* Parametrize y^2=L*m^2+M*m+N from the canonical point. */
m := Kt!(
    m0 + ((2*L*m0 + M) - 2*y0*t)/(t^2 - L)
);
y := Kt!(y0 + t*(m - m0));
assert y^2 eq L*m^2 + M*m + N;
"STAGE", "conic parameterization";

/* Residual A*r^2+B*r+C after projection from the node over zero. */
A, B := ProjectionResidualCoefficients(m, aa, bb);
square_factor_1 := aa*m + bb + m;
square_factor_2 :=
    aa^2*m + 2*aa*bb + bb^2
    + 2*aa*m + bb*m + bb + m;
r :=
    (-B + 4*aa*square_factor_1*square_factor_2*y)/(2*A);
s := -(aa^2 + 2*aa + 2*bb) + r;
p := 2*aa*bb + bb^2 + m*r;

/* Common base coordinate z=phi(t1)=phi(t2). */
remainder_numerator :=
    p
    * (aa^2 + 2*aa + 2*bb + s)
    * (
        -aa^2*s - 4*aa*bb - 2*bb^2
        - 2*aa*s - 2*bb*s - s^2 + 2*p
    );
remainder_denominator :=
    -aa^4*p
    - 4*aa^3*bb*p
    - 4*aa^2*bb^2*p
    - 4*aa^3*s*p
    - 8*aa^2*bb*s*p
    - 4*aa^2*s^2*p
    + bb^4
    - 4*aa^2*bb*p
    - 12*aa*bb^2*p
    - 2*aa^2*s*p
    - 12*aa*bb*s*p
    - 4*aa*s^2*p
    + 4*aa^2*p^2
    - 6*bb^2*p
    - 4*bb*s*p
    - s^2*p
    + 4*aa*p^2
    + p^2;
z := remainder_numerator/remainder_denominator;
"STAGE", "base coordinate";

F1c := cc^2 + (aa^2 + 2*aa + 2*bb)*cc + 2*aa*bb + bb^2;
F2c := (2*aa + 1)*cc^2 + (aa^2 + 2*aa*bb + 2*bb)*cc + bb^2;
e := cc*F1c^2/F2c^2;

function OddMultiplicityPart(polynomial)
    if Degree(polynomial) le 0 then
        return Parent(polynomial)!1;
    end if;
    polynomial := Monic(polynomial);
    repeated := GCD(polynomial, Derivative(polynomial));
    layer := ExactQuotient(polynomial, repeated);
    odd_part := Parent(polynomial)!1;
    multiplicity := 1;
    while Degree(layer) gt 0 do
        next_layer := GCD(layer, repeated);
        exact_layer := ExactQuotient(layer, next_layer);
        if IsOdd(multiplicity) then
            odd_part *:= exact_layer;
        end if;
        layer := next_layer;
        repeated := ExactQuotient(repeated, next_layer);
        multiplicity +:= 1;
    end while;
    return Monic(odd_part);
end function;

function RationalSquareClass(function_value)
    numerator_part := OddMultiplicityPart(Numerator(function_value));
    denominator_part := OddMultiplicityPart(Denominator(function_value));
    common := GCD(numerator_part, denominator_part);
    return Monic(
        ExactQuotient(numerator_part, common)
        * ExactQuotient(denominator_part, common)
    );
end function;

function MultiplySquareClasses(left, right)
    common := GCD(left, right);
    return Monic(
        ExactQuotient(left, common)
        * ExactQuotient(right, common)
    );
end function;

components := [
    RationalSquareClass(z),
    RationalSquareClass(z - 1),
    RationalSquareClass(z - e),
    RationalSquareClass(s^2 - 4*p)
];
"STAGE", "component square classes";
branch_quartic := components[1];
for index in [2..#components] do
    branch_quartic := MultiplySquareClasses(
        branch_quartic,
        components[index]
    );
end for;
assert Degree(branch_quartic) eq 4;
"STAGE", "branch quartic";

coefficients := [Coefficient(branch_quartic, index) : index in [0..4]];
quartic_I :=
    12*coefficients[5]*coefficients[1]
    - 3*coefficients[4]*coefficients[2]
    + coefficients[3]^2;
complement_j :=
    256*quartic_I^3/Discriminant(branch_quartic);
"STAGE", "complement j";

/* The invariant lies in the critical quadratic field. */
j_critical := Kc!complement_j;
j_trace := F!Trace(j_critical);
j_norm := F!Norm(j_critical);
"STAGE", "trace and norm";

"BRANCH_QUARTIC_DEGREE", Degree(branch_quartic);
"J_CRITICAL", j_critical;
"J_TRACE", j_trace;
"J_NORM", j_norm;
"J_TRACE_NUMERATOR_FACTORS", Factorization(Numerator(j_trace));
"J_TRACE_DENOMINATOR_FACTORS", Factorization(Denominator(j_trace));
"J_NORM_NUMERATOR_FACTORS", Factorization(Numerator(j_norm));
"J_NORM_DENOMINATOR_FACTORS", Factorization(Denominator(j_norm));
"VERIFIED", true;
