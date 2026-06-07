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
- General recovery: a degree-independent SageMath library reconstructs and
  exactly certifies maps from local formal data. Regression cases cover
  degrees 3, 5, and 7, finite and infinite source centers, finite target
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

For the degree-8 complement, primes `61` and `67` reconstruct `c^2=4`,
hence `c=2`. Its recovered `X=a+y*b` coordinate has function degree `16`,
and exact elimination proves that the map to the elliptic target has degree
`8`.

### Family interpolation

Solve many specializations, normalize coordinate choices, interpolate
rational functions in the parameters, and prove the candidate by one generic
function-field identity.

### Galois-closure fallback

Implement the non-diagonal fiber-product quotient of Gallese. This is slower
but works in arbitrary degree and gives subgroup and genus certificates
independent of the plane-model shortcuts.

### Construction from torsion

Enumerate Frey-Kani anti-isometries on \(n\)-torsion, quotient
\(E\times E'\), test the principal polarization, reconstruct the genus-2
curve, and recover the two maps.

## Degree milestones

1. Degree 5: prove or refute generic conic splitting over the branch field;
   derive \(j(E')\).
2. Degree 6: both primitive maps are recovered and independently checked in
   Magma. The monodromy is \(S_6\), so this specialization is not the
   exceptional \(\operatorname{PGL}_2(\mathbf F_5)\) action.
3. Degree 7: completed for the current benchmark; from the two family
   `j`-invariants the recovery routine discovers twists, eigenforms, centers,
   scales, and both maps.
4. Degree 8: both primitive maps and full `S8` monodromy are certified for a
   rational `Y_-(64)` specialization.
5. Degrees 9-11: imported; next locate rational surface points and recover
   one fully certified rational specialization per degree.
6. Degrees above 11: generate primitive examples by anti-isometry synthesis
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
