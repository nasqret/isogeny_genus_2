SetLogFile("Example5.out");
"--------------------";

/*--------------------------------------------------------------*/
/*------------------------ PART 1 ------------------------------*/
/*--------------------------------------------------------------*/
        /*  
The first section takes a point on the moduli space of genus-2 degree-5 covers
        of elliptic curves, as given in Shaska's paper,
        and reconstruct the elliptic curve X, the genus 2 curve Y,
        and the map pi: Y -> X.
        
        We start with the point (a,b) in the moduli space.
        and a parametric presentation of the associated P1-cover.
    */

Q := Rationals();
P<t> := PolynomialRing(Q);

// Pick a point
a := 7;
b := 1;

// The map phi: P1 -> P1 is given by phi(t) = phi_num/phi_den, where
F1 := t^2 + (2*a + 2*b + a^2)*t + 2*a*b + b^2;
F2 := (2*a + 1)*t^2 + (a^2 + 2*a*b + 2*b)*t + b^2;

phi_num := t*F1^2;
phi_den := F2^2;

"We start with the degree 5 cover corresponding to the point",
    "a = ", a, ", b =", b,
    "in the moduli space provided by Shaska";
"--------------------";



    /*  
We recover X by computing the cover of PP^1,
        with double ramification over the branch points of the P1-cover.
    */
PP<u, e> := PolynomialRing(Q, 2);
C := Evaluate(phi_num, u) - e*Evaluate(phi_den, u);
A := Evaluate(Resultant(C, Derivative(C, 1), 1), [0,t]);
A := ChangeRing(A, Q);

ShaskaField<z> := SplittingField(A);
ShaskaField := OptimisedRepresentation(ShaskaField);
AssignNames(~ShaskaField, ["z"]);
PK<t> := PolynomialRing(ShaskaField);
fX := PK!SquarefreePart(A) div (ChangeRing(t, ShaskaField)-z);  //ATCHUNG!
"The elliptic curve X is defined by:", fX;
"with j-invariat", jInvariant(EllipticCurve(fX));
"--------------------";

phi_num := PK!phi_num;
phi_den := PK!phi_den;

    /*  
We recover Y by taking the fiber product of phi and X->P1,
        in practice: replace in y^2=f(x) the variable x by phi(t)
        to get an expression y^2=A(t)^2*B(t) and absorb s = (y/A).

        The map pi is (t,s) -> (x,y) = (phi(t), s*A(t)) from Y to X.
        Call A the adjusting_factor.
    */
composition := Evaluate(fX, phi_num/phi_den);
assert IsSquare(Denominator(composition));

fY := 1;
for factor in Factorisation(Numerator(composition)) do
    factor_pol := factor[1];
    factor_mult := factor[2];
    if factor_mult mod 2 ne 0 then
        fY *:= factor_pol;
    end if;
end for;



assert Genus(HyperellipticCurve(fY)) eq 2;
"The genus 2 curve Y is defined by", fY;

/*
a0 :=
    - b^4*(2*b^3*a + 4*b^3 - 2*z*a*b^2 + 7*b^2*a^2 + 8*z*b^2 + 4*b^2
    + 16*a*b^2 + 16*z*b*a + 6*a^3*b + 8*b*a
    + 2*z*a^2*b + 12*z*b + 16*b*a^2 + 13*z*a^2 + z*a^4 + 6*z*a^3 + 4*z + 12*z*a);
a1 :=
    - b^2*(12*b^3 + 12*b^4*a + 32*z*b*a - 6*a^4*b^2 + 44*b^2*a^3 + 6*b*a
    + 24*a*b + 10*a^3*b + 44*b^3*a^2 + 2*b*a
    + 52*b^3*a + 61*b^2*a^2 - 12*b*a^5 - 7*z*a^2 - 2*z*a + 12*b*z
    - 4*a^6 + 12*b^4 - a^4 - 40*z*a^3*b^2 - 16*z*b^3*a^2
    - 12*z*a^5 + 36*z*b^2 - 18*z*a^3 - 26*z*a^4 + 56*z*a*b^2
    + 4*a*z*b^3 + 2*z*a^2*b^2 - 20*z*a^3*b + 28*z*a^2*b
    + 2*z*a^6 + 24*z*b^3 + 4*z*b*a^5 - a^5 - 32*z*a^4*b);
a2 :=
    5*b^2*a^6 + 20*b^2*a^5 + 8*b*a^6 - 61*b^4*a^2 - 18*b^5*a - 56*b^4*a
    + 4*z*b*a + 5*a^4*b^2 - 18*b^2*a^3 - 24*z*b^4
    - 14*z*b^4*a - 4*z*b^2 + 8*z*b^3*a^4 + 2*b^3*a^5 - 54*b^3*a^3
    - 70*b^3*a^2 - 24*b^3*a - 14*b^2*a^2 + 4*a^4*b + 10*b*a^5
    - 6*z*a^7 + 64*z*a^3*b^3 + 38*z*a^4*b^2 + 54*z*a^3*b^2
    + 12*z*b^2*a^2 - 14*z*a^6*b - 10*z*b^2*a^5 - 4*z*a^7*b
    - 4*z*b^2 + 32*z*b^4 + 2*a^7*b - z*a^8 - 36*z*b^3
    - 12*z*a^5 - 12*z*b^2 - 4*z*a^4 - 28*z*a*b^2 - 64*z*a^3*b
    - 5*z*a^2*b^2 + 16*z*a^2*b + 28*z*a^4*b - 4*z*b*a^5
    - 13*z*a^6 - 12*b^5 - 12*b^4 + 34*z*a^3*b;
a3 :=
    (2*a + 1)*( z*a^4 - 2*a^3*b + 4*z*a^3 + 6*z*a^3*b - 4*b*a^2
    + 12*z*a^2*b^2 + 10*z*a^2*b - 9*b^2*a^2 + 5*z*a^2
    - 2*b*a + 2*z*a - 8*a*b^2 - 12*b^3*a + 8*a*z*b^3
    - 4*b^3 - 4*z*b - 4*b^4 - 12*z*b^2 - 8*z*b^3 );
*/
//fY_check := (t^3 + a*t^2 + b*t + c)*(4*c*t^3 + b^2*t^2 + 2*b*c*t + c^2);
//fY eq fY_check/Coefficients(fY_check)[7];
"--------------------";



adjusting_factor := FieldOfFractions(PK)!1;

for factor in Factorisation(Numerator(composition)) do
    factor_pol := factor[1];
    factor_mult := factor[2];
    if factor_mult mod 2 eq 0 then
        adjusting_factor *:= factor_pol^(factor_mult div 2);
    end if;
end for;

for factor in Factorisation(Denominator(composition)) do
    factor_pol := factor[1];
    factor_mult := factor[2];
    if factor_mult mod 2 eq 0 then
        adjusting_factor /:= factor_pol^(factor_mult div 2);
    end if;
end for;

assert IsConstant(adjusting_factor^2*fY/composition);

"The map pi has adjusting factor:", adjusting_factor;
"--------------------";
"--------------------";
























/*--------------------------------------------------------------*/
/*------------------------ PART 2 ------------------------------*/
/*--------------------------------------------------------------*/
    /*  
In this second part we **compute equations for W following Zeta's approach**:
        we condiser the following equation in the function field of Sym^2(Y)
        pi(x1, y1) + pi(x2, y2) = 0,
        where y1^2 = fY(x1) and y2^2 = fY(x2),
        abd "+" is the summation on the elliptic curve X. 

        The functions filed of Sym^2(Y) is the quotient of
            k(x1, x2, y1, y2)^s
        by the relations y1^2 = fY(x1) and y2^2 = fY(x2).
        Here s is the automorphism swapping x1 with x2 and y1 with y2.
        
        One can rewrite this field as the field
            k(x1+x2, x1*x2, y1+y2, y1*y2)
        with relations
            (y1+y2)^2 = fY(x1) + fY(x2) + 2*y1*y2.
            (y1*y2)^2 = fY(x1)*fY(x2).
        and denote these variables XX, YY, ZZ, WW.

        The main task is thus to rewrite the equation
            pi(x1, y1) + pi(x2, y2) = 0
        in terms of the symmetric functions XX, YY, ZZ, WW.
    */



K<x1, x2, y1, y2> := FieldOfFractions(PolynomialRing(ShaskaField, 4));

    /*
Automorphisms r and s generate a group isomorphic to D4,
        <s> fixes the subfield of symmetric functions,
        <s, r^2> fixes k(x1+x2,x1*x2,y1*y2),
        <s, r> fixes k(x1+x2,x1*x2)
    */ 
r := hom< K-> K | [x2, x1, y2, -y1] >;
s := hom< K-> K | [x2, x1, y2,  y1] >;

// Listing x(pi(x1,y1)), x(pi(x2,y2)), y(pi(x1,y1)), y(pi(x2,y2)):
pi_coordinates := [
    Evaluate(phi_num/phi_den, x1),
    Evaluate(phi_num/phi_den, x2),
    y1*Evaluate(adjusting_factor, x1),
    y2*Evaluate(adjusting_factor, x2)
];

// Or just impose the condition for the sum to be 0:
Weq_x  := (pi_coordinates[1] - pi_coordinates[2])/(x1-x2); // <-- i put the square to make it symmetric
Weq_y  := pi_coordinates[3] + pi_coordinates[4]; 


    /*
We write startingWeq in the symmetric functions XX, YY, ZZ, WW,
        that is, x1 + x2, x1*x2, y1 + y2, y1*y2.
        
        The idea is that we can do this by taking norms
        in the tower of extensions
        k(x1,x2,y1,y2)
        k(x1+x2,x1*x2,y1+y2,y1*y2)  <-- we start here;
                                        we want to write startingWeq as A+B*(y1+y2);
        k(x1+x2,x1*x2,y1*y2)        <-- take the trace for the automorphism sending y1+y2 to -y1-y2 to get 2*A
                                        we want to write A as A1+A2*(y1*y2); same for B;
        k(x1+x2,x1*x2)              <-- take the trace for the automorphism sending y1*y2 to -y1*y2 to get 2*A1, 2*B1
    */



PR := Parent(x1);
x1pr := PR.1; x2pr := PR.2; y1pr := PR.3; y2pr := PR.4;
fY_x1 := Evaluate(fY, x1pr);
fY_x2 := Evaluate(fY, x2pr);

function ReplaceSquaresInPoly(poly)
    /* This functions takes a polynomial in x1,x2,y1,y2
        and replaces y1^2 by fY(x1) and y2^2 by fY(x2).
        It does this by looking at the exponents of y1 and y2,
        writing them as 2*k + r, and replacing the squares by fY. */
    new := PR!0;
    mons := Monomials(poly);
    coeffs := Coefficients(poly);
    for i in [1..#mons] do
        m := mons[i];
        c := coeffs[i];
        exps := Exponents(m);
        e1 := exps[1]; e2 := exps[2]; e3 := exps[3]; e4 := exps[4];
        k3 := e3 div 2; r3 := e3 mod 2;
        k4 := e4 div 2; r4 := e4 mod 2;
        term := c * x1pr^e1 * x2pr^e2 * y1pr^r3 * y2pr^r4 * fY_x1^k3 * fY_x2^k4;
        new +:= term;
    end for;
    return new;
end function;

function ReplaceSquaresInRationalFunction(u)
    /* This functions takes a rational function in x1,x2,y1,y2
        and replaces y1^2 by fY(x1) and y2^2 by fY(x2).
        It does this by applying ReplaceSquaresInPoly
        to the numerator and denominator. */
    num_new := ReplaceSquaresInPoly(Numerator(u));
    den_new := ReplaceSquaresInPoly(Denominator(u));
    return num_new/den_new;
end function;

function GetCoefficientsViaTraceMethod(u)
    /* This function implements the method described above
        to write u in terms of the symmetric functions.
        
        It takes a symmetric (under the s action) rational function
        u in x1, y1, x2, y2
        and returns coefficients A1, A2, B1, B2 in k(x1+x2,x1*x2) such that
        u = A1 + A2*(y1*y2) + B1*(y1+y2) + B2*(y1+y2)*(y1*y2), i.e.
        u = A1 + A2*WW + B1*ZZ + B2*WW*ZZ.  */
    
    A := 1/2 * ( u + r(r(u)) );
    B := (u - A)/(y1+y2);

    A1 := 1/2 * ( A + r(A) );
    A2 := (A - A1)/(y1*y2);

    B1 := 1/2 * ( B + r(B) );
    B2 := (B - B1)/(y1*y2);

    U := A1 + A2*(y1*y2) + B1*(y1+y2) + B2*(y1+y2)*(y1*y2);
    assert U eq u;

    A1 := ReplaceSquaresInRationalFunction(A1);
    A2 := ReplaceSquaresInRationalFunction(A2);
    B1 := ReplaceSquaresInRationalFunction(B1);
    B2 := ReplaceSquaresInRationalFunction(B2);

    return [A1, A2, B1, B2];
end function;

AABBx := GetCoefficientsViaTraceMethod(Weq_x);
AABBy := GetCoefficientsViaTraceMethod(Weq_y);

    /*
Finally, we need to write A1, A2, B1, B2 in terms of the symmetric functions XX = x1+x2 and YY = x1*x2.
        We use the existing function IsSymmetric;
        recall that e1 = x1+x2 and e2 = x1*x2.
    */

PP<x1, x2> := PolynomialRing(ShaskaField, 2);
E<e1, e2> := PolynomialRing(ShaskaField, 2);

function Symmetrise(listofrationalfunctions)
    /* This function takes a list of rational functions in x1 and x2,
        symmetric in x1 and x2, and writes them as rational functions
        in e1 = x1+x2 and e2 = x1*x2. */
    newlist := [];
    for f in listofrationalfunctions do
        aa := Evaluate(Numerator(f), [PP.1, PP.2, 0, 0]);
        assert IsSymmetric(aa, E);
        _, a := IsSymmetric(aa, E);

        bb := Evaluate(Denominator(f), [PP.1, PP.2, 0, 0]);
        assert IsSymmetric(bb, E);
        _, b := IsSymmetric(bb, E);
        
        newlist cat:= [a/b];
    end for;
    return newlist;
end function;

// Apply the symmetrisation process to A1, A2, B1, B2:
symmAABBx := Symmetrise(AABBx);
symmAABBy := Symmetrise(AABBy);

// Apply the symmetrisation process to fY(x1)*fY(x2) and fY(x1)+fY(x2):
_, prodfY1fY2 := IsSymmetric(Evaluate(fY, PP.1)*Evaluate(fY, PP.2), E);
_, sumfY1fY2 := IsSymmetric(Evaluate(fY, PP.1) + Evaluate(fY, PP.2), E);




    /*
Finally, express everything in terms of
        XX = x1+x2,
        YY = x1*x2,
        ZZ = y1+y2,
        WW = y1*y2.
    */
PPP<XX, YY, ZZ, WW> :=  PolynomialRing(ShaskaField, 4);
RRR := FieldOfFractions(PPP);


AA1x := Evaluate(symmAABBx[1], [XX, YY]);
AA2x := Evaluate(symmAABBx[2], [XX, YY]);
BB1x := Evaluate(symmAABBx[3], [XX, YY]);
BB2x := Evaluate(symmAABBx[4], [XX, YY]); 

symmetrised_Weq_x := AA1x + AA2x*WW + BB1x*ZZ + BB2x*WW*ZZ;
NSEx := Numerator(symmetrised_Weq_x);
DSEx := Denominator(symmetrised_Weq_x);


AA1y := Evaluate(symmAABBy[1], [XX, YY]);
AA2y := Evaluate(symmAABBy[2], [XX, YY]);
BB1y := Evaluate(symmAABBy[3], [XX, YY]);
BB2y := Evaluate(symmAABBy[4], [XX, YY]); 

symmetrised_Weq_y := AA1y + AA2y*WW + BB1y*ZZ + BB2y*WW*ZZ;
NSEy := Numerator(symmetrised_Weq_y);
DSEy := Denominator(symmetrised_Weq_y);

equations_for_W := [
    NSEx,
    (WW^2 - Evaluate(prodfY1fY2, [XX, YY]) ),
    (ZZ^2 - Evaluate(sumfY1fY2, [XX, YY]) - 2*WW),
    NSEy
];


"The complementary curve is given by the following 4 equations
    in the 4 symmetric variables X=x1+x2, Y=x1*x2, Z=y1+y2, W=y1*y2:";
equations_for_W;
"--------------------";











/*--------------------------------------------------------------*/
/*------------------------ PART 3 ------------------------------*/
/*--------------------------------------------------------------*/
    /*
Check that the curve defined by equations_for_W in the 4-dimensional affine space
        with coordinates XX, YY, ZZ, WW is an elliptic curve.
    */
A4<X, Y, Z, W> := AffineSpace(ShaskaField, 4);
R := CoordinateRing(A4);

affine_Weqs := [ Evaluate(ff, [A4.1, A4.2, A4.3, A4.4]) : ff in equations_for_W];

ReducibleCurve := Scheme(A4, affine_Weqs);
time ReducibleCurve := Curve(ReducibleCurve);

F1orig := affine_Weqs[1];
F2orig := affine_Weqs[2];
F3orig := affine_Weqs[3];
F4orig := affine_Weqs[4];


    /*
One of the components of affine_Weqs[2] is linear in W.
        We use it to replace W with a rational function of X, Y
        in the other three equations.
    */
assert Degree(F3orig, W) eq 1;
Wexpression := Evaluate(-F3orig, [X,Y,Z,0]) / Coefficient(F3orig, W, 1);

F1 := Evaluate(F1orig, [X,Y,Z,Wexpression]);
F2 := Evaluate(F2orig, [X,Y,Z,Wexpression]);
assert Evaluate(F3orig, [X,Y,Z,Wexpression]) eq 0;
F3 := Evaluate(F4orig, [X,Y,Z,Wexpression]) div Z;

A3<X, Y, Z> := AffineSpace(ShaskaField, 3);
FinalCurve := Scheme(A3, [Evaluate(ff, [A3.1, A3.2, A3.3, 0]) : ff in [F1, F2, F3]]);
time FinalCurve := Curve(FinalCurve);

I := Ideal(FinalCurve);
FF1 := Generators(I)[1];
FF2 := Generators(I)[2];
FF3 := Generators(I)[3];

"The second equation is linear in W, we use it to remove the varibale W,
    we get 3 equations in 3 variables X, Y, Z.

The firts equation defines a SINGULAR genus 0 curve:";
    FF1;
"--------------------";


    /*
The firts equation identifies a genus 0 curve,
        while the other two equations define curves
        that are degree 4 extensions over the projective curve.
    
    The first thing to do is to find a parametrisation for BaseP1;
        fortunately, MAGMA has a fuction for that,
        unfortunately, it requires a rational point;
        we find one in a finite field extension.
    */
A2<xx, yy> := AffineSpace(ShaskaField, 2);
equations_for_BaseP1 := Evaluate(FF1, [A2.1, A2.2, 0]);
time BaseP1 := ProjectiveClosure(Curve(Scheme(A2, equations_for_BaseP1)));

fPP := PK!Evaluate(equations_for_BaseP1, [t,0]);
time K := SplittingField(fPP);
r := Roots(fPP, K)[1,1];

time BaseP1 := ChangeRing(BaseP1, K);
PP := BaseP1![r, K!0, K!1];
time par := Parametrization(BaseP1, PP);

A2<X, Z> := AffineSpace(K, 2);
XXX := Evaluate(DefiningEquations(par)[1], [X,1]);
YYY := Evaluate(DefiningEquations(par)[2], [X,1]);
DDD := Evaluate(DefiningEquations(par)[3], [X,1]);


G1 := Evaluate(FF1, [XXX/DDD, YYY/DDD, Z]);
G2 := Evaluate(FF2, [XXX/DDD, YYY/DDD, Z]);
G3 := Evaluate(FF3, [XXX/DDD, YYY/DDD, Z]);

assert G1 eq 0;	        // this is 0, because I'm evaluating the defining polynomial at a parametrisation
G2 := Numerator(G2);
G3 := Numerator(G3);

time gB2 := GCD(G2, G3);	    // the correct irreducible component is the only common component between the equations coming from x and y

"We find a rational non-singular point over a small field extension,
        and use it to determine a parametrisation of the P1 component.

    We substitute the parametrisation in the remaining two equations,
        each of which defines a REDUCIBLE cover of the base P1.

    These  twocovers have exactly one component in common,
        which is the degree 2 cover defined by the following equation:";
    gB2;
"--------------------";

    /*
Finally, we desingularise by reassorbing the quadratic factors.
        More specifically, the defining polynomial is of the form
            A_2(XX)*Z^2 + A_0(XX) = 0.
        We multiply by A2 and reassorb into Z the square factor
        of A0*A2. This gives a nice degree 4 equation,
        i.e. the Weierstrass** form for the complementary elliptic curve.
    */


// Extract A_0, A_2.
A0 := Evaluate(gB2, [X, 0]);
A2 := (gB2-A0) div Z^2;
assert A2*Z^2 + A0 eq gB2;

/*
At the level of function fields, I'm taking the square root of -A0/A2;
this is the same as taking the square root of -A0*A2. I factor A0*A2
and only keep the factors of odd multiplicity.
*/

facs := Factorisation(A0*A2);
facs := [f : f in facs | f[2] mod 2 eq 1];
//facs; // just to check that there are no factors of multiplicity 3
facs := [ f[1] : f in facs ];

/*
I'm probably losing track of the leading coefficient, so this is a quadratic
twist of the correct curve. Tant pis.
*/
finalEq := &* facs;

S<x> := PolynomialRing(K);
h := hom<Parent(finalEq) -> S | [x, 0]>;
finalEq := h(finalEq);
C := HyperellipticCurve(finalEq);
E := EllipticCurve(C);


"After resolving singularities, we get the Weierstrass equation";
    finalEq;
"with the following rational jInvariant:", jInvariant(E);
"--------------------";