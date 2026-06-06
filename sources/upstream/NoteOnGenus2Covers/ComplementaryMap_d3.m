SetLogFile("Example3_map.out");
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

Pbase := ReducibleCurve![0,0,0,-25/4];
EProj := ProjectiveClosure(ReducibleCurve);
PProj := EProj!Pbase;
Eprime, map := EllipticCurve(EProj, PProj);


CY := HyperellipticCurve(fY);



function ImageOnEPrimeScarsa(P : Translation := Identity(Eprime))
	K := Parent(P[1]);

	WK   := BaseChange(ReducibleCurve, K);
	EK   := BaseChange(Eprime, K);
	// mapK := map(K);

	AK := Ambient(WK);
	XX := AK.1; YY := AK.2; ZZ := AK.3; WW := AK.4;

	// fixed base divisor on W
	xp0 := K!5;
	yp0 := K!(-375/2);
	div10 := YY - xp0*XX + xp0^2;
	div20 := WW - yp0*ZZ + yp0^2;
	DpBaseK := Divisor(WK, Ideal([div10, div20]));

	WbaseK := WK![K!0, K!0, K!0, K!(-25/4)];

	// divisor corresponding to "one point in the support is P"
	xp := P[1];
	yp := P[2];
	div1 := YY - xp*XX + xp^2;
	div2 := WW - yp*ZZ + yp^2;
	Dp := Divisor(WK, Ideal([div1, div2]));
	if Degree(Dp) ne 2 then
		error "Unexpected degree for Dp";
	end if;

	D0 := Dp - DpBaseK + Divisor(WbaseK);
	RRSpace, RRmap := RiemannRochSpace(D0);
	imgP := Support(Divisor(RRmap(RRSpace.1)) + D0)[1];
	QW := RepresentativePoint(imgP);


	imageP := EK![Evaluate(g, [QW[i] : i in [1..5]]) : g in DefiningPolynomials(map)];
	if Translation ne Identity(Eprime) then
		TranslationK := EK!Translation;
		return imageP-TranslationK;
	else
		return imageP;
	end if;
end function;


function ImageOnEPrime(P : Translation := Identity(Eprime))
	K := Parent(P[1]);

	WK   := BaseChange(ReducibleCurve, K);
	EK   := BaseChange(Eprime, K);
	// mapK := map(K);

	AK := Ambient(WK);
	XX := AK.1; YY := AK.2; ZZ := AK.3; WW := AK.4;

	// fixed base divisor on W
	xp0 := K!5;
	yp0 := K!(-375/2);
	div10 := YY - xp0*XX + xp0^2;
	div20 := WW - yp0*ZZ + yp0^2;
	DpBaseK := Divisor(WK, Ideal([div10, div20]));

	WbaseK := WK![K!0, K!0, K!0, K!(-25/4)];

	// divisor corresponding to "one point in the support is P"
	xp := P[1];
	yp := P[2];
	div1 := YY - xp*XX + xp^2;
	div2 := WW - yp*ZZ + yp^2;
	Dp := Divisor(WK, Ideal([div1, div2]));
	if Degree(Dp) ne 2 then
		error "Unexpected degree for Dp";
	end if;
	if #Support(Dp) ne 1 then
		error "Non abbiamo voglia di implementarlo in questo momento";
	end if;
	G := RepresentativePoint(Support(Dp)[1]);
	L := Parent(G[1]);
	
	G0 := RepresentativePoint(Support(DpBaseK)[1]);
	L0 := Parent(G0[1]);
	
	Ltot := Compositum(AbsoluteField(L), AbsoluteField(L0));
	
	ELtot := ChangeRing(EK, Ltot);
	imageP0 := ELtot![Evaluate(g, [G0[i] : i in [1..5]]) : g in DefiningPolynomials(map)];
	imageP := ELtot![Evaluate(g, [G[i] : i in [1..5]]) : g in DefiningPolynomials(map)];


	D0 := Dp - DpBaseK + Divisor(WbaseK);
	RRSpace, RRmap := RiemannRochSpace(D0);
	imgP := Support(Divisor(RRmap(RRSpace.1)) + D0)[1];
	QW := RepresentativePoint(imgP);


	imageP := EK![Evaluate(g, [QW[i] : i in [1..5]]) : g in DefiningPolynomials(map)];
	if Translation ne Identity(Eprime) then
		TranslationK := EK!Translation;
		return imageP-TranslationK;
	else
		return imageP;
	end if;
end function;


function QuadraticPointFromT(t0)
	d := Evaluate(fY, t0);
	if IsSquare(d) then
		error "Need a nonsquare value";
	end if;

	// Write d = num/den and adjoin sqrt(num*den)
	num := Numerator(d);
	den := Denominator(d);

	S<z> := PolynomialRing(Q);
	K<rt> := NumberField(z^2 - num*den);

	CYK := BaseChange(CY, K);
	PK := CYK![K!t0, rt/den];   // because (rt/den)^2 = num/den = d
	PK2 := CYK![K!t0, -rt/den];   // because (rt/den)^2 = num/den = d


	return PK, PK2, K, rt/den;
end function;


/*
Compute the normalising translation: we know that
f(P) + f(iota(P)) is constant, and want this constant
to be 0. Hence, we first compute f(P) + f(iota(P))
for a random P, and then divide the result by 2.
With this translation, the map to E' commutes
with the hyperelliptic involutions.
*/

P, P2, K := QuadraticPointFromT(6);
Q := ImageOnEPrime(P);
Q2 := ImageOnEPrime(P2);
EprimeK := ChangeRing(Eprime, K);
Q := EprimeK![Q[1], Q[2]];
Q2 := EprimeK![Q2[1], Q2[2]];
P := Q+Q2;
P := Eprime!P;
Translation := DivisionPoints(P,2)[1];


/*
Now we interpolate.
*/

samplesX := [];
samplesY := [];

B := 3;

for a in [-B..B] do
for b in [1..B] do
	if GCD(a,b) ne 1 then
		continue;
	end if;

	t0 := a/b;
	d := Evaluate(fY, t0);
	if d eq 0 or IsSquare(d) then
		continue;
	end if;

	P, _, K, s0 := QuadraticPointFromT(t0);
	Qimg := ImageOnEPrime(P : Translation := Translation);

	// Skip points at infinity
	if Qimg[3] eq 0 then
		continue;
	end if;

	// With the normalisation explained above, these should be rational:
	boolx, xrat := IsCoercible(Rationals(), Qimg[1]);
	booly, yrat := IsCoercible(Rationals(), Qimg[2]/s0);

	if boolx and booly then
		Append(~samplesX, <t0, xrat>);
		Append(~samplesY, <t0, yrat>);
		print "t0 =", t0, "  x(E') =", xrat, "  y(E')/s =", yrat;
	end if;
end for;
end for;






function InterpolateRational(samples, m, n)
	// Recover f(t)=N(t)/D(t) with deg N <= m, deg D <= n,
	// and D monic of degree n.
	QT<T> := PolynomialRing(Rationals());

	Nvars := (m+1) + n;   // coefficients of N and the lower coeffs of D
	M := ZeroMatrix(Rationals(), #samples, Nvars);
	rhs := ZeroMatrix(Rationals(), #samples, 1);

	for i in [1..#samples] do
	    t0 := samples[i][1];
	    v0 := samples[i][2];

	    // N(t0) = v0*D(t0) = v0*(c0 + ... + c_{n-1} t0^{n-1} + t0^n)
	    for j in [0..m] do
	        M[i][j+1] := t0^j;
	    end for;

	    for j in [0..n-1] do
	        M[i][m+2+j] := -v0*t0^j;
	    end for;

	    rhs[i][1] := v0*t0^n;
	end for;

	bool, sol := IsConsistent(Transpose(M), Transpose(rhs));
	if not bool then
		error "No solution for these degree bounds";
	end if;
	sol := Transpose(sol);
	num := &+[ sol[j][1] * T^(j-1) : j in [1..m+1] ];
	den := T^n + &+[ sol[m+1+j][1] * T^(j-1) : j in [1..n] ];

	return num/den;
end function;

xCoord := InterpolateRational(samplesX[1..8], 3, 3);
yCoord := InterpolateRational(samplesY[1..13], 6, 6);


/*
Finally, construct (and hence verify) the map
*/

CY := HyperellipticCurve(fY);
K := FunctionField(CY);

t := K.1;
s := K.2;

QT<T> := Parent(Numerator(xCoord));

Rt := Evaluate(Numerator(xCoord), t) / Evaluate(Denominator(xCoord), t);
St := Evaluate(Numerator(yCoord), t) / Evaluate(Denominator(yCoord), t);

// Candidate map Y -> E'
phi := map< CY -> Eprime | [Rt, s*St, 1] >;

Eprime1, map1 := MinimalModel(Eprime);

map := phi*map1;

Degree(map);

/*
Final check
*/
fx := -6 * ( t^3 + t^2 + 35/24*t - 25/24 ) / (t^3 + 4/5*t^2 + 2*t + 5/4);
fy := -3 * ( t^3 - 55/6*t^2 - 25/6*t - 125/24 ) / (t^3 + 4/5*t^2 + 2*t + 5/4)^2;
phiFinal := map< CY -> Eprime1 | [fx, s*fy, 1] >;