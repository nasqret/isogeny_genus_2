# Degree-19 Frey-Kani Synthesis

## Graph certificate

The first prime field with two admissible full-19-torsion trace classes is
`F_11743`. The deterministic search selects

```text
E1: y^2 = x^3 + 8444*x + 6205
E2: y^2 = x^3 + 4036*x + 11557.
```

Their traces are `192,-169`, their groups are `(19,608)` and `(19,627)`,
and their CM squareclasses are `-7,-51`. In the stored bases,
`diag(1,16)` is an anti-isometry. The graph has `361` points.

The quotient Weil polynomial is

```text
T^4 - 23*T^3 - 8962*T^2 - 270089*T + 137898049.
```

SageMath and remote Magma independently certify these data.

## Quotient curve

The theta quotient over `F_(11743^12)` has absolute Kohel invariants
`(11336,8788,9369)`. Normalized Igusa-Clebsch invariants are
`(1,3992,8409,8638)`. Mestre reconstruction and L-polynomial twist
selection give

```text
y^2 =
9500*x^6 + 7591*x^5 + 6679*x^4 + 7190*x^3
+ 1439*x^2 + 4884*x + 3417.
```

SageMath independently certifies squarefreeness, genus, moduli, and the
Frobenius polynomial. Magma independently certifies G2 invariants
`(8456,11363,10925)` and the reciprocal L-polynomial.

## Map recovery

The general map-recovery engine is running with 46 deterministic samples
over `F_(11743^24)`. Base-field descent and independent Magma map
verification follow automatically after interpolation.
