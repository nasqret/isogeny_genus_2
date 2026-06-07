# Degree-17 Frey-Kani Synthesis

## Certified input

Over `F_8263`, use

```text
E1: y^2 = x^3 + 1728
E2: y^2 = x^3 + 6442*x + 3171.
```

Their traces are `172` and `-117`, their point-group invariants are
`(34,238)` and `(17,493)`, and their CM squareclasses are `-3` and `-67`.
Both full `17`-torsion modules are rational. In the deterministic bases, the
matrix `diag(1,6)` is an anti-isometry. Its graph has `289` points.

## Quotient

The irreducible Frey-Kani quotient has Weil polynomial

```text
T^4 - 55*T^3 - 3598*T^2 - 454465*T + 68277169.
```

The theta quotient over `F_(8263^12)` has absolute Kohel invariants
`(893,1328,7156)`. Mestre reconstruction and twist selection give

```text
y^2 =
5422*x^6 + 4306*x^5 + 4875*x^4 + 5667*x^3
+ 6314*x^2 + 4554*x + 6050.
```

SageMath certifies squarefreeness, genus, moduli, and the Frobenius
polynomial. Remote Magma independently certifies normalized Igusa-Clebsch
invariants `(1,4851,430,7240)`, G2 invariants `(4393,3171,8140)`, and the
reciprocal L-polynomial.

## General map-recovery algorithm

`computations/sage/lib/frey_kani_map_recovery.sage` accepts a configuration
containing the prime, field, elliptic factors, torsion bases, graph matrix,
fixed sextic, Hasse-Witt eigendirections, extension degree, and sample count.
It then:

1. reconstructs the theta quotient and dual isogeny;
2. converts the dual kernel to exact Mumford divisors;
3. resolves level-2 addition signs by exact Jacobian sums;
4. evaluates the dual isogeny on deterministic Abel-Jacobi points;
5. factors every image as a rank-one elliptic product tensor;
6. interpolates both elliptic X-coordinates;
7. reconstructs the Y-coefficients and proves both target equations;
8. verifies that both invariant differentials pull back to linear forms.

The degree-17 driver uses 42 samples over `F_(8263^24)`. Base-field descent
and independent Magma map certification are the remaining steps.
