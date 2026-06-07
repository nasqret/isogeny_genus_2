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

Use an ansatz

$$
X=\frac{A(x)}{B(x)},\qquad
Y=\frac{y\,C(x)}{B(x)^q}
$$

with degree bounds forced by $n$. The elliptic equation and differential
identity give polynomial equations in the coefficients of $A,B,C,r,s$.
Solve them modulo several good primes, Hensel lift when useful, reconstruct
rational coefficients by CRT, and certify the final characteristic-zero
identity.

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

The target curve, eigenform, scale, and center are currently inputs. Their
automatic discovery remains the modular and finite-field part of Engine B.

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
| 6 | Import $Y_-(36)$, handle the exceptional monodromy case, recover one exact pair of maps |
| 7 | Completed benchmark; automate finite target-point discovery |
| 8 | Import $Y_-(64)$, solve maps with modular eigenform equations |
| 9 | Compare primitive degree 9 with compositions of degree 3 |
| 10 | Separate primitive degree 10 from degree $5$ followed by a 2-isogeny |
| 11 | Recover maps on Kumar's $Y_-(121)$ model |
| $>11$ | Generate examples by anti-isometries and use modular/CRT reconstruction |

## Complexity policy

No generic formula is accepted merely because a computer algebra system
prints it. Every stage records degree bounds, coefficient heights, prime
choices, component signatures, reconstruction moduli, and a compact exact
identity. Large runs belong in remote Magma screen sessions; portable
certificates and reduced outputs return to the repository.
