# High-Degree Elliptic-Cover Research Roadmap

## Goal

Build a degree-independent, certificate-producing system for primitive maps
from genus-2 curves to elliptic curves, then use it to create new families and
examples beyond the formulas currently available in the literature.

## Mathematical contract

For a maximal degree-\(n\) map \(C\to E\), the connected kernel of
\(\operatorname{Jac}(C)\to E\) is an elliptic curve \(E'\), the complementary
map \(C\to E'\) again has degree \(n\), and
\(E\times E'\to\operatorname{Jac}(C)\) is an \((n,n)\)-isogeny. A computation
is complete only after both maps and this splitting are certified exactly.

## Implemented frontier

- Generic degree 5: branch quadratic, three-node plane quartic, normalization
  conic, and exact construction of source curves and maps.
- Degree-5 census: ten exact primitive covers; all tested normalization conics
  split over the branch quadratic field and none over Q.
- Degree 6: one rational Kumar specialization with both primitive maps,
  full quadratic-function recovery for the complement, CRT scale lifting,
  independent Magma degrees, and nonexceptional `S6` monodromy.
- Degree 7: one rational Kumar specialization with exact source curve, two
  rational elliptic twists, 41 matching good Euler factors, and both
  primitive maps certified in SageMath and Magma.
- Degree 8: one rational Kumar specialization with both primitive maps,
  full quadratic-function recovery for the complement, CRT scale lifting,
  independent Magma degrees, source automorphism group of order `2`, and
  full `S8` monodromy over the elliptic base.
- Degree 9: one rational Kumar specialization with both primitive maps,
  modular reconstruction of finite target centers, independent Magma
  degrees, and full `S9` monodromy over the elliptic base.
- Degree 10: one rational Kumar specialization with both primitive
  full-function-field maps, scale CRT moduli of 133 and 276 bits, target
  isogeny obstruction, and independent Magma degrees.
- Degree 11: one rational Kumar specialization with both primitive
  full-function-field maps, scale CRT moduli of 127 and 238 bits, and
  independent Magma degrees.
- Splitting kernels: explicit good-reduction graph matrices and inverse Weil
  pairings for the degree-6 and degree-8 benchmarks, with complete kernel
  counts `6^2` and `8^2`.
- General recovery: a degree-independent SageMath library reconstructs and
  exactly certifies maps from local formal data. Regression cases cover
  degrees 3, 5, 7, and 9, finite and infinite source centers, finite target
  centers, quintic and sextic models, and a quadratic number field.
- Automatic local-data discovery: the differential scale is solved exactly
  as an algebraic condition, and rational target centers are found in a
  bounded Mordell-Weil search.
- Target and eigenform discovery: given candidate Hilbert-modular
  `j`-invariants, Frobenius traces select the rational twists and a bounded
  projective search selects the eigenform lines. Exact maps certify the
  surviving candidates.
- Kumar family importer: all 18 upstream auxiliary files for discriminants
  `36,49,64,81,100,121` are vendored and parsed exactly. The importer exposes
  the Hilbert modular double cover, Igusa-Clebsch tuple, quadratic
  `j`-polynomial, and tautological sextic. One nonsingular genus-2 curve has
  been constructed in every degree `6` through `11`.
- High degree: exact nonprimitive degree-20 and degree-80 maps obtained from
  the degree-5 cover by elliptic multiplication.

## Algorithm portfolio

### Given-map complement

Use the symmetric divided self-fiber, normalize its non-diagonal component,
lift through the two double covers, convert the genus-one output to
Weierstrass form, and reconstruct the complementary map.

### Exact map recovery

Use the split holomorphic differential

$$
(r+sx)\,dx/y
$$

to constrain a rational-function ansatz for the elliptic coordinates. Solve
the coefficient equations modulo good primes, lift, reconstruct, and verify
over the original field.

The degree-7 benchmark adds an essential implementation detail. Formal
integration must be centered at the actual image of the chosen source point.
For the first map that image is the elliptic origin, giving a `(7,3)` Pade
problem. For the complementary map the two source infinities map to finite
opposite points, giving a `(7,7)` problem. Translating by the rational point
`-7*(29,-590)` before formal integration recovers the second map and its
scale `-49/60`.

This is implemented in
`computations/sage/lib/elliptic_cover_recovery.sage`. The reconstruction step
is a homogeneous linear solve for `A(x)-X(t)B(x)`, not a fixed `(7,d)` Padé
formula. Local valuations infer the degree pattern at infinity; finite source
points trigger a search through all numerator/denominator patterns of the
specified cover degree. Every candidate must pass the exact function-field
identity before it is returned.

The symbolic-scale extension runs the same reconstruction over `k(c)`. The
coefficientwise gcd of the exact identity residual gives a univariate scale
polynomial. Nonzero roots in the base field are rerun through the ordinary
exact verifier. Over `Q`, center candidates come from a bounded Mordell-Weil
box whose bound and attempted points are recorded.

For even-degree maps, the elliptic `X`-coordinate need not be fixed by the
hyperelliptic involution. The recovery library now also reconstructs

$$
X=a(x)+y\,b(x),\qquad Y=c(x)+y\,d(x)
$$

inside the full quadratic function field. Exact pair arithmetic verifies the
elliptic identity in the basis `(1,y)`, and elimination computes the degree
of `X:C\to P^1`.

The first finite-field backend discovers the differential scale modulo good
primes, reconstructs `c^2` by CRT, and performs the expensive full-map solve
only once over `Q`. For the degree-6 complement, primes `101` and `103`
reconstruct `c^2=4/9`, hence `c=2/3`.

For the degree-8 complement, prime `61` reconstructs `c^2=4`, hence `c=2`;
the exact characteristic-zero identity accepts this early lift. Its
recovered `X=a+y*b` coordinate has function degree `16`, and exact
elimination proves that the map to the elliptic target has degree `8`.

The degree-9 benchmark adds finite-center reconstruction. For a known
eigenform and scale, `discover_center_by_crt` enumerates target points over
each good finite field, retains only centers passing the complete modular map
identity, combines affine coordinates by CRT, and tests every rational
reconstruction against the characteristic-zero target and map identity.
Partial CRT state is resumable. The two degree-9 centers were certified with
128-bit and 184-bit moduli.

The coefficient stage is also implemented. `discover_coefficients_by_crt`
normalizes the complete modular map coefficient vector at a common projective
pivot, combines every coordinate by CRT, and rationally reconstructs both
`A/D` and `(A+yB)/D` representations. It rejects a lift unless the full
characteristic-zero elliptic identity and exact cover degree hold. The
degree-6 regression reconstructs the rational quotient from a 27-bit modulus
and the full quadratic-function complement from a 34-bit modulus, including
stop-and-resume state in both cases.

### Family interpolation

Solve many specializations, normalize coordinate choices, interpolate
rational functions in the parameters, and prove the candidate by one generic
function-field identity.

### Galois-closure quotient

The Gallese quotient is now implemented at the fixed-field level.  For
\(\phi(t)=N(t)/D(t)\), \(w^2=f(z)\), and two distinct roots \(t_1,t_2\) of
\(N(t)-zD(t)\), the off-diagonal component is quotiented by

\[
(t_1,t_2,w)\longmapsto(t_2,t_1,-w).
\]

Its invariant generators are

\[
s=t_1+t_2,\qquad p=t_1t_2,\qquad q=w(t_1-t_2).
\]

The reusable SageMath engine computes the two coefficients of the remainder
of \(N(T)-zD(T)\) modulo \(T^2-sT+p\), and appends

\[
q^2=f(z)(s^2-4p).
\]

These three equations give the quotient map and an affine model in every
degree.  The Magma engine independently certifies

\[
H_Z=S_{n-2}\times\{1\},\qquad
H_W=\langle H_Z,((12),-1)\rangle
\]

inside \(S_n\times C_2\), including their orders and indices.  Its twisted
ordered-pair action has degree \(n(n-1)\), and Riemann--Hurwitz gives genus
one for the generic odd-degree signatures through degree \(15\), as well as
the concrete degree-\(6\), \(7\), and \(8\) signatures.

For the critical quartic, intersecting \(H_W\) with the sign graph
\(S_4\hookrightarrow S_4\times C_2\) gives an order-\(2\), index-\(12\)
subgroup, recovering the paper's transposition fixed field.  The invariant
equations reduce to the known genus-one quartic and its exact complementary
\(j\)-invariant.

### Construction from torsion

Enumerate Frey-Kani anti-isometries on \(n\)-torsion, quotient
\(E\times E'\), test the principal polarization, reconstruct the genus-2
curve, and recover the two maps.

### Explicit splitting-kernel certificate

For two recovered maps `phi1:C->E1` and `phi2:C->E2`, choose a good finite
field of characteristic prime to `n` over which both full `n`-torsion groups
are rational. For a torsion point `P`, compute

```magma
JacobianPoint(J, Pullback(phi, Divisor(P)-Divisor(E!0)));
```

Solving when the two pullback classes sum to zero gives a matrix for the
graph isomorphism `E1[n] -> E2[n]`. The certificate requires a unit
determinant, exactly `n^2` graph pairs, and inverse Weil pairings. This is
implemented in `computations/magma/lib/splitting_kernel.m`.

## Degree milestones

1. Degree 5: prove or refute generic conic splitting over the branch field;
   derive \(j(E')\).
2. Degree 6: both primitive maps are recovered and independently checked in
   Magma. The monodromy is \(S_6\), so this specialization is not the
   exceptional \(\operatorname{PGL}_2(\mathbf F_5)\) action.
3. Degree 7: completed for the current benchmark; from the two family
   `j`-invariants the recovery routine discovers twists, eigenforms, centers,
   scales, and both maps. The compact quotient has exact `S7` monodromy over
   the elliptic base and a certified genus-one Galois quotient.
4. Degree 8: both primitive maps and full `S8` monodromy are certified for a
   rational `Y_-(64)` specialization.
5. Degree 9: both primitive maps, modular target centers, and full `S9`
   monodromy are certified for a rational `Y_-(81)` specialization.
6. Degrees 10-11: one fully certified rational specialization and both
   primitive maps are complete in each degree.
7. Degrees above 11: generate primitive examples by anti-isometry synthesis
   and recover maps with the finite-field/CRT backend.

## Evidence levels

- **Identity certificate:** exact polynomial or function-field equality.
- **Map certificate:** target identity plus exact degree.
- **Primitive certificate:** maximality or nonfactorization.
- **Split certificate:** both maps and the induced \((n,n)\)-isogeny.
- **Discovery evidence:** Euler factors, numerical periods, or modular
  solutions. These guide reconstruction but are not the final proof.

## Primary sources audited

- K. Magaard, T. Shaska, H. Voelklein,
  [degree-5 normal form](https://arxiv.org/abs/1209.0443).
- A. Kumar,
  [Hilbert modular surfaces for square discriminants](https://arxiv.org/abs/1412.2849).
- A. Gallese,
  [geometric complement construction](https://arxiv.org/abs/2412.07414).

The local implementation deliberately treats these papers as inputs to audit,
not as executable evidence.

## Reproduction

Run all current high-degree certificates with:

```bash
./scripts/validate-beyond.sh
```
