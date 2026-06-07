# Degree-37 Frey-Kani Synthesis

## Arithmetic and graph

The first qualifying prime field is `F_128021`, with traces `705,-664` and
CM squareclasses `-11,-13`. The deterministic curves are

```text
E1: y^2 = x^3 + 94494*x + 115630
E2: y^2 = x^3 + 94047*x + 106345.
```

Their group invariants are `(37,3441)` and `(37,3478)`. The selected
anti-isometry is `diag(1,21)`. SageMath and Magma independently certify all
`1369` graph points and all `50616 = 37(37^2-1)` compatible matrices.

The quotient Weil polynomial is

```text
T^4 - 41*T^3 - 212078*T^2 - 5248861*T + 16389376441.
```

## Quotient curve

The theta quotient has absolute invariants `(29635,122473,53158)` and
normalized Igusa-Clebsch tuple `(1,12531,30800,118581)`. The Rosenhain model
does not descend directly. Magma's Mestre reconstruction needs no quadratic
twist and gives

```text
y^2 =
36955*x^6 + 49647*x^5 + 21256*x^4 + 44090*x^3
+ 59931*x^2 + 75182*x + 123483.
```

SageMath independently checks the moduli and computes the quotient
Frobenius polynomial through an odd-degree model and the `hypellfrob`
backend.

## Both maps

The Hasse-Witt eigendirections are `(1,27611)` and `(1,13761)`. Recovery
uses `82 = 2*37+8` exact samples and `167` Kummer-class roots.

| subphase | seconds |
|---|---:|
| compatible lifts | 10.539 |
| extension and roots | 222.253 |
| prepared kernel recurrence | 1386.486 |
| row-major theta power sums | 819.920 |
| coefficient descent | 16.759 |

Dual evaluation takes `2471.072` seconds and complete recovery takes
`2551.792` seconds. Both Rosenhain X-degree pairs are `(37,36)`.

After transport to the fixed sextic, both X-degree pairs are `(37,37)`.
Both maps descend directly. SageMath verifies the target equations and
differential eigendirections; remote Magma independently returns degrees
`37,37`.

## Scaling conclusion

The revised degree-31-based model predicted about `1571` seconds for dual
evaluation, but the measured value is `2471` seconds. The recurrence remains
important, while theta power sums now consume `819.920` seconds and grow
faster than expected. Degree 41 should not be launched until the power-sum
phase receives another optimization pass.
