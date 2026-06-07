# Map-Recovery Optimization

## Motivation

Exact map recovery dominates the prime-degree pipeline:

| degree | samples | recovery seconds |
|---:|---:|---:|
| 13 | 34 | 251.786 |
| 17 | 42 | 384.812 |
| 19 | 46 | 586.712 |
| 23 | 54 | 1100.736 |

By contrast, theta-quotient reconstruction takes at most 18.8 seconds,
base-field descent takes at most 6.5 seconds, and final Magma verification
takes at most 0.2 seconds in these runs.

## Instrumentation

`computations/sage/lib/frey_kani_map_recovery.sage` now emits flushed
`PHASE_START` and `PHASE_DONE` records and stores exact phase timings in each
result JSON. The phases are:

1. theta quotient;
2. dual-kernel recovery;
3. level-2 kernel preparation;
4. sample selection;
5. sample theta conversion;
6. dual-isogeny evaluation;
7. target factorization;
8. rational interpolation;
9. map identity certification.

This makes a detached screen log immediately useful and separates conversion
cost from isogeny cost.

## Degree-13 profile

The instrumented baseline takes `173.008` seconds. The dual-isogeny phase
alone takes `157.980` seconds, or more than 91% of the complete run. Sample
selection, theta conversion, factorization, interpolation, and identity
certification together are negligible by comparison.

The first optimization hypothesis replaced the exact-addition linear scan
with projective-coordinate dictionary keys. It was rejected: total runtime
increased to `192.131` seconds (`+11.05%`) and the dual-isogeny phase
increased to `176.591` seconds (`+11.78%`). Equality scans are not the
dominant cost at this sample size.

## Common root extension

The upstream AVIsogenies evaluator adjoins one formal prime-th root for every
compatible lift. The degree-13 batch has 71 such roots, so its arithmetic is
performed in a quotient polynomial ring with 71 generators.

The optimized evaluator instead:

1. computes the same compatible lifts over `F_(8009^24)`;
2. embeds them in one degree-13 extension;
3. chooses all 71 roots there;
4. performs the unchanged kernel-table recurrence;
5. raises all coordinates to the 13th power;
6. requires every final coordinate to descend to `F_(8009^24)`.

This path completes in `115.487` seconds. The dual-isogeny phase drops to
`100.451` seconds, a `36.42%` reduction, while total runtime drops `33.25%`.

`verify_degree13_recovery_optimization.sage` reconstructs the recorded field
and compares the formulas exactly. Both X-coordinates are identical to the
symbolic baseline. The first Y-coordinate is identical; the second differs
by the target involution `Y -> -Y`, and its differential changes by the same
sign. All interpolation samples and elliptic identities remain certified.

## Cross-degree gate

Degree 17 validates the same mechanism independently:

- 87 compatible-lift roots are realized in one degree-17 extension;
- every final image coordinate descends to `F_(8263^24)`;
- both X-maps are identical to the symbolic baseline;
- the two Y-map signs are again `[1,-1]`, with matching differential signs;
- all 42 interpolation samples and both elliptic identities are exact;
- total runtime falls from `384.812` to `272.338` seconds, a `29.23%`
  reduction.

## Finite-field justification

Let the level-2 field have order \(q\), and let the odd prime degree be
\(\ell\). In the synthesis pipeline, full rational \(\ell\)-torsion implies
\(q \equiv 1 \pmod{\ell}\). For \(a\in\mathbf F_q^\times\), its image in
\(\mathbf F_{q^\ell}\) has exponent multiplied by

\[
1+q+\cdots+q^{\ell-1},
\]

which is divisible by \(\ell\). Hence every element of \(\mathbf F_q\) is an
\(\ell\)-th power in \(\mathbf F_{q^\ell}\). The optimized algorithm may
therefore choose all compatible roots in one common extension. The final
\ell\)-th-power theta sums are independent of those choices; the
implementation additionally checks coefficient-by-coefficient descent to
\(\mathbf F_q\).

The common-extension evaluator is now the default general strategy.
`symbolic_quotient_ring` remains available as a regression oracle. B022 is
complete, and degree 29 can use the optimized path.
