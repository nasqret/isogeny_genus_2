# Executable Examples

## Degree 5: a full exact map

For $(a,b)=(7,1)$, let $e$ satisfy

$$
289e^2-605e+289=0.
$$

The script `census_degree5_family.sage` constructs a squarefree quintic
$F_e(x)$, the genus-2 curve

$$
C_e:y^2=F_e(x),
$$

the Legendre elliptic curve

$$
E_e:Y^2=t(t-1)(t-e),
$$

and the degree-5 map with

$$
t=x\left(\frac{F_1(x)}{F_2(x)}\right)^2.
$$

The $Y$-coordinate multiplier is recovered by exact squarefree
factorization, and the target equation is checked as an identity over
$\mathbf Q(e)(x)$.

## Degree 6: a primitive even-degree benchmark

The rational point

$$
(r,s,z)=\left(-9,\frac92,39366\right)
$$

on Kumar's $Y_-(36)$ gives, after
$x_{\mathrm{raw}}=3^{16}x$ and
$y_{\mathrm{raw}}=3^{48}y$,

$$
C:\quad y^2=F(x)
=x^6-6x^5+7x^4+\frac{28}{9}x^3
-\frac{16}{3}x^2-\frac{16}{9}x+\frac{16}{81}.
$$

The two rational elliptic factors are

$$
E_1:Y^2=X^3-27X+90,\qquad
E_2:Y^2=X^3+81X-162,
$$

with $j(E_1)=-972$ and $j(E_2)=1296$. Hasse-Witt matrices at six
good primes identify the pullback lines as $x\,dx/y$ and $dx/y$.

For the first map,

$$
X_1=
\frac{
3x^6-30x^5+81x^4-\frac{296}{3}x^3
+\frac{184}{3}x^2-\frac{848}{27}
}{
x^6-6x^5+9x^4+\frac{40}{9}x^3
-\frac{40}{3}x^2+\frac{400}{81}
},
$$

and

$$
Y_1=-\frac{yX_1'}{2x}.
$$

The complementary map exhibits the even-degree phenomenon absent from the
degree-$7$ benchmark:

$$
X_2=a(x)+y\,b(x)
$$

is not contained in $\mathbf Q(x)$. Its common denominator is

$$
\left(x+\frac12\right)^2
\left(x^3+\frac32x^2+\frac25x-\frac{2}{45}\right)^2.
$$

The exact numerators are recorded in `sage_degree6_recovery.json`. The
differential scale is

$$
c_2=\frac23.
$$

It is reconstructed from the certified congruences

$$
c_2^2\equiv79\pmod{101},\qquad
c_2^2\equiv92\pmod{103},
$$

whose CRT rational reconstruction is $4/9$. Writing
$X_2=a+yb$, the second coordinate is derived exactly as

$$
Y_2=
\frac{
F b'+\frac12bF'+a'y
}{2c_2}.
$$

SageMath verifies $Y_2^2=X_2^3+81X_2-162$ in
$\mathbf Q(C)$ and computes $\deg(X_2)=12$, hence
$\deg(C\to E_2)=6$. Remote Magma independently returns degree $6$ for
both maps. Neither target has a rational $2$- or $3$-isogeny, so both
degree-$6$ maps are primitive over $\mathbf Q$.

For the first quotient, Magma computes the generic fiber group as
$S_6$ of order $720$. Its discriminant is

$$
\frac{2^{43}}{3^6}(25T+159)(T^3-27T+90)^2.
$$

The unique quadratic subfield of the $S_6$ splitting field has square class
$2(25T+159)$, whereas the elliptic base adjoins
$\sqrt{T^3-27T+90}$. These square classes are distinct, so the elliptic base
change preserves $S_6$. This benchmark is therefore not the exceptional
$\operatorname{PGL}_2(\mathbf F_5)$ case.

## Degree 7: a primitive benchmark

Kumar's rational curve on $Y_-(49)$ gives at $u=1$

$$
\begin{aligned}
C:\quad y^2={}&(x^3+23x^2+552x+17940)\\
&\cdot\left(x^3-\frac{46}{5}x^2
+\frac{3013}{4}x-\frac{25645}{4}\right).
\end{aligned}
$$

The two elliptic invariants are

$$
j_1=-\frac{20285403817}{279936},\qquad
j_2=-\frac{97967097}{128}.
$$

Compatible rational twists are

$$
\begin{aligned}
E_1&:y^2+xy=x^3-6077163x-5835183183,\\
E_2&:y^2+xy+y=x^3-x^2-15705x+762297.
\end{aligned}
$$

The genus-2 Frobenius polynomial equals the product of the two elliptic
Frobenius polynomials at all 41 good primes $11\leq p<200$. The two maps
have now also been recovered exactly.

For the first map, put

$$
\begin{aligned}
N_1={}&x^7+\frac{2415}{2}x^5+\frac{7245}{2}x^4
+\frac{41306965}{192}x^3+\frac{393877001}{96}x^2\\
&-\frac{90651235955}{768}x
+\frac{1179635972075}{768},\\
D_1={}&x^3-\frac{46}{5}x^2+\frac{3013}{4}x-\frac{25645}{4}.
\end{aligned}
$$

Then

$$
X_1=\frac{576N_1}{2401D_1},
\qquad
Y_1=\frac{yX_1'}{2(49/12)}.
$$

SageMath verifies

$$
F(x)(X_1')^2
=4\left(\frac{49}{12}\right)^2
\left(X_1^3-7876003275X_1-272222678576250\right).
$$

The missing $x^6$ coefficient in $N_1$ gives
$\operatorname{Tr}(x)=0$, so the complementary eigenform is
$x\,dx/y$. Put

$$
\begin{aligned}
N_2={}&\frac{10465}{4}x^7+\frac{197225}{8}x^6
+\frac{164727955}{64}x^5+\frac{1305770375}{64}x^4\\
&+\frac{36305600625}{64}x^3
-\frac{1306013384375}{64}x^2
-\frac{232046932796875}{16},\\
D_2={}&(x^3+23x^2+552x+17940)
\left(x^2-\frac{115}{24}x+\frac{7475}{24}\right)^2.
\end{aligned}
$$

The second map is

$$
X_2=\frac{N_2}{D_2},
\qquad
Y_2=\frac{yX_2'}{2(-49/60)x},
$$

and satisfies

$$
F(x)(X_2')^2
=4\left(\frac{49}{60}\right)^2x^2
\left(X_2^3-20353275X_2+35382561750\right).
$$

The positive point at infinity maps to

$$
\left(\frac{10465}{4},-\frac{51175}{8}\right),
$$

which is $-7(29,-590)$ on the original second elliptic model. Remote
Magma independently constructs both morphisms and returns degree $7$ for
each. Since $7$ is prime, both maps are primitive.

## Degree 8: a primitive full-function-field benchmark

The rational point

$$
(r,s,z)=(4,-2,-1280)
$$

on Kumar's $Y_-(64)$ gives the normalized source

$$
C:\quad y^2=x^6+8x^4+20x^3+68x^2+240x+396.
$$

Its two rational elliptic factors are

$$
\begin{aligned}
E_1&:Y^2=X^3-X^2-5833X+207037,\\
E_2&:Y^2=X^3-X^2+7X-3,
\end{aligned}
$$

with $j(E_1)=-8780800/2187$ and $j(E_2)=5120/3$. Hasse-Witt
eigenvectors at six good primes identify the pullback lines as $dx/y$ and
$(1+2x)dx/y$.

The compact quotient has differential scale $2$ and

$$
X_1=
\frac{
x^8+4x^7+12x^6+32x^5+87x^4+220x^3+444x^2+360x-8
}{
x^4+4x^3+8x^2+8x+4
},
\qquad
Y_1=\frac{yX_1'}{4}.
$$

For the complement,

$$
X_2=a(x)+y\,b(x)
$$

has degree $16$ as a function on $C$ and common denominator

$$
\left(
x^7-\frac{4357}{12}x^6+314x^5-\frac{25905}{8}x^4
-\frac{3285}{2}x^3-\frac{69039}{2}x^2-35073x-87723
\right)^2.
$$

The exact numerators are stored in `sage_degree8_recovery.json`. The
differential scale is $2$, reconstructed from the roots $\pm2$ modulo
$61$ and $67$. If $F$ is the source sextic, then

$$
Y_2=
\frac{
F b'+\frac12bF'+a'y
}{
4(1+2x)
}.
$$

SageMath verifies both target equations and both degree-$8$ assertions.
Remote Magma independently constructs the morphisms and also computes
$\#\operatorname{Aut}_{\mathbf Q}(C)=2$. Since neither target has a rational
$2$-isogeny, this excludes both degree-$2$ isogeny factors and the remaining
multiplication-by-$2$ possibility through a degree-$2$ elliptic quotient.
Both maps are therefore primitive over $\mathbf Q$.

For the compact quotient, Magma computes the generic fiber group as $S_8$ of
order $40320$. Its discriminant is

$$
-3276800000
\left(T^3-T^2-5833T+207037\right)^3.
$$

The discriminant square class is $-5$ times the elliptic-base cubic, so the
elliptic quadratic extension does not absorb the unique quadratic subfield
of the $S_8$ closure. The degree-$8$ elliptic cover retains full $S_8$
monodromy.

## Degree 9: primitive maps with CRT-reconstructed centers

The rational point

$$
(r,s,z)=(3,-7,-29280)
$$

on Kumar's $Y_-(81)$ gives the normalized source

$$
\begin{aligned}
C:\quad y^2={}&x^6-9038618392x^4-64880615814700x^3\\
&+23434251437448181208x^2
&+276514602725620514127600x\\
&-12176183106883876734347363424.
\end{aligned}
$$

Frobenius filtering among $512$ signed twist classes selects

$$
\begin{aligned}
E_1:\quad Y^2+Y={}&X^3-X^2-1604677999942163X\\
&-205661103401997979787347,\\
E_2:\quad Y^2+Y={}&X^3-X^2-6547160054952023739513X\\
&+203904847526895684592439318144228.
\end{aligned}
$$

Their pullback eigenforms and scales are

$$
(231434+9x)\frac{dx}{y},\quad c_1=1,
\qquad
\frac{dx}{y},\quad c_2=-24806.
$$

Exact finite-field map searches and CRT reconstruct the two finite images of
infinity:

$$
P_1=\left(
\frac{1162836225963}{5041},
-\frac{1224177442475117122}{357911}
\right)
$$

from a $128$-bit modulus and

$$
P_2=\left(
\frac{14623882010512642188}{314743081},
-\frac{528607451220336034930422397}{5583857000021}
\right)
$$

from a $184$-bit modulus. The exact degree-$(9,9)$ rational functions
$X_1(x)$ and $X_2(x)$ are stored in `sage_degree9_recovery.json`.
SageMath certifies both target identities, and remote Magma independently
returns degree $9$ for each morphism.

Neither target has a rational $3$-isogeny, so both degree-$9$ maps are
primitive over $\mathbf Q$. For the first quotient, modular cycle types
$(1,3,5)$ and $(2,7)$ force the generic group to be $S_9$. Its discriminant
square class is

$$
359687\left(1842229401671T+98280453222687553920\right),
$$

which is coprime to the elliptic branch cubic. Hence the elliptic cover
retains full $S_9$ monodromy.

## Degrees 20 and 80: exact nonprimitive maps

Starting from the degree-5 map above, the script
`verify_composed_high_degree_maps.sage` applies the exact elliptic doubling
formulas once and twice. It certifies maps

$$
C_e\longrightarrow E_e
$$

of degrees

$$
5\cdot 2^2=20,\qquad 5\cdot 4^2=80.
$$

For each map, SageMath verifies the target equation in the function field and
checks the rational-function degree. These are practical stress tests for the
high-degree engine, but they are nonprimitive.
