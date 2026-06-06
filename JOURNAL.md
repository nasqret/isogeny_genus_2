# Project Journal

## 2026-06-06

### Source acquisition

- Downloaded arXiv source for `2606.02429` and archived the original tarball.
- Preserved the top-level source as `sources/paper.tex` and bibliography as
  `sources/bibliography.bib`.
- Downloaded the 13-page arXiv PDF.
- Recorded paper metadata: version 1 submitted June 1, 2026; title
  *Finding the complement of an elliptic curve inside a Jacobian*.

### Companion repository

- Cloned `https://github.com/G4ll/NoteOnGenus2Covers`.
- Pinned the inspected state at commit
  `d7f91b16b325e7832b3647c514e6cbbfb949f0d6`, committed May 11, 2026.
- The repository contains Magma code for the degree-3 reconstruction,
  degree-3 complementary map, and degree-5 reconstruction.
- No degree-4 computation is present in the companion repository.
- The upstream files are evidence and implementation references; they are not
  counted as independent verification.

### Environments

- SageMath 10.8 is available locally.
- Jupyter Book 1.0.4.post1, Pandoc 3.8.2.1, and latexmk 4.86a are available.
- GitHub CLI is authenticated as `nasqret`.
- SSH access to `lts-faculty.wmi.amu.edu.pl` succeeds.
- Remote Magma is `/opt/magma/current/magma`, with
  `/opt/magma/current -> V2.28-3`.
- The remote host provides GNU screen and reports 3 processors.
- `magma` is available in a remote Bash login shell but not on the default
  non-login SSH PATH.

### Initial claim audit

- Identified computation clusters for the general algorithm, degree-3,
  degree-4, degree-5, degree-2, and `j`-invariant formulas.
- Created an initial atomic ledger with source-line references.
- Formal verification remains at 0% until executable independent evidence is
  generated.

### Scaffold

- Initialized the local Git repository on branch `main`.
- Began the plan, journal, memory, Obsidian vault, Jupyter Book, computation
  directories, and live dashboard.

### First independent SageMath verification batch

- Added `computations/sage/verify_degree3_basic.sage`.
- Ran the artifact with SageMath 10.8; the latest recorded run completed in
  0.049 seconds.
- Independently verified claims C012, C013, C015, C018, and C020 using exact
  polynomial, rational-function, and function-field identities.
- Recorded the machine-readable certificate in
  `results/sage_degree3_basic.json`.
- Kept the degree computation C019 and the elimination claims C014, C016,
  and C017 open; this batch does not certify them.

### Remote Magma execution

- Uploaded `computations/magma/smoke_test.m` to the isolated project directory
  on `lts-faculty.wmi.amu.edu.pl`.
- The first run exposed a convention distinction: Magma's discriminant of the
  cubic polynomial is `-3859375`, while the elliptic-curve discriminant is
  `16*(-3859375) = -61750000`.
- Corrected the smoke artifact to state both quantities explicitly.
- The rerun under Magma V2.28-3 printed `MAGMA_SMOKE_OK`.
- Preserved the result and remote session-log path in
  `results/magma_remote_smoke.json`.

### Private publication checkpoint

- Created the private repository
  `https://github.com/nasqret/isogeny_genus_2`.
- Prepared the validated baseline, source archive, ledger, documentation,
  dashboard, and first independent evidence batch for the initial push.

### Degree-3 cluster completion

- Added `computations/sage/verify_degree3_elimination.sage`.
- Reconstructed C014 from the symmetric-square equations by eliminating
  `p_y`, taking the exact polynomial GCD, and matching the displayed
  factorized singular model.
- Recovered `j=6912/247` independently from binary-quartic invariants and
  matched Kuhn's formula for C016.
- For C017, repeated the complete elimination and invariant calculation for
  `(1,2,3)`, `(2,3,5)`, `(1,4,2)`, and `(4,7,3)`; every exact comparison
  passed.
- Added `computations/magma/verify_degree3_map.m` and ran it remotely.
  Magma constructed the displayed map directly and returned degree `3`,
  verifying C019.
- The initial degree-3 claim cluster C012-C020 is now fully verified.
- The first unified GitHub Actions build failed because Pandoc was absent from
  the runner. The workflow now installs Pandoc explicitly before regenerating
  the article and Jupyter Book.

### Degree-4 example

- Added `computations/sage/verify_degree4_example.sage`.
- Derived the critical cubic and reduced genus-2 sextic directly from the two
  discriminants, including the displayed factors `-256` and `-16`.
- Recorded the rescaling convention: after passing to the displayed models,
  the map has second coordinate `y*g'(x)/4`.
- Normalized the self-fiber-product cubic through
  `Y^2=-s^4+16s^2-32s` and verified the birational map
  `x=12-72/s`, `y=-108Y/s^2` to
  `y^2=x^3-432x-8208`.
- Added and remotely executed
  `computations/magma/verify_degree4_complement.m`; Magma independently
  certified a nonsingular genus-one curve isomorphic to the target.
- Verified the `-1` twist relation with Cremona 11a3, rank zero, torsion
  group `Z/5Z`, and ramification `j=-27648/11`.
