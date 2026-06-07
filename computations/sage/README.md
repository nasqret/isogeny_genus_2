# SageMath Computations

Each `.sage` file must:

1. state the claim IDs it verifies;
2. use exact arithmetic;
3. fail with an assertion on disagreement;
4. write a compact JSON or text certificate under `results/`;
5. document SageMath version and elapsed time.

## Beyond-paper artifacts

- `verify_degree5_family_structure.sage`: generic branch quadratic,
  three-node quartic, normalization conic, and canonical branch-field point.
- `lib/degree5_complement.sage`: exact conic parameterization, off-diagonal
  pair curve, orientation square classes, branch quartic, and complementary
  elliptic `j`-invariant.
- `verify_degree5_complement.sage`: the article specialization and a genuinely
  quadratic branch-field example.
- `census_degree5_family.sage`: exact degree-5 source curves, maps, canonical
  conic points, complementary quartics, and `j`-minimal polynomials.
- `verify_degree7_kumar_specialization.sage`: rational degree-7 benchmark and
  41 exact Euler-factor identities.
- `lib/kumar_square_discriminant_families.sage`: exact importer for Kumar's
  Hilbert modular surfaces, Igusa-Clebsch tuples, symmetric elliptic
  `j`-functions, and tautological genus-2 curves in degrees `6` through `11`.
- `verify_kumar_family_importer.sage`: all-degree surface/Igusa/`j` audit and
  an executable degree-7 target-discovery specialization.
- `verify_kumar_all_tautological_curves.sage`: constructs one exact
  nonsingular tautological genus-2 curve in every degree `6` through `11`.
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

## Kumar family importer

```sage
load("computations/sage/lib/kumar_square_discriminant_families.sage")

D = kumar_surface_rhs(8)
I2, I4, I6, I10 = kumar_igusa_clebsch_invariants(8)
j_polynomial = kumar_j_polynomial(8)

sample = specialize_kumar_family(
    degree=8,
    r_value=-3,
    s_value=-3,
)
C = sample["source_curve"]
```

If `D(r,s)` is nonsquare, the curve is constructed over the exact quadratic
field generated by `z^2=D(r,s)`. A rational `z_value` can be supplied for a
rational point on the Hilbert modular double cover. The degree-11 upstream
curve is 3.1 MB; an iterative arithmetic parser avoids Python AST depth
limits while retaining exact Sage arithmetic.

## Degree-8 benchmark

`recover_degree8_maps.sage` specializes `Y_-(64)` at
`(r,s,z)=(4,-2,-1280)`, discovers both rational targets and Hasse-Witt
eigenlines, reconstructs one compact `X(x)` coordinate and one
`X=A(x)+yB(x)` coordinate, lifts the complementary scale from primes `61`
and `67`, and certifies both degree-8 maps exactly.

## Degree-10 and degree-11 benchmarks

`recover_degree10_maps.sage` and `recover_degree11_maps.sage` specialize
Kumar's `Y_-(100)` and `Y_-(121)` at rational points, discover the unique
rational target twists and Hasse-Witt eigenlines, reconstruct both scales by
resumable CRT, and certify all four maps in the full quadratic function
fields. `export_degree10_11_magma.sage` emits the static independent Magma
degree certificates.
