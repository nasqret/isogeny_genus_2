# Degree-29 Frey-Kani Synthesis

## Minimal arithmetic instance

The arithmetic prefilter exhaustively checks every smaller prime
`q = 1 mod 29`. The first field with at least two full-29-torsion trace
classes having distinct CM squareclasses is `F_50867`, with traces
`408,-433` and squareclasses `-11,-19`.

The deterministic curves are

```text
E1: y^2 = x^3 + 18068*x + 28770
E2: y^2 = x^3 + 16732*x + 29860.
```

Their groups have invariants `(29,1740)` and `(29,1769)`. In the stored
torsion bases, the anti-isometry is `diag(1,24)`. SageMath and Magma
independently certify the inverse Weil pairing, all `841` graph points, and
all `24360 = 29(29^2-1)` matrices with the required determinant.

The quotient Weil polynomial is

```text
T^4 + 25*T^3 - 74930*T^2 + 1271675*T + 2587451689.
```

## Quotient curve

The theta quotient over the degree-12 auxiliary field has Kohel absolute
invariants `(15563,43108,4996)`. With `I2=1`, the normalized
Igusa-Clebsch tuple is `(1,21252,39425,6127)`.

Magma's Mestre reconstruction needs no quadratic twist and gives

```text
y^2 =
24513*x^6 + 50615*x^5 + 5530*x^4 + 37221*x^3
+ 46765*x^2 + 234*x + 31812.
```

SageMath independently verifies squarefreeness, genus 2, the absolute
invariants, and the quotient Frobenius polynomial. Magma verifies G2
invariants `(30806,10408,29480)` and the reciprocal L-polynomial.

## Both maps

The Hasse-Witt matrix of the fixed model is

```text
[21204 41712]
[49255 29638]
```

Its eigendirections for traces `408,-433` are `(1,4375)` and `(1,33334)`.
The recovery engine uses `66 = 2*29+8` exact samples over the degree-24
level-2 field. The optimized evaluator realizes all `135` compatible-lift
roots in one degree-29 extension.

The dual-isogeny phase takes `1862.473` seconds and the complete recovery
takes `1912.645` seconds. On the Rosenhain model, both X-coordinate degree
pairs are `(29,28)`. Exact interpolation, target identities, and linear
differential pullbacks all pass.

After transport to the fixed sextic, both maps have X-degree pair `(29,29)`.
The first map descends directly. The second has a nontrivial target
2-torsion Frobenius cocycle; the four-point coboundary search finds its
unique correction. Both final maps have coefficients in `F_50867`.

Static Magma code independently reconstructs the two morphisms, verifies
their target equations and differential pullbacks, and returns degrees
`29,29` in `0.170` seconds.

## Scaling conclusion

The sample rule `2*n+8`, Rosenhain degree pattern `(n,n-1)`, and descended
degree pattern `(n,n)` persist through degree 29. Recovery remains the
dominant cost: the dual-isogeny phase accounts for `97.38%` of the complete
degree-29 recovery run. The next optimization target is therefore the
kernel-table recurrence and its repeated finite-field additions, not
interpolation, descent, or final certification.
