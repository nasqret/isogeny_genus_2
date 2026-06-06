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
| Claim inventory | Atomic ledger of every computational assertion | Initial pass complete; second audit pending |
| Operations | Live dashboard with local/remote status | Operational |
| Documentation | Plan, journal, memory, Obsidian vault, Jupyter Book | Baseline complete |
| General algorithm | Reusable symmetric-square and normalization routines | Not started |
| Degree 3 | Independent reconstruction of curve, complement, and map | 5 of 9 initial obligations verified |
| Degree 4 | Independent reconstruction, arithmetic, and label checks | Not started |
| Degree 5 | Number-field reconstruction and complementary curve | Not started |
| Publication | Private GitHub repository and continuous validation | Pending |

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

## Current bounded task

Publish the validated baseline privately, reproduce the remaining degree-3
elimination and map-degree claims in Magma and SageMath, and continue the
second-pass claim inventory audit.
