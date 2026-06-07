# Degree-31 Frey-Kani Synthesis

## Minimal arithmetic instance

The generic frontier scanner exhaustively rejects every smaller prime
`q = 1 mod 31` and selects `F_64853`. The admissible traces are `467` and
`-494`, with distinct CM squareclasses `-43` and `-1`.

The deterministic curves are

```text
E1: y^2 = x^3 + 48095*x + 18584
E2: y^2 = x^3 + x.
```

Their group invariants are `(31,2077)` and `(62,1054)`. With the stored
torsion bases, the anti-isometry is `diag(1,11)`. SageMath and Magma
independently certify the inverse Weil pairing, all `961` graph points, and
all `29760 = 31(31^2-1)` compatible matrices.

The quotient Weil polynomial is

```text
T^4 + 27*T^3 - 100992*T^2 + 1751031*T + 4205911609.
```

## Quotient curve

The theta quotient has absolute invariants `(36707,3040,53075)` and
normalized Igusa-Clebsch tuple `(1,26829,14540,30878)`. Unlike the previous
prime-degree examples, the Rosenhain model itself is already defined over
the base field:

```text
y^2 = x^5 + 52399*x^4 + 40681*x^3 + 18410*x^2 + 18215*x.
```

Magma's Mestre reconstruction needs no quadratic twist and returns the same
quintic. SageMath and Magma independently verify its invariants and quotient
Frobenius polynomial.

## Both maps

The Hasse-Witt matrix is

```text
[34191 34998]
[34162 30635]
```

Its eigendirections for traces `467,-494` are `(1,55105)` and `(1,54058)`.
Recovery uses `70 = 2*31+8` exact samples over the degree-24 level-2 field
and `143` compatible roots in one degree-31 extension.

The Kummer-class evaluator takes `2400.937` seconds inside a total recovery
time of `2560.543` seconds. Its internal timings are:

| subphase | seconds |
|---|---:|
| compatible lifts | 12.809 |
| extension and batched roots | 237.727 |
| kernel recurrence | 1783.443 |
| theta power sums | 353.803 |
| coefficient descent and target construction | 11.398 |

Both X-coordinate degree pairs are `(31,30)`. Because the source quintic is
already the fixed base-field model, descent uses the identity Möbius
transformation and scaling `1`; both maps descend directly, without a
2-torsion correction. Exact elliptic identities and differential
eigendirections pass over `F_64853`.

Static Magma code independently reconstructs both morphisms, verifies their
target equations and differential pullbacks, and returns degrees `31,31`.

## Scaling conclusion

The frontier model predicted `2410.819` seconds for dual-isogeny evaluation;
the measured value is `2400.937` seconds, an error of only `0.41%`.
Recovery remains dominant, but the bottleneck is now sharply localized:
the kernel recurrence consumes `74.28%` of dual evaluation and `69.65%` of
the complete recovery. B026 therefore targets recurrence organization and
finite-field additions before attempting degree 37.

## Optimized rerun

B026 caches basis-dependent differential-addition data and traverses theta
power sums row by row. Exact comparison preserves both complete maps.

| quantity | original | optimized | reduction |
|---|---:|---:|---:|
| kernel recurrence | 1783.443 s | 457.410 s | 74.35% |
| theta power sums | 353.803 s | 187.407 s | 47.03% |
| dual evaluation | 2400.937 s | 790.112 s | 67.09% |
| complete recovery | 2560.543 s | 839.479 s | 67.21% |

Scaling the original frontier model by the measured dual improvement gives a
revised degree-37 dual estimate of about `1571` seconds. Degree 37 is now a
practical next synthesis target.
