SetLogFile("Example3.out");
"--------------------";

/*--------------------------------------------------------------*/
/*------------------------ PART 1 ------------------------------*/
/*--------------------------------------------------------------*/
    /*  
The first section takes a point on the moduli space of genus-2 degree-3 covers
        of elliptic curves, as given in Khun's paper,
        and reconstruct the elliptic curve X, the genus 2 curve Y,
        and the map pi: Y -> X.
        
        We start with the point (a,b) in the moduli space.
        and a parametric presentation of the associated P1-cover.
    */

Q := Rationals();
P<t> := PolynomialRing(Q);

/*  In [Kuh88, Section 6] there is a parametrization of all such covering maps,
    we choose a nice looking one. Feel free to tweak the parameters
    to get more examples. */
a := 3;
b := 4;
c := 5;

/*  We have a paremetric description of both phi.... */
phi_num := t^2;
phi_den := t^3+a*t^2+b*t+c;



    /*  
We recover X by computing the cover of PP^1,
        with double ramification over the branch points of the P1-cover.
    */
PP<u, e> := PolynomialRing(Q, 2);
C := Evaluate(phi_num, u) - e*Evaluate(phi_den, u);
A := Evaluate(Resultant(C, Derivative(C, 1), 1), [0,t]);
A := ChangeRing(A, Q);
fX := SquarefreePart(A) div t;  //ATCHUNG!
"The elliptic curve X is defined by:", fX;
//X := EllipticCurve(fX);
"--------------------";



    /*  
We recover Y by taking the fiber product of phi and X->P1,
        in practice: replace in y^2=f(x) the variable x by phi(t)
        to get an expression y^2=A(t)^2*B(t) and absorb s = (y/A).

        The map pi is (t,s) -> (x,y) = (phi(t), s*A(t)) from Y to X.
        Call A the adjusting_factor.
    */
composition := Evaluate(fX, phi_num/phi_den);

fY := 1;
for factor in Factorisation(Numerator(composition)*SquarefreePart(Denominator(composition))) do
    factor_pol := factor[1];
    factor_mult := factor[2];
    if factor_mult mod 2 ne 0 then
        fY *:= factor_pol;
    end if;
end for;

"The genus 2 curve Y is defined by", fY;

fY_check := (t^3 + a*t^2 + b*t + c)*(4*c*t^3 + b^2*t^2 + 2*b*c*t + c^2);
fY eq fY_check/Coefficients(fY_check)[7];
"--------------------";

"To normalize the model of Y,
    we take a twist of E:
    instead of y^2=...,
    we consider d*y^2=...
    with d =", Coefficients(Numerator(composition))[10];

"--------------------";


adjusting_factor := FieldOfFractions(P)!1;

for factor in Factorisation(Numerator(composition)*SquarefreePart(Denominator(composition))) do
    factor_pol := factor[1];
    factor_mult := factor[2];
    if factor_mult mod 2 eq 0 then
        adjusting_factor *:= factor_pol^(factor_mult div 2);
    end if;
end for;

for factor in Factorisation(Denominator(composition)*SquarefreePart(Denominator(composition))) do
    factor_pol := factor[1];
    factor_mult := factor[2];
    if factor_mult mod 2 eq 0 then
        adjusting_factor /:= factor_pol^(factor_mult div 2);
    end if;
end for;

assert adjusting_factor^2*fY eq composition/Coefficients(Numerator(composition))[10];

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



K<x1, x2, y1, y2> := FieldOfFractions(PolynomialRing(Q, 4));

    /*
Automorphisms r and s generate a group isomorphic to D4,
        <s> fixes the subfield of symmetric functions,
        <s, r^2> fixes k(x1+x2,x1*x2,y1*y2),
        <s, r> fixes k(x1+x2,x1*x2)
    */ 
r := hom< K-> K | [x2, x1, y2, -y1] >;
s := hom< K-> K | [x2, x1, y2,  y1] >;



// Group law on elliptic curve; taken from Silverman I, Algorithm 2.3.
// Notice that it's improper to call these coordinates x and y.
// Also, this is just the x coordinate of the sum!!
a1 := 0;
a2 := Coefficient(fX, 2);
a3 := 0;

lambda := (y2-y1)/(x2-x1);
nu := (y1*x2-y2*x1)/(x2-x1);

group_law := (lambda)^2 + a1 * (lambda) - a2 - (x1 + x2);
y_group_law := - (lambda + a1) - nu - a3;

// Listing x(pi(x1,y1)), x(pi(x2,y2)), y(pi(x1,y1)), y(pi(x2,y2)):
pi_coordinates := [
    Evaluate(phi_num/phi_den, x1),
    Evaluate(phi_num/phi_den, x2),
    y1*Evaluate(adjusting_factor, x1),
    y2*Evaluate(adjusting_factor, x2)
];


// Or just impose the condition for the sum to be 0:
Weq_x  := (pi_coordinates[1] - pi_coordinates[2]) / (x1-x2); // <-- i put the square to make it symmetric
Weq_y  := pi_coordinates[3] + pi_coordinates[4]; // <-- this is not needed, i believe, but ill plug it in just because i can




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

PP<x1, x2> := PolynomialRing(Q, 2);
E<e1, e2> := PolynomialRing(Q, 2);

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
PPP<XX, YY, ZZ, WW> :=  PolynomialRing(Q, 4);
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

    /*
Check that the curve defined by equations_for_W in the 4-dimensional affine space
        with coordinates XX, YY, ZZ, WW is an elliptic curve.
    */
A4<X, Y, Z, W> := AffineSpace(Q, 4);
R := CoordinateRing(A4);

affine_Weqs := [ Evaluate(ff, [A4.1, A4.2, A4.3, A4.4]) : ff in equations_for_W];

ReducibleCurve := Scheme(A4, affine_Weqs);
ReducibleCurve := Curve(ReducibleCurve);

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
F3 := Evaluate(F4orig, [X,Y,Z,Wexpression]);

A3<X, Y, Z> := AffineSpace(Q, 3);
FinalCurve := Scheme(A3, [Evaluate(ff, [A3.1, A3.2, A3.3, 0]) : ff in [F1, F2, F3]]);
time FinalCurve := Curve(FinalCurve);

I := Ideal(FinalCurve);
FF1 := Generators(I)[1];
FF2 := Generators(I)[2];
FF3 := Generators(I)[3];

"The second equation is linear in W, we use it to remove the varibale W,
    we get 3 equations in 3 variables X, Y, Z.";
"--------------------";


    /*
The firts equation identifies a genus 0 curve,
        while the other two equations define curves
        that are degree 4 extensions over the projective curve.
    
    The first thing to do is to find a parametrisation for BaseP1;
        fortunately, it is already linear in X.
    */

assert Degree(FF1, X) eq 1;
Xexpression := Evaluate(-FF1, [0,Y,Z]) / Coefficient(FF1, X, 1);

assert Evaluate(FF1, [Xexpression,Y,Z]) eq 0;
G1 := Evaluate(FF2, [Xexpression,Y,Z]);
G2 := Evaluate(FF3, [Xexpression,Y,Z]);
G := GCD(G1, G2);


/*
Normalising hyperelliptic equations is trivial: you just reabsorb
the square factors. What's left is conveniently of degree 4, hence
a genus 1 curve. In this case it also has a rational point at (0,0)
(I suspect this is not a coincidence), so it's now easy to make it
into an elliptic curve
*/

Q<x> := PolynomialRing(Rationals());
fWsingular := -Evaluate(G, [0, x, 0]);
fW := &*[ factor[1] : factor in Factorisation(fWsingular) | factor[2] mod 2 eq 1 ]; 
E := HyperellipticCurve( fW );
E := EllipticCurve(E);


"We have succesfully found the complementary elliptic curve:", jInvariant(E) eq (256*(3*b-a^2)^3)/(27*c^2-18*a*b*c+4*a^3*c+4*b^3-a^2*b^2); // this is the j-invariant of the complementary curve as given in Shaska's paper, so it seems we are on the right track!
E; // this is my guess for the complementary curve.

