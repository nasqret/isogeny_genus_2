# SageMath Computations

Each `.sage` file must:

1. state the claim IDs it verifies;
2. use exact arithmetic;
3. fail with an assertion on disagreement;
4. write a compact JSON or text certificate under `results/`;
5. document SageMath version and elapsed time.

## Beyond-paper artifacts

- `verify_degree5_family_structure.sage`: generic branch quadratic,
  three-node quartic, and normalization conic.
- `census_degree5_family.sage`: exact degree-5 source curves, maps, and conic
  solubility over the rational and branch fields.
- `verify_degree7_kumar_specialization.sage`: rational degree-7 benchmark and
  41 exact Euler-factor identities.
- `verify_degree7_maps.sage`: both primitive degree-7 maps, their differential
  pullbacks, pole divisors, and exact target identities.
- `lib/elliptic_cover_recovery.sage`: reusable exact recovery library for
  genus-2 covers of arbitrary degree, with finite or infinite source centers,
  finite or identity target centers, quintic or sextic source models, and
  exact number fields.
- `test_general_elliptic_cover_recovery.sage`: regression cases in degrees
  `3`, `5`, and `7`, including finite centers and a quadratic number field.
- `recover_degree7_maps.sage`: applies the reusable library to both
  degree-7 maps.
- `verify_composed_high_degree_maps.sage`: exact nonprimitive maps of degrees
  20 and 80.

## General recovery API

```sage
load("computations/sage/lib/elliptic_cover_recovery.sage")

answer = recover_elliptic_cover(
    source_polynomial=F,
    target_curve=E,
    eigenform=r + s*x,
    differential_scale=c,
    cover_degree=n,
    source_point=None,       # or (x0, y0)
    target_center=E(0),      # or a finite point of E
)

X = answer["x_coordinate"]
M = answer["y_multiplier"]
N = answer["y_offset"]      # the map is (X, y*M + N)
```

The routine infers rational degree bounds from local valuations when the
source center is at infinity. At finite source points it searches all degree
patterns with maximum degree `n`. A candidate is returned only if the exact
completed-square elliptic identity vanishes in the source function field.

The current API assumes that the target curve, eigenform, differential scale,
and image of the expansion point are known. Discovering those inputs is a
separate modular/period/finite-field stage of B010.
