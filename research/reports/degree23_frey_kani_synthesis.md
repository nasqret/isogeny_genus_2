# Degree-23 Frey-Kani Synthesis

## Graph

Over `F_21943`, the deterministic curves are

```text
E1: y^2 = x^3 + 18008*x + 21189
E2: y^2 = x^3 + 6198*x + 5070.
```

Their traces are `255,-274`, groups are `(23,943)` and `(23,966)`, and CM
squareclasses are `-43,-6`. In the stored bases the identity matrix is an
anti-isometry. The graph has `529` points and quotient Weil polynomial

```text
T^4 + 19*T^3 - 25984*T^2 + 416917*T + 481495249.
```

SageMath and remote Magma independently certify these data.

## Quotient

The theta quotient has base-field Igusa-Clebsch invariants
`(6652,7299,13559,5703)` and absolute invariants
`(10751,7124,12516)`. The fixed curve is

```text
y^2 =
7036*x^6 + 9761*x^5 + 17544*x^4 + 6384*x^3
+ 20690*x^2 + 11330*x + 14637.
```

SageMath certifies its moduli and Frobenius polynomial. Magma independently
certifies G2 invariants `(10058,1654,18404)` and the reciprocal
L-polynomial.

## Maps

The general recovery engine is running with 54 exact samples over
`F_(21943^24)`. The dashboard tracks screen `degree23-map-recovery`.
