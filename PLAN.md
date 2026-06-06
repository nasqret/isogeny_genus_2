# Full Computation Reconstruction Plan

## Objective

Build a comprehensive, reviewable, and reproducible collection of SageMath and
Magma computations that verifies every computational claim in
`sources/paper.tex`. Publish the work as a private GitHub repository and as a
Jupyter Book containing a copy of the article with direct links to evidence.

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
| Publication | Private GitHub repository and continuous validation | Operational |
| Beyond paper | Separate B-series research ledger | Started |

## Phases

### Phase 0: Reproducible baseline

- Initialize local git and private GitHub repository.
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
- Push validated checkpoints to the private GitHub repository.

## Final paper-verification state

- 40 tracked claims.
- 36 independently verified.
- 4 disproved as printed: C027-C030.
- 0 unresolved.
- Strict audit: `python3 scripts/audit-claims.py`.

## Beyond-paper program

The B-series is deliberately separate from the frozen article ledger.

1. Generalize the degree-5 base-field point and parametrization from
   `(a,b)=(7,1)` to a locus in the full two-parameter family.
2. Derive a generic complementary `j` formula for degree 5.
3. Build a large exact census in degrees 3, 4, and 5.
4. Add number-field arithmetic and automated source-to-CAS discrepancy
   detection.

Current bounded task: B002, the generic degree-5 base-field parametrization
locus.
