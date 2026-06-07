# Degree-13 Frey-Kani Synthesis

## Scope

This report records the first construction-engine certificate beyond degree
11. It starts from two elliptic curves and a torsion anti-isometry, rather
than from a known genus-2 curve. SageMath and Magma independently verify the
finite-field data.

The certificate proves that the principally polarized quotient is
geometrically a smooth genus-2 Jacobian, reconstructs an explicit equation
over the base field, recovers both degree-13 maps on its Rosenhain model,
descends them to the fixed base-field sextic, and verifies both morphisms
independently in Magma.

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

## Theta quotient and descent

The parameterized Sage implementation places both elliptic curves in
level-2 theta coordinates over `F_(8009^12)`. It checks the derived
elliptic Kummer coordinates against scalar multiplication and normal
addition, forms the decomposable product theta null, and evaluates the
degree-13 isogeny on the graph basis.

The quotient Rosenhain model has Igusa-Clebsch invariants

```text
(2419, 7563, 6738, 5346)
```

and absolute invariants

```text
(4139, 7829, 4340).
```

The absolute invariants are fixed by `8009`-Frobenius, so the moduli point
descends to `F_8009`.

## Explicit base-field curve

Magma's Mestre reconstruction, followed by quadratic-twist selection using
the quotient L-polynomial, gives the fixed representative

```text
C: y^2 =
6042*x^6 + 4620*x^5 + 6357*x^4 + 3661*x^3
+ 4018*x^2 + 5767*x + 84.
```

SageMath independently verifies that this sextic is squarefree, that `C` has
genus two, that its absolute Igusa invariants are `(4139,7829,4340)`, and
that its Frobenius polynomial is exactly the required quotient polynomial.

## Reproducibility

- SageMath:
  `computations/sage/verify_degree13_anti_isometry.sage`
- reusable SageMath library:
  `computations/sage/lib/frey_kani_synthesis.sage`
- reusable theta-gluing library:
  `computations/sage/lib/frey_kani_theta_gluing.sage`
- explicit Sage reconstruction:
  `computations/sage/reconstruct_degree13_curve.sage`
- Sage recovery of both maps:
  `computations/sage/recover_degree13_maps.sage`
- Sage transport and coefficient descent:
  `computations/sage/descend_degree13_maps.sage`
- Magma:
  `computations/magma/verify_degree13_anti_isometry.m`
- independent Magma Mestre reconstruction:
  `computations/magma/reconstruct_degree13_curve.m`
- independent Magma map verification:
  `computations/magma/verify_degree13_maps.m`
- certificates:
  `results/sage_degree13_anti_isometry.json` and
  `results/magma_degree13_anti_isometry.json`,
  `results/sage_degree13_curve.json`, and
  `results/magma_degree13_curve.json`, plus
  `results/sage_degree13_maps.json`,
  `results/sage_degree13_descended_maps.json`, and
  `results/magma_degree13_maps.json`
- remote transcript:
  `results/remote/magma_degree13_anti_isometry.log` and
  `results/remote/magma_degree13_curve.log`, plus
  `results/remote/magma_degree13_maps.log`

The recorded runs took under `0.4` seconds in SageMath and `0.080` seconds
in Magma for the graph certificate. The explicit theta reconstruction took
`3.742` seconds in SageMath, and the independent Magma reconstruction took
`0.636` seconds. Map recovery took `251.786` seconds, base-field descent
took `3.773` seconds, and final Magma map verification took `0.160` seconds
and `32.09 MB`.

## Degree-13 maps

The dual kernel was converted from Kummer theta coordinates to Mumford
divisors. Over `F_(8009^24)`, exact Jacobian sums resolve all level-2 sign
choices needed to evaluate the dual isogeny.

Thirty-four deterministic source points give rank-one target tensors. The
two interpolated elliptic X-coordinates both have numerator degree `13` and
denominator degree `12`. The elliptic equations then recover exact
Y-coordinates `y*G_i(x)`. Both function-field identities vanish, and both
invariant differentials pull back to linear forms.

## Base-field descent

The fixed sextic has branch-factor degrees `1`, `2`, and `3` over
`F_8009`, so its six branch points split in `F_(8009^24)`. Enumerating the
`120` Möbius transformations determined by the images of infinity, `0`, and
`1` produces exactly one projective class carrying the Rosenhain branch set
to the fixed sextic branch set.

After solving the hyperelliptic scaling identity, both maps transport to the
fixed sextic. Every transported coefficient is fixed by `8009`-Frobenius,
so coefficientwise descent gives formulas over `F_8009`. Both descended
X-coordinates have numerator and denominator degree `13`.

The exact elliptic identities hold over `F_8009`. Their invariant
differentials pull back to

```text
618*x + 1045
209*x + 6653,
```

which normalize to the Hasse-Witt eigendirections `[1,3779]` and
`[1,7873]`. Remote Magma independently constructs both morphisms and
returns degrees `13` and `13`, with target j-invariants `81` and `3213`.

## Next construction step

B014 is complete. The next milestone is to parameterize the finite-field
search and certification pipeline, then search for new examples in prime
degrees 17 and 19.
