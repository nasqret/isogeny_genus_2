# Full Computation Reconstruction Plan

## Objective

Build a comprehensive, reviewable, and reproducible collection of SageMath and
Magma computations that verifies every computational claim in
`sources/paper.tex`, then develop a degree-independent theory and implementation
for primitive genus-2 to elliptic maps. Publish the work in a public GitHub
repository and a Jupyter Book with direct links to exact evidence.

## Acceptance criteria

A computational claim is **verified** only when:

1. its exact source location and statement are recorded;
2. a deterministic SageMath or Magma artifact exists;
3. the artifact runs successfully in the documented environment;
4. output or a compact certificate is committed under `results/`;
5. the reconstructed article and claim index link to the evidence;
6. assumptions, field extensions, excluded parameters, and probabilistic
   steps are explicit.

## Workstreams

| Workstream | Deliverable | State |
|---|---|---|
| Source archive | arXiv TeX, PDF, bibliography, metadata | Complete |
| Upstream audit | Pinned copy of the authors' companion Magma repository | Complete |
| Claim inventory | Atomic ledger of every computational assertion | Complete: C001-C040 |
| Operations | Live dashboard with local/remote status | Operational |
| Documentation | Plan, journal, memory, Obsidian vault, Jupyter Book | Complete and validated |
| General algorithm | Reusable symmetric-square and normalization routines | Complete |
| Degree 3 | Independent reconstruction of curve, complement, and map | Complete |
| Degree 4 | Independent reconstruction, arithmetic, and label checks | Example obligations C021-C025 verified |
| Degree 5 | Number-field reconstruction and complementary curve | Complete; four article claims disproved |
| Degree 2 and invariants | Maps, generic j formulas, and twist identities | Complete |
| Publication | Public GitHub repository and continuous validation | Operational |
| Beyond paper | High-degree B-series research program | Active |

## Phases

### Phase 0: Reproducible baseline

- Initialize local git and GitHub repository.
- Archive the exact arXiv source and the pinned upstream repository.
- Create claim ledger, journal, memory, vault, book, dashboard, and validation
  scripts.
- Verify local SageMath and remote Magma environments.

### Phase 1: Complete claim inventory

- Audit every equation, example, algorithm step, and externally cited
  computation.
- Split compound claims into independently verifiable obligations.
- Record dependencies and the minimum sufficient certificate.

### Phase 2: General algorithm library

- Implement symmetric rational-function rewriting.
- Implement the equations of the complementary genus-one component.
- Implement genus-zero parametrization, elimination, squarefree
  normalization, and elliptic-model conversion.
- Implement the divisor/interpolation algorithm for the complementary map.

### Phase 3: Paper examples

- Reconstruct degree 3 in SageMath and Magma, including the explicit map.
- Reconstruct the quartic critical-curve example and its arithmetic.
- Reconstruct the degree-5 number-field computation and compare
  independently with Shaska's invariant formulas.
- Verify the degree-2 family and the displayed `j`-invariant identities.

### Phase 4: Strict audit and publication

- Require all claim artifacts to execute.
- Build the article copy, claim index, Jupyter Book, and dashboard.
- Preserve local and remote environment metadata and transcripts.
- Push validated checkpoints to the public GitHub repository.

## Final paper-verification state

- 40 tracked claims.
- 36 independently verified.
- 4 disproved as printed: C027-C030.
- 0 unresolved.
- Strict audit: `python3 scripts/audit-claims.py`.

## High-degree research program

The B-series is deliberately separate from the frozen article ledger.

### Theory target

For a maximal degree-\(n\) cover \(C\to E\), construct the complementary
degree-\(n\) cover \(C\to E'\), certify the induced \((n,n)\)-isogeny
\(E\times E'\to\operatorname{Jac}(C)\), and record the anti-isometry on
\(n\)-torsion. Nonprimitive compositions are tracked separately.

### Algorithm target

1. **Given-map engine:** symmetric self-fiber, component selection,
   normalization, genus-one conversion, and complementary map recovery.
2. **Eigenform engine:** recover unknown maps from the split differential
   \((r+sx)dx/y\) using modular polynomial solving.
3. **Family engine:** solve specializations, interpolate parameter formulas,
   and certify them generically.
4. **CRT backend:** compute over good finite fields, lift coefficients, and
   verify over the original field.
5. **Galois engine:** implement the degree-independent non-diagonal
   fiber-product quotient.
6. **Construction engine:** synthesize new examples from Frey-Kani
   anti-isometries.

### Degree milestones

| Degree | Deliverable |
|---|---|
| 5 | Prove the generic normalization conic and its branch-field splitting locus; derive \(j(E')\) |
| 6 | Both primitive maps and nonexceptional \(S_6\) monodromy certified |
| 7 | Recover both maps for the certified Kumar benchmark |
| 8 | Both primitive maps and full \(S_8\) monodromy certified |
| 9 | Both primitive maps, CRT centers, and full \(S_9\) monodromy certified |
| 10-11 | Both primitive rational map pairs certified in SageMath and Magma |
| \(>11\) | Generate primitive examples from anti-isometries and recover maps by CRT |

### Implemented checkpoint

- Generic degree-5 quartic, three nodes, normalization conic, canonical
  branch-field point, and complementary quartic-invariant formula: exact.
- Ten exact primitive degree-5 maps over quadratic branch fields, including
  exact complementary \(j\)-invariants and minimal polynomials: exact.
- One degree-7 split benchmark with 41 Euler-factor identities and both
  primitive maps: exact in SageMath, with independent Magma degree checks.
- One rational degree-6 benchmark with both primitive maps: exact in
  SageMath, with independent Magma degree checks. The complementary map uses
  the full function field `Q(x,y)`, and its scale is reconstructed by CRT.
- One rational degree-8 benchmark with both primitive maps: exact in
  SageMath, with independent Magma degrees, source automorphism-group order
  `2`, and full `S8` monodromy over the elliptic base. Its complementary map
  again uses `Q(x,y)`, and CRT reconstructs scale `2`.
- One rational degree-9 benchmark at `(r,s,z)=(3,-7,-29280)` with both
  primitive maps: exact in SageMath, with independent Magma degrees and full
  `S9` monodromy over the elliptic base. Modular center searches reconstruct
  the two finite infinity images from 128-bit and 184-bit CRT moduli.
- One rational degree-10 benchmark at
  `(r,s,z)=(-4/5,1/5,18/125)` with both primitive maps: exact in SageMath and
  independently degree-checked in Magma. Both coordinates use `Q(x,y)`;
  their scales were reconstructed with 133-bit and 276-bit CRT moduli.
- One rational degree-11 benchmark at `(r,s,z)=(3/2,1/2,3/8)` with both
  primitive maps: exact in SageMath and independently degree-checked in
  Magma. Both coordinates use `Q(x,y)`; their scales were reconstructed with
  127-bit and 238-bit CRT moduli.
- Explicit splitting kernels for the degree-6 and degree-8 benchmarks:
  Magma pulls full torsion bases into the genus-2 Jacobians, recovers graph
  matrices modulo `6` and `8`, enumerates exactly `36` and `64` kernel
  points, and verifies inverse Weil pairings.
- The full Galois-closure quotient is implemented. SageMath constructs the
  invariant fixed-field equations from `N(t)-zD(t)` and
  `q^2=f(z)(s^2-4p)`. Magma certifies `H_Z`, the graph subgroup `H_W`, the
  critical-quartic intersection, and genus-one branch actions for generic
  odd degrees through `15` and the degree-6/7/8 benchmarks.
- The compact degree-7 map has exact `S7` monodromy. Its discriminant square
  class is `2*target_cubic`, distinct from the elliptic-base class, so base
  change preserves `S7`.
- The finite-field backend lifts complete projective coefficient vectors for
  both `X=A(x)/D(x)` and `X=A(x)/D(x)+y*B(x)/D(x)`. Partial CRT state is
  resumable and every lift is accepted only after exact characteristic-zero
  map and degree certification.
- Degree-20 and degree-80 maps by elliptic multiplication: exact,
  nonprimitive.
- Kumar's Hilbert modular surfaces, Igusa-Clebsch invariants, symmetric
  elliptic `j`-functions, and tautological sextics are imported exactly for
  every degree 6 through 11. One nonsingular genus-2 specialization is
  certified in each degree.
- The initial construction-engine milestone is complete in degree 13.
  Over `F_8009`, SageMath and Magma independently certify an anti-isometry
  graph of order `13^2`, an irreducible Frey-Kani principal polarization,
  and the quotient Weil polynomial. This proves the quotient is geometrically
  a smooth genus-2 Jacobian, but does not yet reconstruct its curve equation.

Current bounded tasks, in order:

1. reconstruct an explicit genus-2 curve for the certified degree-13
   anti-isometry quotient;
2. recover and certify its two degree-13 elliptic maps;
3. turn the degree-13 search into a parameterized prime-degree synthesis
   engine and run it in degrees 17 and 19.
