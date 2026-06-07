# Durable Project Memory

## Purpose

This project reconstructs every computational claim in
`sources/paper.tex` using SageMath locally and Magma remotely.

## Sources of truth

- Claim status: `research/data/claims.json`
- Environment readiness: `research/data/environments.json`
- Remote jobs: `research/data/remote_jobs.json`
- Recent evidence: `research/data/recent_results.json`
- Human progress log: `JOURNAL.md`
- Execution plan: `PLAN.md`
- Live dashboard payload: generated `dashboard/status.json`
- Ephemeral remote telemetry: generated `dashboard/remote_runtime.json`

## Verification policy

- Do not count copied upstream output as independent verification.
- Do not mark a claim verified without executable code and saved evidence.
- Keep implementation completeness separate from verification completeness.
- Preserve source discrepancies as `review_needed`; do not silently repair the
  paper.
- Keep live remote runtime telemetry separate from committed mathematical
  evidence.

## Environments

- Local: SageMath 10.8 on macOS.
- Remote: Magma V2.28-3 at `/opt/magma/current/magma` on
  `lts-faculty.wmi.amu.edu.pl`.
- Remote commands requiring Magma must use a Bash login shell or the absolute
  binary path.
- Long remote work should run in named GNU screen sessions with logs and exit
  files copied back under `results/remote/`.

## Upstream provenance

- Paper: arXiv `2606.02429`, source downloaded June 6, 2026.
- Companion repository:
  `https://github.com/G4ll/NoteOnGenus2Covers`.
- Inspected upstream commit:
  `d7f91b16b325e7832b3647c514e6cbbfb949f0d6`.

## Resume protocol

1. Read `PLAN.md` and the latest `JOURNAL.md` entry.
2. Regenerate dashboard state with `python3 scripts/update-dashboard.py`.
3. Check `git status`.
4. Check `research/data/remote_jobs.json` and refresh live telemetry.
5. Continue the current bounded task; update the ledger before claiming
   progress.

## Completed article verification

- Claims C001-C040 are frozen and terminal.
- Final outcome: 36 verified, 4 disproved, 0 unresolved.
- The disproved claims are C027-C030, all in the degree-5 example.
- `scripts/audit-claims.py` writes the acceptance certificate
  `results/claim_audit.json`.
- The corrected degree-5 quartic has a nonsingular point over
  `Q(z), z^2+z-5=0`; no further extension is required.
- Corrected remote Magma artifact:
  `computations/magma/verify_degree5_over_base_field.m`.
- Complementary degree-5 invariant:
  `j(E')=-250888806400/56807829`.
- The exceptional quartic values arise from the torsion classification of
  `P=(-2p,2q)` on `V^2=U^3+2pU^2+4q^2`.

## Beyond-paper protocol

- New research uses IDs B001 onward in
  `research/data/beyond_paper.json`.
- Do not modify C-series outcomes to represent new work.
- Separate primitive maps from maps obtained by composing with elliptic
  isogenies.
- Degree-5 generic normalization:
  `y^2=L*m^2+M*m+N`, where
  `L=a^4+2*a^3+2*a^2*b+a^2+b^2`,
  `M=2*b*(a+b)*(a^2+b)`, and `N=b^3*(2*a+b)`.
- The initial exact degree-5 census has ten rows: zero conics split over `Q`,
  all ten split over the branch quadratic field.
- B008 is complete: both primitive degree-7 maps are recovered over `Q`.
  Sage verifies their exact function-field and differential identities, and
  remote Magma independently returns degree `7` for each morphism.
- The first pullback differential is `(49/12) dx/y`; its absent numerator
  `x^6` term gives the trace-zero complementary eigenform `x dx/y`.
- The second pullback differential is `(-49/60) x dx/y`. Its positive point
  at infinity maps to `-7*(29,-590)` on the second elliptic factor, and its
  pole denominator is the first cubic times
  `(x^2-115*x/24+7475/24)^2`.
- B013 gives exact degree-20 and degree-80 maps by elliptic multiplication,
  but they are nonprimitive.
- B010 now has a degree-independent exact SageMath recovery library:
  `computations/sage/lib/elliptic_cover_recovery.sage`. It supports finite or
  infinite source centers, finite or identity target centers, quintic or
  sextic genus-2 models, general Weierstrass coefficients, and exact number
  fields. Certified regression cases have degrees 3, 5, and 7.
- The recovery library still requires the target elliptic curve and
  eigenform, but no longer requires the differential scale or image of the
  source expansion point. `discover_elliptic_cover` solves the scale
  symbolically and searches a bounded Mordell-Weil box over `Q`.
- For degree 7, automatic discovery gives `scale^2-2401/144` at the origin
  and finds `-7*G=(10465/4,-51175/8)` with `scale+49/60` after four center
  attempts.
- Given candidate Hilbert-modular `j`-invariants,
  `elliptic_factor_discovery.sage` now discovers rational target twists by
  Frobenius filtering and eigenform lines by bounded projective search.
- For degree 7, 64 discriminant-supported twist classes and 17 split good
  Frobenius polynomials uniquely recover twists `-115`, `5`; exact recovery
  then selects eigenforms `[1:0]`, `[0:1]`.
- B010's remaining fully general input is candidate `j`-invariant extraction
  from an arbitrary source. For Kumar families this belongs to B009.
- B009 is complete. `kumar_square_discriminant_families.sage` imports the
  exact surfaces, Igusa-Clebsch tuples, symmetric elliptic `j`-functions, and
  tautological sextics for degrees 6 through 11. The degree-11 formula needs
  the iterative arithmetic evaluator rather than `sage_eval`.
- `sage_kumar_tautological_curves.json` certifies one nonsingular genus-2
  specialization in every imported degree.
- Current active frontier: B002 generic degree 5, B007 arbitrary given-map
  engine, B010 automated recovery, and the first primitive degree-6 pair.
