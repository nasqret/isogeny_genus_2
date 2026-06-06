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
- Degree 7: one rational Kumar specialization with exact source curve, two
  rational elliptic twists, and 41 matching good Euler factors.
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
2. Degree 6: import the \(Y_-(36)\) family and handle exceptional
   \(\operatorname{PGL}_2(\mathbf F_5)\) monodromy.
3. Degree 7: recover both maps for the current benchmark.
4. Degrees 8-11: import Kumar's tautological families and recover one fully
   certified rational specialization per degree.
5. Degrees above 11: generate primitive examples by anti-isometry synthesis
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
