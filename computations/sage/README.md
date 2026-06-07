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
- `lib/elliptic_factor_discovery.sage`: discovers rational target twists from
  candidate `j`-invariants and genus-2 Frobenius factors, searches bounded
  eigenform lines, and invokes exact map recovery.
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

When the scale and target center are not known, use:

```sage
discovery = discover_elliptic_cover(
    source_polynomial=F,
    target_curve=E,
    eigenform=r + s*x,
    cover_degree=n,
    source_point=None,       # or (x0, y0)
    mordell_weil_bound=n,
)

answers = discovery["maps"]
```

For each candidate center, reconstruction runs over `k(scale)`. The exact
elliptic identity produces a polynomial in `scale`; its roots in the base
field are passed through the ordinary characteristic-zero verifier. Over
`QQ`, the center can be found by a bounded Mordell-Weil search. The origin,
small multiples, and degree-sized multiples are tested early.

The routine infers rational degree bounds from local valuations when the
source center is at infinity. At finite source points it searches all degree
patterns with maximum degree `n`. A candidate is returned only if the exact
completed-square elliptic identity vanishes in the source function field.

The base recovery API assumes that the target curve and eigenform are known.
Over number fields other than `QQ`, center candidates must currently be
supplied. The wrapper below removes the target-model and eigenform inputs
when candidate `j`-invariants are available.

## Target and eigenform discovery

For Hilbert-modular families that supply candidate `j`-invariants:

```sage
load("computations/sage/lib/elliptic_cover_recovery.sage")
load("computations/sage/lib/elliptic_factor_discovery.sage")

answer = discover_covers_from_j_invariants(
    source_polynomial=F,
    j_invariants=[j1, j2],
    cover_degree=n,
    prime_bound=80,
    eigenform_height_bound=1,
    mordell_weil_bound=n,
)
```

The target search enumerates signed squarefree twist classes supported on the
source discriminant. A twist survives only when its trace belongs to one of
the two quadratic factors of the source Frobenius polynomial at every tested
good split prime. Surviving targets are tested against primitive projective
lines `[r:s]`, representing `(r+s*x) dx/y`. Scale, center, and map recovery
then use exact characteristic-zero identities.

The twist-support, Frobenius-prime, eigenform-height, and Mordell-Weil bounds
are explicit search bounds, not proof substitutes. The returned map identity
is the final certificate. Discovering the candidate `j`-invariants from an
arbitrary source curve remains outside this API.
