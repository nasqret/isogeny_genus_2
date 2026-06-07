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

Regression certificates cover degrees $3$, $5$, and $7$, a finite source
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

For the degree-$8$ complement, primes $61$ and $67$ both leave the roots
$c=\pm2$. Their CRT reconstruction gives $c^2=4$, and the characteristic-zero
recovery then verifies the degree-$8$ map exactly. Coefficient-level modular
lifting remains the next backend extension.

## Engine E: Galois closure

Gallese's construction works at arbitrary degree. Compute the Galois closure
of $C\to E$, identify the subgroup corresponding to the non-diagonal
component of $C\times_E C$, and quotient by the natural involution. The
algorithm should output:

- the monodromy group and subgroup certificate;
- genera of the intermediate curves;
- the genus-one quotient;
- the induced complementary map.

It is less efficient than Engine A, but it is degree-independent and provides
an independent structural check. Degree $6$ needs special care because the
exceptional $\operatorname{PGL}_2(\mathbf F_5)$ action can occur.

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

## Engine F: Frey-Kani synthesis

Instead of starting from a curve, start from elliptic curves $E,E'$ and an
anti-isometry

$$
\psi:E[n]\longrightarrow E'[n].
$$

Form the quotient of $E\times E'$ by the graph of $\psi$, test whether the
principal polarization is a Jacobian, reconstruct the genus-2 curve, and then
recover both degree-$n$ maps. This is the construction engine for genuinely
new primitive examples beyond the currently tabulated moduli families.

## Degree program

| Degree | Immediate target |
|---|---|
| 5 | Prove the branch-field conic splitting locus and derive generic $j(E')$ |
| 6 | Both primitive maps and nonexceptional $S_6$ monodromy complete |
| 7 | Completed benchmark; automate finite target-point discovery |
| 8 | Both primitive maps and full $S_8$ monodromy complete |
| 9 | Compare primitive degree 9 with compositions of degree 3 |
| 10 | Separate primitive degree 10 from degree $5$ followed by a 2-isogeny |
| 11 | Imported; recover maps on Kumar's $Y_-(121)$ model |
| $>11$ | Generate examples by anti-isometries and use modular/CRT reconstruction |

## Complexity policy

No generic formula is accepted merely because a computer algebra system
prints it. Every stage records degree bounds, coefficient heights, prime
choices, component signatures, reconstruction moduli, and a compact exact
identity. Large runs belong in remote Magma screen sessions; portable
certificates and reduced outputs return to the repository.
