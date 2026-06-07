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

### Degree-2 and invariant identities

- Added `computations/sage/verify_degree2_j_twists.sage`.
- Verified both generic degree-2 maps from
  `y^2=x^6+a*x^4+b*x^2+1` and their two target elliptic equations.
- Derived the critical and complementary `j` formulas symbolically for the
  affine-normalized generic quartic `g=x^4+p*x^2+q*x` over `Q(p,q)`.
- Tested the formulas at three exact specializations, including
  `(p,q)=(-8,16)` from the degree-4 example.
- Verified that the explicit degree-3 maps produce nonconstant `Q(t)`-points
  on both quadratic twists by the source sextic.

## 2026-06-07

### Jupyter Book formula-rendering audit

- Added `scripts/sanitize-article-markdown.py` to normalize Pandoc's article
  conversion before it enters the Jupyter Book.
- Converted nested `equation`, `align`, and `eqnarray` environments into
  standalone MathJax display blocks with 19 stable numbered anchors.
- Repaired Pandoc equation and theorem references, normalized MyST targets,
  removed leaked reference metadata and TeX comments, and flattened the one
  `cases` block that conflicts with MyST's automatic `split` wrapper.
- Replaced the unsupported `tikzcd` diagram with equivalent geometric-cover
  and subgroup-inclusion tables containing rendered inline mathematics.
- A clean `./scripts/build-book.sh` run completed without Sphinx warnings.
- Browser verification of the article page found 779 MathJax containers,
  including 50 display blocks, zero `mjx-merror` nodes, zero raw TeX
  fragments, working sampled anchors, and zero horizontal overflow.

### General algorithm and omitted obligations

- Added universal SageMath certificates for the D4 symmetric-square
  invariants, trace rewriting, the complementary equations, squarefree
  normalization, and degree-3 linearity.
- Reconstructed the degree-3 complementary map from exactly seven samples.
- Added C035-C040 after the second line-by-line audit.
- Ran the full divisor-class worksheet remotely; all degree assertions and
  Riemann-Roch evaluations passed.

### Degree-5 discrepancy audit

- Found four incorrect coefficients in the displayed quartic.
- Proved that the printed quartic is smooth of genus 3, while the corrected
  quartic has three ordinary nodes and geometric genus zero.
- Found an exact nonsingular point over `Q(z)`, disproving the claimed
  obstruction.
- Parametrized over `Q(z)` itself in Magma and obtained
  `j(E')=-250888806400/56807829`.
- Recorded the mismatch between the cited 2001 Shaska paper and the later
  source of the two-parameter normal form.

### Quartic structural completion

- Remote Magma certified the `S4` subgroup tower and maximality used for
  primitivity.
- Derived the universal point `P=(-2p,2q)` on the complementary elliptic
  model.
- Factored every division polynomial permitted by Mazur's theorem and
  recovered exactly `0`, `-27648/11`, and `55296/5`.

### Final article audit

- Closed all claims C001-C040: 36 verified, 4 disproved, 0 unresolved.
- Added `scripts/audit-claims.py`; it checks 45 linked artifacts and every
  source-line range.
- Added final-status and beyond-paper chapters to the Jupyter Book.
- Started B002, the generic degree-5 base-field parametrization locus.

### High-degree program

- Audited the primary degree-5, Hilbert modular surface, and geometric
  complement sources: arXiv:1209.0443, arXiv:1412.2849, and
  arXiv:2412.07414.
- Derived the generic degree-5 branch quadratic and proved that the symmetric
  off-diagonal self-fiber is a plane quartic with three ordinary nodes.
- Projected from a node and obtained the normalization conic
  `y^2=L*m^2+M*m+N` over `Q(a,b)`, with a fully factored discriminant.
- Constructed ten exact primitive degree-5 covers. Their normalization conics
  are all obstructed over `Q` and soluble over the branch quadratic field.
- Added a rational degree-7 Kumar specialization. Exact Frobenius polynomial
  factorization against two rational elliptic curves passed at all 41 good
  primes from 11 through 199.
- Composed the degree-5 cover with `[2]` and `[4]` on its elliptic target and
  certified exact degree-20 and degree-80 maps. These are explicitly recorded
  as nonprimitive.
- Expanded the B-series to fourteen workstreams covering map recovery,
  Galois closures, finite-field/CRT lifting, Kumar families through degree 11,
  and Frey-Kani anti-isometry synthesis.

### Primitive degree-7 maps

- Recovered the first Kumar map by formal integration at infinity. Its
  pullback differential is `(49/12) dx/y`, and its denominator is the second
  cubic factor of the source sextic.
- Used the absent `x^6` coefficient in the first map numerator to prove
  `Tr(x)=0`, identifying the complementary eigenform as `x dx/y`.
- Corrected the recovery ansatz for the complementary map: the two points at
  infinity map to finite opposite elliptic points, so the rational
  `X`-coordinate has degree pattern `(7,7)`, not `(7,5)`.
- Located the positive infinity image at `-7*(29,-590)` on the second
  elliptic factor and recovered differential scale `-49/60`.
- SageMath verified both exact target identities, differential pullbacks, pole
  divisors, and rational-function degrees.
- Remote Magma constructed both morphisms and independently returned degree
  `7` for each. B008 is complete; B010 now contains a concrete finite-point
  formal-integration and Pade-reconstruction benchmark.

### Degree-independent formal recovery

- Replaced the fixed degree-7 Padé routine with the reusable library
  `computations/sage/lib/elliptic_cover_recovery.sage`.
- The API accepts a quintic or sextic genus-2 model, an elliptic target, an
  eigenform, differential scale, source center, target center, and cover
  degree.
- Rational reconstruction now solves the homogeneous local equation
  `A(x(t))-X(t)B(x(t))=O(t^N)` and infers degree bounds from valuations at
  infinity.
- Every reconstructed candidate is rejected unless the exact completed-square
  elliptic identity vanishes over the source function field.
- Regression tests recover maps of degrees `3`, `5`, and `7`; they include a
  finite source point, finite target centers, an odd-degree source model, a
  non-short elliptic target, and a quadratic number field.
- B010 progress increased to 60%. Automatic target, eigenform, and scale
  discovery remain separate inputs to implement.

### Automatic scale and center discovery

- Added `discover_elliptic_cover` to the general SageMath library.
- For each candidate center, reconstruction runs over `k(scale)`. The
  coefficientwise gcd of the exact identity residual yields the scale
  polynomial.
- The first degree-7 map gives `scale^2-2401/144`; the positive
  normalization recovers `49/12`.
- A bounded Mordell-Weil search tests four centers for the complementary
  degree-7 map and discovers `-7*G=(10465/4,-51175/8)` with
  `scale+49/60`.
- The finite degree-3 regression discovers `(5,19)` after two center attempts
  and derives `scale+1/5`.
- Every nonzero scale root is rerun through the exact characteristic-zero
  verifier. The search bound and attempted centers remain in the returned
  certificate.
- B010 progress increased to 75%. Target-curve and eigenform discovery are
  the remaining conceptual inputs.

### Target twist and eigenform discovery

- Added `computations/sage/lib/elliptic_factor_discovery.sage`.
- Starting from the source discriminant support
  `{2,3,5,7,23}`, the target search enumerates 64 signed squarefree twist
  classes for each candidate `j`-invariant.
- Seventeen split good Frobenius polynomials below 80 uniquely select twist
  `-115` for `j1` and twist `5` for `j2`.
- A bounded projective search in `(r+s*x) dx/y` finds eigenform lines
  `[1:0]` and `[0:1]`.
- The degree-7 recovery benchmark now starts only from the source sextic, the
  two Hilbert-modular `j`-invariants, and degree `7`; target models,
  eigenforms, centers, scales, and maps are discovered.
- All discovery evidence is followed by exact characteristic-zero map
  identities, so the finite-prime and height bounds are search aids rather
  than proof claims.
- B010 progress increased to 90%. The remaining general input is extraction
  of candidate `j`-invariants from an arbitrary source; Kumar-family values
  will come from B009.

### Kumar families in degrees 6 through 11

- Vendored Kumar's 18 auxiliary files for discriminants
  `36,49,64,81,100,121`.
- Added `kumar_square_discriminant_families.sage`, which parses each Hilbert
  modular double cover, Igusa-Clebsch tuple, symmetric `j`-functions, and
  tautological genus-2 sextic.
- Verified at exact rational sample points that the discriminant of the
  `j`-polynomial differs from the surface branch polynomial by a square in
  all six degrees.
- Constructed one squarefree genus-2 sextic in every degree 6 through 11.
  The degree-11 3.1 MB coefficient source is evaluated by an iterative
  arithmetic parser to avoid Python compiler depth limits.
- The imported degree-7 specialization reproduces both rational
  `j`-invariants and Frobenius discovery retains twists `-115` and `5`.
- B009 is complete. The next high-degree target is a rational degree-6
  specialization with both primitive maps and an exceptional-monodromy
  certificate.

### Primitive degree-6 maps and the first CRT backend

- Located the rational point `(r,s,z)=(-9,9/2,39366)` on `Y_-(36)`.
  Its elliptic invariants are `-972` and `1296`, and the normalized source is
  `y^2=x^6-6*x^5+7*x^4+28*x^3/9-16*x^2/3-16*x/9+16/81`.
- Frobenius filtering uniquely selected twist `-1` for both targets:
  `y^2=x^3-27*x+90` and `y^2=x^3+81*x-162`.
- Diagonal Hasse-Witt matrices identified the eigenform lines as
  `x dx/y` and `dx/y`.
- Recovered the first map with scale `-1` using the original rational
  `X(x)` backend.
- Extended `elliptic_cover_recovery.sage` to reconstruct general
  `X=A(x)+yB(x)`, derive `Y=C(x)+yD(x)` from the differential, and certify
  the completed-square elliptic identity in the quadratic function field.
- The complementary map has scale `2/3`. Its scale square `4/9` was
  reconstructed by CRT from exact residues modulo `101` and `103`; the
  characteristic-zero `X`-coordinate has degree `12`, hence cover degree
  `6`.
- Both targets have no rational prime-degree isogenies of degree `2` or `3`,
  proving that the degree-6 maps are primitive over `Q`.
- Remote Magma independently constructed both morphisms and returned degree
  `6` for each. B012 is now active with a working scale-lifting backend.
- For the first quotient, the generic fiber polynomial
  `N(x)-T*D(x)` has discriminant
  `2^43/3^6*(25*T+159)*(T^3-27*T+90)^2`.
- Magma computed its exact transitive Galois group as `S6` (group `6T16`,
  order `720`).
- The elliptic base adjoins `sqrt(T^3-27*T+90)`, which is a different square
  class from `sqrt(2*(25*T+159))`, the unique quadratic subfield of the
  `S6` splitting field. Therefore base change does not lower the group:
  the degree-6 elliptic cover also has `S6` monodromy and is not the
  exceptional `PGL(2,5)` case.

### Primitive degree-8 maps and maximal monodromy

- Located the rational point `(r,s,z)=(4,-2,-1280)` on `Y_-(64)` and
  normalized its source to
  `y^2=x^6+8*x^4+20*x^3+68*x^2+240*x+396`.
- Frobenius filtering selected the targets
  `y^2=x^3-x^2-5833*x+207037` and
  `y^2=x^3-x^2+7*x-3`, with
  `j=-8780800/2187` and `j=5120/3`.
- Hasse-Witt eigenvectors at six good primes identified `dx/y` and
  `(1+2*x) dx/y`.
- Recovered the compact map in `Q(x)` with scale `2`.
- Recovered the complementary map as `X=A(x)+yB(x)` with degree `16` as a
  function on the source, hence elliptic cover degree `8`.
- Reconstructed the complementary scale square `4` from exact roots `+/-2`
  modulo `61`; exact characteristic-zero verification accepts the early
  rational reconstruction.
- Remote Magma independently constructed both morphisms, returned degree `8`
  for each, and computed the rational source automorphism group order as
  `2`.
- The automorphism result closes the multiplication-by-2 gap in the
  primitivity argument: neither target has a rational `2`-isogeny and the
  source has no rational degree-2 elliptic quotient.
- Magma computed the compact fiber group as `S8` of order `40320`. Its
  discriminant square class is
  `-5*(T^3-T^2-5833*T+207037)`, distinct from the elliptic-base square class,
  so the cover remains `S8` after base change.
- B015 is complete. B004, B011, and B012 now include degree-8 evidence.

### Primitive degree-9 maps, modular centers, and maximal monodromy

- Located the rational point `(r,s,z)=(3,-7,-29280)` on `Y_-(81)` and
  normalized the tautological source to
  `y^2=x^6-9038618392*x^4-64880615814700*x^3
  +23434251437448181208*x^2+276514602725620514127600*x
  -12176183106883876734347363424`.
- Frobenius filtering over 512 discriminant-supported twist classes uniquely
  selected twists `-359687` and `-21940907`.
- Hasse-Witt eigenvectors identified `(231434+9*x) dx/y` and `dx/y`.
  Modular map searches reconstructed differential scales `1` and `-24806`.
- Added `discover_center_by_crt`, including resumable partial CRT state.
  Exact finite-field center searches lifted the two images of infinity from
  128-bit and 184-bit moduli:
  `(1162836225963/5041,-1224177442475117122/357911)` and
  `(14623882010512642188/314743081,
  -528607451220336034930422397/5583857000021)`.
- `recover_degree9_maps.sage` rebuilt both centers from modular certificates,
  recovered both rational `X(x)` maps, verified the completed-square target
  identities, and returned degree `9`.
- Remote Magma independently constructed both morphisms and returned degree
  `9`. Neither target has a rational `3`-isogeny, proving primitivity.
- For the first quotient, factorization patterns `(1,3,5)` and `(2,7)` in
  the irreducible `X=0` fiber force `S9`. The generic discriminant square
  class is
  `359687*(1842229401671*T+98280453222687553920)`, which is squarefree and
  coprime to the cubic elliptic branch polynomial. The elliptic cover
  therefore retains `S9`.
- B016 is complete. B004, B010, B011, and B012 now include degree-9 evidence.

### Complete coefficient-vector CRT lifting

- Added `discover_coefficients_by_crt` to the general SageMath recovery
  library.
- The backend supports both rational `X=A(x)/D(x)` coordinates and general
  `X=A(x)/D(x)+y*B(x)/D(x)` coordinates.
- Modular maps are represented by padded projective coefficient vectors and
  normalized at a common nonzero pivot before entrywise CRT.
- Bad reductions and vanishing pivots are recorded as per-prime failures.
  Partial states retain the modulus, coefficient residues, pivot, and modular
  certificates and can be resumed without repeating earlier work.
- Rational reconstruction is never accepted heuristically: the complete map
  identity and exact cover degree must certify over `QQ`.
- The degree-6 quotient reconstructs after a 27-bit modulus. Its full
  quadratic-function complement reconstructs after a 34-bit modulus. Both
  agree exactly with direct characteristic-zero recovery.
- B012 is complete.

### Primitive degree-10 and degree-11 map pairs

- Located rational Hilbert modular points
  `(r,s,z)=(-4/5,1/5,18/125)` on `Y_-(100)` and
  `(r,s,z)=(3/2,1/2,3/8)` on `Y_-(121)`.
- Frobenius filtering uniquely selected both rational target twists in each
  degree, and Hasse-Witt eigenspaces identified the two pullback differential
  lines.
- Extended `discover_general_scale_by_crt` with bad-prime skipping and
  resumable partial CRT state. The degree-10 scales required 133-bit and
  276-bit moduli; the degree-11 scales required 127-bit and 238-bit moduli.
- Recovered all four maps in the full quadratic function fields
  `Q(x,y)`, verified the exact elliptic identities, and computed cover
  degrees `10,10,11,11`.
- The degree-10 targets have no rational 2- or 5-isogenies, proving both
  maps primitive over `Q`. Degree 11 is prime, so both degree-11 maps are
  primitive.
- Generated static Magma artifacts from the exact Sage coefficients. Remote
  Magma V2.28-3 independently returned degrees `10,10` in 7.240 seconds and
  degrees `11,11` in 10.359 seconds, with 32.09 MB memory in each run.
- B004, B010, and the new benchmark workstream B017 are complete. The next
  bounded task is explicit splitting-kernel certification in degrees 6 and 8.

### Explicit degree-6 and degree-8 splitting kernels

- Added a reusable Magma helper that obtains full rational `n`-torsion bases
  over finite fields, pulls point divisors through curve maps, converts them
  to genus-2 Jacobian classes, solves the graph relation, enumerates the full
  kernel, and checks the Weil pairing.
- For degree 6, good reduction over `F_(29^2)` gives target group invariants
  `[6,144]` on both sides. In the computed bases, the kernel is the graph of
  `[[1,4],[0,1]]` modulo `6`.
- Exactly `36=6^2` pairs lie in the kernel. The two Weil pairings are
  `a^700` and `a^140` in a field whose multiplicative group has order `840`,
  so their product is `1`.
- For degree 8, good reduction over `F_(79^2)` gives target group invariants
  `[8,792]` on both sides. The graph matrix is
  `[[4,7],[3,4]]` modulo `8`, with unit determinant `3`.
- Exactly `64=8^2` pairs lie in the kernel. The pairing exponents
  `2340+3900=6240` sum to the multiplicative group order, again proving that
  the graph is anti-isometric.
- The reduction characteristics do not divide `n`, so these are finite etale
  good-reduction models of the characteristic-zero splitting kernels.
  B018 is complete.

### Full Galois-closure complementary quotient

- Audited Gallese's fixed-field construction rather than treating the
  rational generic-fiber Galois group as the quotient itself.
- Implemented invariant generators
  `s=t1+t2`, `p=t1*t2`, and `q=w*(t1-t2)` for the involution
  `(t1,t2,w)->(t2,t1,-w)`.
- `galois_complement.sage` computes the exact remainder of
  `N(T)-z*D(T)` modulo `T^2-s*T+p`; its two coefficients together with
  `q^2=f(z)*(s^2-4*p)` define the complementary fixed field in arbitrary
  degree.
- The generic critical quartic reduces to
  `s^3-2*s*p+a*s+b=0` and the known genus-one quartic
  `Y^2=-s^4-2*a*s^2-2*b*s`, with
  `j=-1024*a^6/(b^2*(8*a^3+27*b^2))`.
- Added a Magma model of `G=S_n x C2`,
  `H_Z=S_(n-2) x {1}`, and
  `H_W=<H_Z,((12),-1)>`. Exact orders and indices certify the
  off-diagonal and quotient degrees for every `n=4,...,11`.
- The twisted ordered-pair coset action gives genus one for generic odd
  degrees `5,7,9,11,13,15`. It also gives genus one for the exact
  degree-6, degree-7, and degree-8 branch signatures.
- In the critical quartic, the sign-graph `S4` intersects `H_W` in an
  order-2 subgroup of index `12`, recovering the transposition fixed field
  used in the paper.
- Remote Magma computed `S7` for the compact degree-7 quotient. Its fiber
  discriminant is
  `(828157741498368/117649)*target_cubic^3`, with square class
  `2*target_cubic`; adjoining `sqrt(target_cubic)` therefore preserves
  `S7`.
- Remote runtimes were `0.050` seconds for the subgroup/genus certificate
  and `0.290` seconds for the degree-7 Galois group, both at `32.09 MB`.
  B011 is complete.

### Generic degree-5 branch-field splitting and complement

- Identified the diagonal critical pair `(c,c)` as a rational point on the
  divided self-fiber. Projection from the node over zero gives the universal
  normalization-conic point
  `m=((a+2*b)c-2*b(2*a+b))/(2*a^2+3*a+4*b)` and the corresponding explicit
  `y`.
- SageMath reduces the conic identity and the diagonal self-fiber identity
  exactly modulo the fourth-critical-point quadratic. Remote Magma repeats
  the conic substitution over `Q(a)(b,c)` in `0.020` seconds.
- Implemented the complete orientation quotient from the four square classes
  `z`, `z-1`, `z-e`, and `s^2-4*p`. Pairwise gcd cancellation produces a
  squarefree quartic; its binary-quartic invariant gives
  `j'=256*I^3/discriminant`.
- The article specialization `(a,b)=(7,1)` returns
  `j'=-250888806400/56807829`, independently matching the prior Magma
  reconstruction.
- The generic invariant lies in `Q(a,b,c)` and is usually quadratic over
  `Q(a,b)`. At `(a,b)=(1,2)`, the exact minimal polynomial has degree two.
- Upgraded the ten-row degree-5 census: every row now contains the canonical
  conic point, complementary branch quartic, `j'`, and its minimal
  polynomial. Four of the ten displayed rows have quadratic `j'`.
- B002 and B003 are complete. The next bounded task is Frey-Kani
  anti-isometry synthesis beyond degree 11.

### Initial degree-13 Frey-Kani synthesis

- Selected `F_8009`, where both elliptic curves have full rational
  `13`-torsion:
  `E1: y^2=x^3+5553*x+5419` and
  `E2: y^2=x^3+2531*x+1402`.
- Their group invariants are `[13,611]` and `[13,624]`. Explicit torsion
  bases are stored in the SageMath and Magma certificates.
- In the chosen bases, inverse Weil pairings require determinant `3`.
  The matrix `diag(1,3)` defines an anti-isometry, and exactly
  `13*(13^2-1)=2184` matrices have the same required determinant.
- The graph contains exactly `13^2=169` points and is maximally isotropic.
  SageMath records pairings `1420` and `6379`, whose product is one.
- The Frobenius traces are `67` and `-102`. Their discriminants have
  squareclasses `-163` and `-2`, so the ordinary geometric endomorphism
  fields differ. The curves are geometrically nonisogenous, which gives the
  strong Frey-Kani irreducibility criterion.
- Therefore the quotient principal polarization is geometrically the
  Jacobian of a smooth genus-2 curve. Its Weil polynomial is
  `T^4+35*T^3+9184*T^2+280315*T+64144081`.
- Local SageMath verification took under `0.4` seconds. Independent remote
  Magma verification took `0.080` seconds and `32.09 MB`.
- This completes the initial B014 synthesis milestone. B014 remains in
  progress because an explicit genus-2 model and the two degree-13 maps have
  not yet been reconstructed.

### Explicit degree-13 quotient curve

- Added a pinned external dependency installer for the GPL-3.0 Sage branch of
  AVIsogenies at commit
  `e488a54304a5b5bcd0ae8c58d0ab82aeb02d6746`.
- Derived and checked level-2 elliptic Kummer coordinates from Legendre
  coordinates. Scalar multiplication and normal addition agree with the
  original elliptic group law on both certified `13`-torsion bases.
- Implemented the decomposable product theta null and the graph basis
  `(P1,Q1)`, `(P2,3Q2)`. The only normal sum needed by the generic isogeny
  initializer is supplied componentwise; all remaining kernel arithmetic is
  performed by AVIsogenies differential addition.
- Computed the quotient theta null over `F_(8009^12)` and a Rosenhain model.
  Its Igusa-Clebsch invariants are `(2419,7563,6738,5346)`, and its absolute
  invariants `(4139,7829,4340)` are fixed by `8009`-Frobenius.
- Magma's Mestre reconstruction and twist test produced a base-field model.
  The fixed committed representative is
  `y^2=6042*x^6+4620*x^5+6357*x^4+3661*x^3+4018*x^2+5767*x+84`.
- SageMath independently computed its Frobenius polynomial as
  `T^4+35*T^3+9184*T^2+280315*T+64144081`. Remote Magma independently
  verified the same moduli and L-polynomial in `0.636` seconds.
- B014 is now `75%`: anti-isometry, quotient polarization, theta quotient,
  descent, and explicit genus-2 model are certified. The remaining quarter
  is recovery of the two degree-13 maps.
