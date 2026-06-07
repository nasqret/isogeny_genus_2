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
- The primitive degree-6 benchmark is now complete at
  `(r,s,z)=(-9,9/2,39366)`. The normalized source has elliptic targets
  `j=-972,1296`, with eigenforms `x dx/y` and `dx/y`.
- Even-degree recovery cannot assume `X` lies in `Q(x)`. The complementary
  degree-6 map requires `X=A(x)+yB(x)`; its exact scale is `2/3` and its
  elliptic `X`-coordinate has degree `12`.
- `discover_general_scale_by_crt` finds the scale square modulo good primes
  and rationally reconstructs it. For the degree-6 complement, residues
  modulo `101` and `103` reconstruct `c^2=4/9`.
- Both degree-6 targets have no rational `2`- or `3`-isogenies, so the maps
  are primitive over `Q`. Remote Magma independently returns degree `6` for
  both morphisms.
- The first degree-6 quotient has exact monodromy `S6`, not exceptional
  `PGL(2,5)`. Its fiber discriminant square class is `2*(25*T+159)`, distinct
  from the elliptic-base square class `T^3-27*T+90`, so the quadratic base
  change preserves `S6`.
- B015 is complete at `(r,s,z)=(4,-2,-1280)` on `Y_-(64)`. The normalized
  source is
  `y^2=x^6+8*x^4+20*x^3+68*x^2+240*x+396`.
- Its targets have `j=-8780800/2187,5120/3`, and the pullback eigenforms are
  `dx/y` and `(1+2*x) dx/y`.
- Both degree-8 maps have scale `2`; the complementary map requires
  `X=A(x)+yB(x)` and has function degree `16`. CRT at prime `61`
  reconstructs `c^2=4`, and exact characteristic-zero verification accepts
  the early lift.
- Remote Magma returns degree `8` for both morphisms and source automorphism
  group order `2`. Together with the absence of rational target
  `2`-isogenies, this rules out all nontrivial degree-8 factorizations over
  `Q`.
- The compact degree-8 quotient has exact `S8` monodromy over the elliptic
  base. Its discriminant square class is
  `-5*(T^3-T^2-5833*T+207037)`.
- B016 is complete at `(r,s,z)=(3,-7,-29280)` on `Y_-(81)`. The normalized
  source has targets with
  `j=-121929728/4804839` and
  `j=598116032039544946688/43441281`.
- Frobenius filtering selects twists `-359687` and `-21940907`; the
  eigenforms are `(231434+9*x) dx/y` and `dx/y`, with scales `1` and
  `-24806`.
- `discover_center_by_crt` searches exact finite-field target points,
  combines unique centers by CRT, supports resumable partial state, and
  accepts a lift only after characteristic-zero map certification. The two
  degree-9 centers required 128-bit and 184-bit moduli.
- Remote Magma independently returns degree `9` for both maps. Neither target
  has a rational `3`-isogeny, so both maps are primitive over `Q`.
- The first degree-9 quotient has `S9` monodromy. Exact factorization patterns
  `(1,3,5)` and `(2,7)` force `S9`; its discriminant square class is
  `359687*(1842229401671*T+98280453222687553920)`, coprime to the cubic
  elliptic branch class, so base change preserves `S9`.
- `discover_coefficients_by_crt` completes coefficient-level CRT lifting. It
  supports rational and full quadratic-function X-coordinates, uses a common
  projective pivot, preserves resumable partial state, and requires exact
  characteristic-zero identity and degree certification. The degree-6
  regression is stored in `results/sage_crt_coefficient_lifting.json`.
- B017 gives complete rational degree-10 and degree-11 benchmarks. The
  degree-10 point is `(-4/5,1/5,18/125)` on `Y_-(100)` and the degree-11
  point is `(3/2,1/2,3/8)` on `Y_-(121)`. All four maps use full
  quadratic-function `X`-coordinates and have independent remote Magma
  degree certificates.
- `discover_general_scale_by_crt` now skips bad or noncertifying primes,
  records failures, and preserves resumable CRT state. Its largest completed
  reconstruction is the 276-bit modulus for the second degree-10 map.
- B018 explicitly certifies splitting kernels at good reduction. For degree
  6 over `F_(29^2)`, the anti-isometry graph matrix is
  `[[1,4],[0,1]] mod 6` and the kernel has `36` points. For degree 8 over
  `F_(79^2)`, the matrix is `[[4,7],[3,4]] mod 8` and the kernel has `64`
  points. Inverse Weil pairings certify maximal isotropy.
- B011 is complete. The general fixed-field quotient uses
  `s=t1+t2`, `p=t1*t2`, and `q=w*(t1-t2)`, with the remainder equations of
  `N(T)-zD(T)` modulo `T^2-sT+p` and
  `q^2=f(z)*(s^2-4p)`. Magma certifies
  `H_Z=S_(n-2)x{1}` and `H_W=<H_Z,((12),-1)>`, genus one through generic
  odd degree `15`, and the exact degree-6/7/8 signatures.
- The compact degree-7 quotient has `S7` monodromy after elliptic base
  change; its discriminant square class is `2*target_cubic`.
- B002 is complete. The diagonal critical pair `(c,c)` gives a universal
  point on the degree-5 normalization conic over `Q(a,b,c)`, with denominator
  `2*a^2+3*a+4*b`. This proves generic branch-field splitting.
- B003 is complete in compact form. Reduce the four orientation divisors
  `z`, `z-1`, `z-e`, and `s^2-4*p` independently modulo squares, combine
  them to a squarefree quartic, and use
  `j'=256*I^3/discriminant`. The invariant generally has degree two over
  `Q(a,b)`.
- B014 has an initial degree-13 synthesis certificate over `F_8009`.
  The curves with `j=81` and `j=3213` have full rational `13`-torsion; in
  the stored bases, `diag(1,3)` is an anti-isometry graph with `169` points.
  The CM squareclasses `-163` and `-2` prove geometric nonisogeny and hence
  Frey-Kani irreducibility. The quotient is geometrically a smooth genus-2
  Jacobian with Weil polynomial
  `T^4+35*T^3+9184*T^2+280315*T+64144081`.
- The B014 theta quotient is now explicit. The pinned AVIsogenies Sage
  dependency is installed by `scripts/setup-avisogenies-sage.sh`; its commit
  is `e488a54304a5b5bcd0ae8c58d0ab82aeb02d6746`.
- The quotient theta null over `F_(8009^12)` has Igusa-Clebsch invariants
  `(2419,7563,6738,5346)` and absolute invariants `(4139,7829,4340)`.
  A fixed base-field model is
  `y^2=6042*x^6+4620*x^5+6357*x^4+3661*x^3+4018*x^2+5767*x+84`.
- The two primitive degree-13 maps are now reconstructed and exactly
  certified on the Rosenhain quotient over `F_(8009^24)`. Both elliptic
  X-coordinates have numerator/denominator degrees `(13,12)`, the elliptic
  equations hold identically, and both invariant differentials pull back
  to linear forms. The full formulas are in
  `results/sage_degree13_maps.json`.
- B014 is complete. A unique branch-set Möbius class transports the
  Rosenhain quotient to the fixed `F_8009` sextic. Both descended
  X-coordinates have degree pair `(13,13)`, their coefficients lie in
  `F_8009`, and their normalized differential directions are
  `[1,3779]` and `[1,7873]`.
- Remote Magma independently constructs both descended morphisms and returns
  degrees `13` and `13`, target j-invariants `81` and `3213`, in `0.160`
  seconds and `32.09 MB`.
- Current active frontier: parameterize the prime-degree Frey-Kani search and
  run it in degrees 17 and 19.
- The prime-degree search is now deterministic: admissible traces are
  filtered arithmetically, quadratic twists use a fixed primitive element,
  and torsion bases come from a lexicographic point scan plus primitive Weil
  pairing.
- B019 has a certified degree-17 graph over `F_8263`. The curves
  `y^2=x^3+1728` and `y^2=x^3+6442*x+3171` have traces `172,-117`,
  CM squareclasses `-3,-67`, and anti-isometry matrix `diag(1,6)`.
- The graph has `289` points and quotient Weil polynomial
  `T^4-55*T^3-3598*T^2-454465*T+68277169`. SageMath and remote Magma agree.
