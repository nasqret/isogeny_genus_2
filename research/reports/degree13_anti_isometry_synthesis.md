# Degree-13 Frey-Kani Synthesis

## Scope

This report records the first construction-engine certificate beyond degree
11. It starts from two elliptic curves and a torsion anti-isometry, rather
than from a known genus-2 curve. SageMath and Magma independently verify the
finite-field data.

The certificate proves that the principally polarized quotient is
geometrically a smooth genus-2 Jacobian. It does not yet provide an explicit
equation for that curve or its two degree-13 maps.

## Elliptic curves

Work over `F_8009` with

```text
E1: y^2 = x^3 + 5553*x + 5419
E2: y^2 = x^3 + 2531*x + 1402.
```

The invariants are:

| curve | j | cardinality | group invariants | trace | CM squareclass |
|---|---:|---:|---|---:|---:|
| `E1` | 81 | 7943 | `(13,611)` | 67 | -163 |
| `E2` | 3213 | 8112 | `(13,624)` | -102 | -2 |

Thus both full `13`-torsion modules are rational. The stored bases are

```text
P1 = (3600 : 411 : 1), P2 = (5265 : 3005 : 1)
Q1 = (6171 : 1633 : 1), Q2 = (3628 : 2373 : 1).
```

## Anti-isometry

In these bases the Weil pairings are compatible precisely for determinant
`3`. The matrix

```text
[1 0]
[0 3]
```

maps `(P1,P2)` to `(Q1,3*Q2)`. The pairing values are `1420` and `6379`;
their product is `1` in `F_8009`.

The graph contains exactly `13^2=169` points and is maximally isotropic.
Exactly

```text
13*(13^2-1) = 2184
```

matrices in `GL(2,F_13)` have the required determinant.

## Irreducibility

The Frobenius discriminants are

```text
-13^2*163
-104^2*2.
```

The ordinary geometric endomorphism fields are therefore
`Q(sqrt(-163))` and `Q(sqrt(-2))`. They are distinct, so the elliptic curves
are geometrically nonisogenous. This supplies the strong Frey-Kani
irreducibility condition. Consequently the descended principal polarization
is geometrically a smooth genus-2 Jacobian.

The quotient Weil polynomial is

```text
T^4 + 35*T^3 + 9184*T^2 + 280315*T + 64144081.
```

## Reproducibility

- SageMath:
  `computations/sage/verify_degree13_anti_isometry.sage`
- reusable SageMath library:
  `computations/sage/lib/frey_kani_synthesis.sage`
- Magma:
  `computations/magma/verify_degree13_anti_isometry.m`
- certificates:
  `results/sage_degree13_anti_isometry.json` and
  `results/magma_degree13_anti_isometry.json`
- remote transcript:
  `results/remote/magma_degree13_anti_isometry.log`

The recorded runs took under `0.4` seconds in SageMath and `0.080` seconds
in Magma; Magma used `32.09 MB`.

## Next construction step

The next B014 milestone is to reconstruct an explicit genus-2 model of the
quotient and then recover the two primitive degree-13 maps. After that, the
finite-field search and certification code will be generalized to degrees
17 and 19.
