# Algorithms for Degrees 6 and Beyond

## Engine A: direct symmetric self-fiber

Input: explicit $C$, $E$, and $f:C\to E$.

1. descend to the rational map $\phi:\mathbf P^1\to\mathbf P^1$;
2. compute the divided self-fiber equation;
3. rewrite it in symmetric coordinates;
4. factor and select the non-diagonal component;
5. normalize and compute its genus;
6. lift through the double-cover equations;
7. convert the resulting genus-one curve to a Weierstrass model;
8. reconstruct $f'$ and verify its degree and target identity.

This is the preferred route when a compact map is already known.

## Engine B: eigenform-guided map recovery

Input: a genus-2 curve $C:y^2=F(x)$ and candidate elliptic factor $E$.

Every pulled-back invariant differential has the form

$$
f^*\left(\frac{dX}{Y}\right)
=(r+sx)\frac{dx}{y}.
$$

For maps normalized so that the hyperelliptic involution acts as elliptic
negation, use

$$
X=\frac{A(x)}{B(x)},\qquad
Y=\frac{y\,C(x)}{B(x)^q}
$$

with degree bounds forced by $n$. In the general even-degree case the correct
ansatz is

$$
X=a(x)+y\,b(x),\qquad Y=c(x)+y\,d(x).
$$

The elliptic equation and differential identity give polynomial equations in
the coefficients and the eigenform line. Solve them modulo several good
primes, Hensel lift when useful, reconstruct rational coefficients by CRT,
and certify the final characteristic-zero identity.

This is the main map-recovery route for Kumar's degree $6$ through $11$
families.

### Centering the formal expansion

The source expansion point need not map to the elliptic origin. If it maps to
a rational point $P\in E(k)$, first construct the formal point $R(z)$ at
the origin from the integrated eigenform, then use the elliptic group law to
expand the $X$-coordinate of

$$
P+R(z).
$$

This distinction changes the Pade degree bounds. In the degree-7 benchmark,
the first map sends infinity to the origin and has pattern $(7,3)$. The
complementary map sends the two infinities to finite opposite points and has
pattern $(7,7)$. Assuming $(7,5)$ incorrectly forces nonexistent tail
equations.

### Reusable exact implementation

The SageMath library
[`elliptic_cover_recovery.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/lib/elliptic_cover_recovery.sage)
implements this process without fixing the degree. Its input is

$$
(F,E,h,c,Q,P,n),
$$

where $C:y^2=F(x)$, $h(x)\,dx/y$ is the selected eigenform, $c$ is the
differential scale, $Q$ is a finite or infinite source expansion point,
$P$ is its image on $E$, and $n$ is the expected cover degree.

The implementation:

1. constructs the local source expansions at $Q$;
2. integrates $c\,h(x)\,dx/y$ exactly;
3. inverts the elliptic formal logarithm;
4. translates the formal point by $P$ using the full Weierstrass group law;
5. solves the linear system
   $A(x(t))-X_E(t)B(x(t))=O(t^N)$;
6. verifies the exact completed-square identity

   $$
   F(X')^2=c^2h^2
   \left(4X^3+b_2X^2+2b_4X+b_6\right).
   $$

It returns

$$
X=\frac{A}{B},\qquad
Y=y\frac{X'}{2ch}-\frac{a_1X+a_3}{2}.
$$

Regression certificates cover degrees $3$, $5$, $7$, and $9$, a finite source
point, finite and identity target centers, quintic and sextic source models,
and a quadratic number field. Thus the implementation is no longer tied to
the Kumar specialization.

The library now also discovers the scale and center. For a fixed candidate
center it performs reconstruction over $k(c)$, where $c$ is an indeterminate
differential scale. The exact map identity yields a univariate polynomial in
$c$, and only roots in the base field that pass full exact verification are
accepted.

Over $\mathbb Q$, unknown centers are searched in an explicitly bounded
Mordell-Weil box. The bound and attempted centers are retained in the
certificate. For the second degree-$7$ map, four centers are tested before
finding

$$
P=\left(\frac{10465}{4},-\frac{51175}{8}\right)=-7G
$$

and $c=-49/60$. The finite degree-$3$ regression similarly discovers
$P=(5,19)$ and $c=-1/5$.

When candidate Hilbert-modular $j$-invariants are supplied, the target models
and eigenforms are now also discovered. Signed squarefree twists supported on
the source discriminant are filtered by the two quadratic Frobenius factors.
Primitive projective differential lines $[r:s]$ are then searched in bounded
height, and only candidates producing an exact map survive.

For the degree-$7$ benchmark, 64 twist classes and 17 split good Frobenius
polynomials uniquely select twists $-115$ and $5$. The exact map search then
selects eigenform lines $[1:0]$ and $[0:1]$.

The remaining input is the list of candidate $j$-invariants. Extracting that
list from an arbitrary source curve is a separate moduli or database problem;
for Kumar families it is supplied by the family importer.

### General even-degree coordinates

The degree-$6$ benchmark shows why a rational-function-only implementation is
not sufficient. After translating one rational point at infinity to the
elliptic origin, the complementary map has

$$
X=a(x)+y\,b(x).
$$

If $\delta(x)=1$ and $\delta(y)=F'(x)/(2y)$, then

$$
\delta(X)=a'
+\left(b'+\frac{bF'}{2F}\right)y.
$$

For a short Weierstrass target and pullback differential
$c\,h(x)\,dx/y$, the second coordinate is forced:

$$
Y=
\frac{
F b'+\frac12bF'+a'y
}{2ch}.
$$

The library represents functions as pairs `(a,b)` for $a+yb$, performs exact
quadratic-function arithmetic, verifies the elliptic equation coefficient by
coefficient in the basis $(1,y)$, and computes the degree by eliminating
$y$. For the current complement the recovered $X$-coordinate has degree
$12$, proving that the elliptic map has degree $6$.

The same backend now recovers the degree-$8$ complement with eigenform
$(1+2x)dx/y$. Its $X=a+yb$ coordinate has degree $16$, while the compact
quotient remains in $\mathbf Q(x)$. Thus the full-function-field
representation is a stable even-degree feature rather than an isolated
degree-$6$ exception.

### Kumar family importer

The exact SageMath adapter
[`kumar_square_discriminant_families.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/lib/kumar_square_discriminant_families.sage)
now covers every degree $6\leq n\leq 11$. It reads Kumar's original
auxiliary files and returns

$$
z^2=D_n(r,s),\qquad
(I_2,I_4,I_6,I_{10}),\qquad
J^2-(j_1+j_2)J+j_1j_2,
$$

together with exact specializations of the tautological sextic. At a
nonsquare value of $D_n(r,s)$ the curve is constructed over the quadratic
field generated by $z$; a rational lift can be supplied explicitly.

Two independent validation layers are committed. The first parses all six
surface equations, all six Igusa tuples, and all six pairs of symmetric
$j$-functions, then checks at exact rational samples that

$$
\frac{(j_1+j_2)^2-4j_1j_2}{D_n(r,s)}
$$

is a square. The second constructs a squarefree genus-2 sextic in every
degree. The largest upstream formula, for degree $11$, occupies 3.1 MB and
is evaluated by an iterative exact-arithmetic parser rather than Python's
depth-limited expression compiler.

## Engine C: specialization and interpolation

Generic elimination becomes too large quickly. For a parameterized family:

1. choose many good rational parameter values;
2. solve each exact specialization independently;
3. normalize signs and Möbius choices canonically;
4. interpolate coefficients as rational functions of the parameters;
5. verify the reconstructed formula over the full function field.

The final symbolic verification, not the number of samples, is the proof.

## Engine D: finite fields and CRT

For one large characteristic-zero example:

1. choose good primes preserving degree and ramification type;
2. perform factorization, normalization, and Gröbner elimination over
   finite fields;
3. identify the same component using degree, genus, and monodromy data;
4. lift coefficients with CRT and rational reconstruction;
5. rerun all defining identities over the original number field.

This backend is required once direct resultants become memory-bound.

The first implemented CRT stage discovers the differential scale. For the
degree-$6$ complement, full finite-field map identities leave the two roots
$c=\pm33$ modulo $101$ and $c=\pm35$ modulo $103$. Rational reconstruction of
the scale squares gives

$$
c^2=\frac49,
$$

after which the complete map is reconstructed once over $\mathbf Q$ and
certified exactly.

For the degree-$8$ complement, prime $61$ leaves the roots $c=\pm2$.
Rational reconstruction gives $c^2=4$, and the characteristic-zero recovery
then verifies the degree-$8$ map exactly.

The degree-$9$ benchmark adds resumable target-center lifting. For each good
prime, the implementation enumerates the finite elliptic target, retains only
centers for which the complete modular map identity holds, combines the
affine coordinates by CRT, and tests rational reconstructions against both
the rational target and the full characteristic-zero map. The two finite
centers required moduli of $128$ and $184$ bits. Coefficient-level modular
lifting is now implemented as well.

A modular rational map is stored as the projective coefficient vector of
$(A,D)$, while a full quadratic-function map uses $(A,B,D)$. One common
nonzero coefficient is fixed as projective pivot across all good primes.
Every other coordinate is combined by CRT and rationally reconstructed. The
state is resumable and records the modulus, pivot, residues, accepted prime
certificates, and rejected primes. The lift is accepted only after the exact
elliptic identity and cover degree certify over $\mathbf Q$.

For the degree-$6$ benchmark, this recovers the rational quotient with a
$27$-bit modulus and its $A+yB$ complement with a $34$-bit modulus. Thus the
modular pipeline no longer requires a characteristic-zero linear solve for
the final map coefficients.

## Engine E: Galois closure

Let the associated rational map be

$$
\phi(t)=\frac{N(t)}{D(t)}
$$

and write the elliptic double cover as

$$
w^2=f(z).
$$

If $t_1$ and $t_2$ are two distinct roots of
$N(T)-zD(T)$, the non-diagonal component has an involution

$$
(t_1,t_2,w)\longmapsto(t_2,t_1,-w).
$$

The fixed field is generated by

$$
s=t_1+t_2,\qquad p=t_1t_2,\qquad q=w(t_1-t_2).
$$

To compute it, divide

$$
N(T)-zD(T)
$$

by $T^2-sT+p$.  If the remainder is $r_1(s,p,z)T+r_0(s,p,z)$, then an
affine model of the quotient is

$$
r_0=0,\qquad r_1=0,\qquad
q^2=f(z)(s^2-4p).
$$

This is implemented in `lib/galois_complement.sage`.  It is a direct
fixed-field algorithm: no explicit polynomial of degree $n!$ for the full
Galois closure is needed.

On the group side, for $G=S_n\times C_2$ the off-diagonal component and its
quotient correspond to

$$
H_Z=S_{n-2}\times\{1\},
\qquad
H_W=\langle H_Z,((12),-1)\rangle.
$$

Their indices are

$$
[G:H_Z]=2n(n-1),\qquad [G:H_W]=n(n-1).
$$

The coset action $G/H_W$ has a concrete model on ordered pairs
$(a,b)$ with $a\ne b$:

$$
(\sigma,+1)(a,b)=(\sigma(a),\sigma(b)),
$$

$$
(\sigma,-1)(a,b)=(\sigma(b),\sigma(a)).
$$

`lib/galois_complement.m` computes the branch permutations in this action
and applies Riemann--Hurwitz.  The generic odd-degree signature gives genus
one in degrees $5,7,9,11,13,15$.  The exact signatures of the current
degree-$6$, degree-$7$, and degree-$8$ quotients also give genus one.

For the critical quartic, the elliptic quadratic field is the sign subfield
of the $S_4$ closure.  Intersecting its sign graph with $H_W$ gives an
order-$2$ subgroup of index $12$, exactly the transposition fixed field in
the paper.  The invariant equations reduce to

$$
s^3-2sp+as+b=0
$$

and, after setting $Y=s(t_1-t_2)$,

$$
Y^2=-s^4-2as^2-2bs.
$$

This recovers

$$
j=-\frac{1024a^6}{b^2(8a^3+27b^2)}.
$$

For the current degree-$6$ benchmark, Magma computes the rational generic
fiber group as $S_6$. The elliptic-base quadratic extension is linearly
disjoint from the unique quadratic subfield of that splitting field, so the
elliptic cover also has $S_6$ monodromy. This is a certified nonexceptional
test case.

The compact degree-$8$ quotient supplies a second exact group benchmark.
Magma computes $S_8$ of order $40320$, and the fiber discriminant has square
class

$$
-5\left(T^3-T^2-5833T+207037\right).
$$

The elliptic base adjoins the square root of the cubic without the factor
$-5$, so the base change preserves $S_8$.

For the compact degree-$7$ quotient, Magma computes $S_7$ of order $5040$.
The fiber discriminant is

$$
\frac{828157741498368}{117649}
\left(T^3-7876003275T-272222678576250\right)^3.
$$

Its square class is twice the target cubic.  The elliptic base adjoins the
square root of the cubic itself, so the two quadratic extensions are
distinct and the elliptic cover retains $S_7$.

For the first degree-$9$ quotient, an irreducible rational fiber has modular
factorization patterns $(1,3,5)$ and $(2,7)$. Powers of the corresponding
Frobenius elements give a $5$-cycle and a transposition. The $5$-cycle rules
out the only possible block size, Jordan's theorem supplies $A_9$, and the
transposition gives $S_9$. The generic fiber discriminant has square class

$$
359687\left(1842229401671T+98280453222687553920\right).
$$

This linear polynomial is squarefree and coprime to the elliptic branch
cubic, so the quadratic elliptic base change preserves $S_9$.

## Engine F: explicit splitting kernels

For recovered maps $\phi_i:C\to E_i$, the reusable Magma helper pulls
divisors $P-O_i$ through $\phi_i$ and converts them to points of
$\operatorname{Jac}(C)$. Over a good finite field containing the full
$n$-torsion, it solves the unique graph relation

$$
\phi_1^*(P-O_1)+\phi_2^*(\psi(P)-O_2)=0.
$$

The degree-$6$ benchmark uses $\mathbf F_{29^2}$. In the computed torsion
bases,

$$
\psi_6=
\begin{pmatrix}
1&4\\
0&1
\end{pmatrix}
\pmod{6}.
$$

The script finds exactly $36$ kernel pairs. The two Weil pairings are
$a^{700}$ and $a^{140}$ in $\mathbf F_{29^2}^{\times}$, whose order is
$840$, so their product is $1$.

The degree-$8$ benchmark uses $\mathbf F_{79^2}$ and gives

$$
\psi_8=
\begin{pmatrix}
4&7\\
3&4
\end{pmatrix}
\pmod{8}.
$$

Its determinant is $3$ modulo $8$, the kernel contains exactly $64$ pairs,
and the pairing exponents $2340$ and $3900$ sum to
$|\mathbf F_{79^2}^{\times}|=6240$. Thus both graph maps are
anti-isometries and both kernels are maximally isotropic.

## Engine G: Frey-Kani synthesis

Instead of starting from a curve, start from elliptic curves $E,E'$ and an
anti-isometry

$$
\psi:E[n]\longrightarrow E'[n].
$$

Form the quotient of $E\times E'$ by the graph of $\psi$, test whether the
principal polarization is a Jacobian, reconstruct the genus-2 curve, and then
recover both degree-$n$ maps. This is the construction engine for genuinely
new primitive examples beyond the currently tabulated moduli families.

The first certified synthesis uses $n=13$ over $\mathbf F_{8009}$:

$$
E_1:y^2=x^3+5553x+5419,\qquad
E_2:y^2=x^3+2531x+1402.
$$

Their rational point groups have invariants $(13,611)$ and $(13,624)$, so
both full $13$-torsion modules are rational. In the stored bases, the required
determinant is $3$, and

$$
\psi=
\begin{pmatrix}
1&0\\
0&3
\end{pmatrix}
\pmod {13}
$$

inverts the Weil pairing. The graph has $169$ points. There are exactly

$$
13(13^2-1)=2184
$$

matrices with the required determinant.

The Frobenius traces are $67$ and $-102$. The corresponding ordinary
endomorphism fields have squareclasses $-163$ and $-2$, so the curves are
geometrically nonisogenous. This supplies the strong Frey-Kani irreducibility
criterion: the quotient principal polarization is geometrically the
Jacobian of a smooth genus-2 curve. Its Weil polynomial is

$$
T^4+35T^3+9184T^2+280315T+64144081.
$$

The theta-gluing implementation now computes the quotient over
$\mathbf F_{8009^{12}}$. Its absolute Igusa invariants are

$$
(4139,7829,4340),
$$

and are fixed by $8009$-Frobenius. Magma's Mestre reconstruction and twist
test give the base-field model

$$
\begin{aligned}
C:\quad y^2={}&6042x^6+4620x^5+6357x^4+3661x^3\\
&+4018x^2+5767x+84.
\end{aligned}
$$

SageMath and Magma independently certify that this curve has the displayed
Weil polynomial. Both degree-$13$ maps have now been recovered, transported
to this fixed model, descended to $\mathbf F_{8009}$, and independently
certified in Magma.

The same engine produces a degree-$17$ graph over $\mathbf F_{8263}$ from

$$
E_1:y^2=x^3+1728,\qquad
E_2:y^2=x^3+6442x+3171.
$$

The traces are $172$ and $-117$, their CM squareclasses are $-3$ and $-67$,
and the anti-isometry matrix is

$$
\begin{pmatrix}
1&0\\
0&6
\end{pmatrix}
\pmod {17}.
$$

The graph has $17^2=289$ points. The quotient Weil polynomial is

$$
T^4-55T^3-3598T^2-454465T+68277169.
$$

Its absolute Igusa invariants are $(893,1328,7156)$. Independent SageMath
and Magma reconstruction gives the fixed base-field curve

$$
\begin{aligned}
C_{17}:\quad y^2={}&5422x^6+4306x^5+4875x^4+5667x^3\\
&+6314x^2+4554x+6050.
\end{aligned}
$$

Map recovery is degree-independent. For prime $n$, the engine recovers two
dual-kernel Mumford divisors, evaluates the dual theta isogeny on at least
$2n+1$ deterministic points, interpolates rational functions of degree at
most $n$, and proves the two elliptic equations as identities. The degree-17
run uses 42 samples over $\mathbf F_{8263^{24}}$. It returns degree pairs
$(17,16)$ on the Rosenhain model in 384.812 seconds. After branch-set
transport, both maps descend with degree pairs $(17,17)$. The second map
requires one target 2-torsion translation to resolve its Frobenius cocycle.
Magma independently returns degrees $17$ and $17$.

For degree $19$, the first admissible field is $\mathbf F_{11743}$. The
deterministic curves have traces $192$ and $-169$, CM squareclasses $-7$ and
$-51$, and graph matrix $\operatorname{diag}(1,16)$. The quotient Weil
polynomial is

$$
T^4-23T^3-8962T^2-270089T+137898049.
$$

Its absolute invariants are $(11336,8788,9369)$, and the fixed quotient is

$$
\begin{aligned}
C_{19}:\quad y^2={}&9500x^6+7591x^5+6679x^4+7190x^3\\
&+1439x^2+4884x+3417.
\end{aligned}
$$

The degree-19 recovery uses 46 exact samples over
$\mathbf F_{11743^{24}}$.

## Degree program

| Degree | Immediate target |
|---|---|
| 5 | Prove the branch-field conic splitting locus and derive generic $j(E')$ |
| 6 | Both primitive maps and nonexceptional $S_6$ monodromy complete |
| 7 | Completed benchmark; automate finite target-point discovery |
| 8 | Both primitive maps and full $S_8$ monodromy complete |
| 9 | Both primitive maps, CRT centers, and full $S_9$ monodromy complete |
| 10 | Both primitive maps complete; target isogeny obstruction excludes degree $5$ followed by a 2-isogeny |
| 11 | Both primitive maps complete on a rational point of Kumar's $Y_-(121)$ |
| $>11$ | Degrees 13 and 17 complete; degree-19 quotient complete and maps in progress |

## Degree 10 and degree 11

The same full-function-field engine now reaches the final two imported Kumar
families. For degree $10$, the rational point

$$
(r,s,z)=\left(-\frac45,\frac15,\frac{18}{125}\right)
$$

on $Y_-(100)$ yields two maps with pullback eigenforms
$(x+3689/18750)dx/y$ and $dx/y$. Their differential scales are
$1/10500$ and $197509/787500000$. Modular recovery used $133$-bit and
$276$-bit CRT moduli. Both target curves have no rational $2$- or
$5$-isogeny, so both degree-$10$ maps are primitive.

For degree $11$, the rational point

$$
(r,s,z)=\left(\frac32,\frac12,\frac38\right)
$$

on $Y_-(121)$ yields eigenforms $(x-1)dx/y$ and $dx/y$, with scales
$121/639660$ and $2671801/7306516350$. Their CRT moduli have $127$ and
$238$ bits. Since $11$ is prime, the exact degree computation already rules
out a nontrivial factorization through an elliptic isogeny.

All four $X$-coordinates have the form $a(x)+y\,b(x)$. SageMath certifies
their exact function-field identities and cover degrees. Static Magma
programs independently reconstruct the morphisms and return degrees
$10,10,11,11$.

## Complexity policy

No generic formula is accepted merely because a computer algebra system
prints it. Every stage records degree bounds, coefficient heights, prime
choices, component signatures, reconstruction moduli, and a compact exact
identity. Large runs belong in remote Magma screen sessions; portable
certificates and reduced outputs return to the repository.
