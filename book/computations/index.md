# Computation Collection

## SageMath

Local exact computations live under `computations/sage/`.

- [`verify_degree3_basic.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree3_basic.sage):
  cover identities, birational normalization, explicit complementary map,
  and denominator factorization.
- [`verify_degree3_elimination.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree3_elimination.sage):
  exact symmetric elimination, polynomial GCD, binary-quartic invariants, and
  four additional Kuhn-family samples.
- [`verify_degree4_example.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree4_example.sage):
  critical and fiber-product discriminants, explicit complement
  normalization, twist identification, arithmetic, and ramification
  invariant.
- [`verify_degree2_j_twists.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree2_j_twists.sage):
  generic degree-2 maps, symbolic critical-quartic `j` formulas, and
  quadratic-twist point identities.
- [`verify_general_symbolics.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_general_symbolics.sage):
  universal symmetric-square invariants and trace rewriting.
- [`verify_generic_quartic.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_generic_quartic.sage):
  generic critical-quartic source, map, self-fiber, and complementary
  invariant.
- [`lib/galois_complement.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/lib/galois_complement.sage):
  arbitrary-degree fixed-field equations for the off-diagonal
  Galois-closure quotient.
- [`verify_galois_complement.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_galois_complement.sage):
  exact invariant construction, generic critical-quartic recovery, and
  degree-6, degree-7, and degree-8 quotient-equation benchmarks.
- [`verify_structural_claims.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_structural_claims.sage):
  squarefree normalization, universal degree-3 linearity, dominance, and
  twist non-torsion.
- [`verify_complementary_interpolation.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_complementary_interpolation.sage):
  exact seven-sample reconstruction of the degree-3 complementary map.
- [`verify_degree5_basic.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree5_basic.sage):
  degree-5 reconstruction and exact certificates for the four printed
  discrepancies.
- [`verify_exceptional_ramification.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_exceptional_ramification.sage):
  universal point and full torsion classification yielding the exceptional
  ramification invariants.
- [`elliptic_cover_recovery.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/lib/elliptic_cover_recovery.sage):
  degree-independent formal integration, target translation, rational
  and full quadratic-function reconstruction, symbolic and CRT scale solving,
  bounded Mordell-Weil search, resumable CRT center and complete coefficient
  lifting, and exact map certification.
- [`test_crt_coefficient_lifting.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/test_crt_coefficient_lifting.sage):
  projective coefficient-vector CRT for rational and full
  quadratic-function degree-6 maps, including resumable partial states and
  characteristic-zero certification.
- [`elliptic_factor_discovery.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/lib/elliptic_factor_discovery.sage):
  Frobenius-compatible target-twist discovery and bounded eigenform-line
  search from candidate Hilbert-modular `j`-invariants.
- [`kumar_square_discriminant_families.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/lib/kumar_square_discriminant_families.sage):
  exact degree-6 through degree-11 Hilbert modular surfaces, Igusa-Clebsch
  invariants, elliptic `j`-polynomials, and tautological curves.
- [`verify_kumar_family_importer.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_kumar_family_importer.sage):
  all-degree parser audit, double-cover discriminant checks, and imported
  degree-7 target discovery.
- [`verify_kumar_all_tautological_curves.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_kumar_all_tautological_curves.sage):
  one exact nonsingular genus-2 specialization in each degree 6 through 11.
- [`test_general_elliptic_cover_recovery.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/test_general_elliptic_cover_recovery.sage):
  exact regression cases in degrees 3, 5, and 7 over rational and quadratic
  number fields.
- [`recover_degree6_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree6_maps.sage):
  rational `Y_-(36)` specialization, target-twist and Hasse-Witt eigenform
  discovery, one rational `X(x)` map, one full `A(x)+yB(x)` map, CRT scale
  lifting, exact degree, and primitivity.
- [`recover_degree7_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree7_maps.sage):
  application of the general library to both primitive degree-7
  `X`-coordinates.
- [`recover_degree8_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree8_maps.sage):
  rational `Y_-(64)` specialization, target-twist and Hasse-Witt eigenform
  discovery, compact and full-function-field map recovery, CRT scale
  reconstruction, exact degrees, and primitivity inputs.
- [`recover_degree9_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree9_maps.sage):
  rational `Y_-(81)` specialization, twist and eigenform discovery,
  resumable finite-target-center reconstruction by CRT, both exact
  degree-9 maps, and primitivity.
- [`recover_degree10_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree10_maps.sage):
  rational `Y_-(100)` specialization, target and eigenform discovery,
  resumable scale reconstruction up to a 276-bit modulus, both exact
  full-function-field maps, and primitivity.
- [`recover_degree11_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree11_maps.sage):
  rational `Y_-(121)` specialization, target and eigenform discovery,
  resumable scale reconstruction up to a 238-bit modulus, and both exact
  primitive full-function-field maps.
- [`recover_degree13_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree13_maps.sage):
  dual-kernel Mumford recovery, exact sign-resolved theta evaluation on 34
  points, interpolation of both degree-13 maps on the Rosenhain quotient,
  elliptic function-field identities, and linear differential pullbacks
  over `F_(8009^24)`.
- [`descend_degree13_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/descend_degree13_maps.sage):
  unique branch-set Möbius transport, coefficientwise descent to `F_8009`,
  exact target identities, and Hasse-Witt eigendirection checks for both
  degree-13 maps.
- [`verify_degree17_anti_isometry.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree17_anti_isometry.sage):
  deterministic prime-field search and exact degree-17 Frey-Kani graph
  certificate over `F_8263`.
- [`reconstruct_degree17_theta.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/reconstruct_degree17_theta.sage):
  degree-17 theta quotient, invariant descent, and exact certification of a
  fixed genus-2 model over `F_8263`.
- [`lib/frey_kani_map_recovery.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/lib/frey_kani_map_recovery.sage):
  configuration-driven dual-kernel recovery, exact level-2 theta evaluation,
  rational interpolation, and full function-field certification.
- [`recover_degree17_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree17_maps.sage):
  degree-17 specialization with 42 deterministic interpolation samples.
- [`descend_degree17_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/descend_degree17_maps.sage):
  branch-set transport, 2-torsion cocycle resolution, coefficient descent,
  exact identities, and Hasse-Witt eigendirections over `F_8263`.
- [`verify_degree19_anti_isometry.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree19_anti_isometry.sage):
  deterministic degree-19 graph search and exact certificate over `F_11743`.
- [`reconstruct_degree19_theta.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/reconstruct_degree19_theta.sage):
  degree-19 theta quotient, invariant descent, and fixed base-field curve.
- [`recover_degree19_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/recover_degree19_maps.sage):
  degree-19 specialization with 46 deterministic interpolation samples.
- [`descend_degree19_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/descend_degree19_maps.sage):
  exact fixed-field transport and certification of both degree-19 maps.
- [`compare_prime_degree_scaling.py`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/compare_prime_degree_scaling.py):
  reproducible scaling table for complete degrees 13, 17, and 19.
- [`verify_degree23_anti_isometry.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree23_anti_isometry.sage):
  deterministic degree-23 graph certificate over `F_21943`.
- [`reconstruct_degree23_theta.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/reconstruct_degree23_theta.sage):
  degree-23 theta quotient and fixed base-field model.
- [`export_degree10_11_magma.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/export_degree10_11_magma.sage):
  deterministic export of the recovered exact coefficients to static Magma
  verification programs.
- [`verify_degree7_maps.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree7_maps.sage):
  exact target identities, differential pullbacks, pole divisors, infinity
  image, and primitivity for both Kumar maps.

## Magma

- [`verify_degree13_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree13_maps.m):
  independently constructs both descended morphisms over `F_8009`, verifies
  their equations and differential pullbacks, and computes degrees `13` and
  `13`.
- [`verify_degree17_anti_isometry.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree17_anti_isometry.m):
  independently verifies both full `17`-torsion bases, determinant `6`,
  the `289`-point graph, CM squareclasses, and quotient Weil polynomial.
- [`reconstruct_degree17_curve.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/reconstruct_degree17_curve.m):
  independently reconstructs the degree-17 quotient from its invariants,
  selects its twist by the L-polynomial, and checks the fixed sextic.
- [`verify_degree17_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree17_maps.m):
  independently constructs both descended morphisms and returns degrees
  `17` and `17`.
- [`verify_degree19_anti_isometry.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree19_anti_isometry.m):
  independently verifies the full degree-19 torsion graph.
- [`reconstruct_degree19_curve.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/reconstruct_degree19_curve.m):
  independently reconstructs and twist-selects the fixed degree-19 quotient.
- [`verify_degree19_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree19_maps.m):
  independently constructs both degree-19 morphisms.
- [`verify_degree23_anti_isometry.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree23_anti_isometry.m):
  independently verifies the degree-23 graph.
- [`reconstruct_degree23_curve.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/reconstruct_degree23_curve.m):
  independently reconstructs the fixed degree-23 quotient.

Remote computations live under `computations/magma/` and execute with Magma
V2.28-3 on `lts-faculty.wmi.amu.edu.pl`.

- [`lib/splitting_kernel.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/lib/splitting_kernel.m):
  reusable full-torsion pullback, graph-kernel enumeration, and Weil-pairing
  anti-isometry certificate.
- [`lib/galois_complement.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/lib/galois_complement.m):
  reusable `H_Z`, graph-subgroup `H_W`, twisted ordered-pair action, and
  Riemann--Hurwitz genus certificate.
- [`smoke_test.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/smoke_test.m):
  remote engine and exact-arithmetic smoke certificate.
- [`verify_degree3_map.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree3_map.m):
  direct construction of the displayed complementary map and degree
  computation.
- [`verify_degree4_complement.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree4_complement.m):
  independent genus-one and isomorphism check for the self-fiber-product
  cubic.
- [`verify_generic_quartic.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_generic_quartic.m):
  independent exact checks at three quartic specializations.
- [`verify_quartic_group_tower.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_quartic_group_tower.m):
  S4 Galois specialization and complete subgroup-index certificate.
- [`verify_degree5_over_base_field.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree5_over_base_field.m):
  corrected degree-5 parametrization over the original quadratic field and
  complementary `j`-invariant.
- [`verify_degree6_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree6_maps.m):
  independent construction of both degree-6 morphisms, including the
  complementary `A(x)+yB(x)` coordinate, and exact degree computations.
- [`verify_degree6_monodromy.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree6_monodromy.m):
  exact `S6` generic-fiber Galois group, discriminant square class, and
  elliptic-base disjointness certificate ruling out exceptional
  `PGL(2,5)` monodromy.
- [`verify_degree6_splitting_kernel.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree6_splitting_kernel.m):
  full 6-torsion pullback over `F_(29^2)`, explicit anti-isometry graph
  matrix, inverse Weil pairings, and all 36 kernel points.
- [`verify_degree7_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree7_maps.m):
  independent construction of both Kumar morphisms and exact degree-7
  computations.
- [`verify_degree7_monodromy.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree7_monodromy.m):
  exact `S7` generic-fiber group and quadratic-disjointness certificate over
  the elliptic base.
- [`verify_galois_complement.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_galois_complement.m):
  subgroup orders and indices through degree 11, critical-quartic fixed
  field, generic odd-degree genus-one signatures through degree 15, and
  exact degree-6/7/8 signatures.
- [`verify_degree8_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree8_maps.m):
  independent construction of both degree-8 morphisms, exact degree
  computations, and source automorphism-group certificate.
- [`verify_degree8_monodromy.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree8_monodromy.m):
  exact `S8` generic-fiber Galois group, discriminant square class, and
  elliptic-base disjointness certificate.
- [`verify_degree8_splitting_kernel.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree8_splitting_kernel.m):
  full 8-torsion pullback over `F_(79^2)`, explicit anti-isometry graph
  matrix, inverse Weil pairings, and all 64 kernel points.
- [`verify_degree9_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree9_maps.m):
  independent construction of both degree-9 morphisms and exact degree
  computations.
- [`verify_degree9_monodromy.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree9_monodromy.m):
  deterministic `S9` certificate from modular cycle types, exact generic
  discriminant square class, and elliptic-base disjointness.
- [`verify_degree10_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree10_maps.m):
  independent construction of both full-function-field degree-10 morphisms
  and exact degree computations.
- [`verify_degree11_maps.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree11_maps.m):
  independent construction of both full-function-field degree-11 morphisms
  and exact degree computations.

## Evidence

Committed certificates and remote transcripts live under `results/`.
Upstream author code under `sources/upstream/` is reference material and is
never sufficient by itself to mark a claim verified.

- [`sage_degree3_basic.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree3_basic.json)
- [`sage_degree3_elimination.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree3_elimination.json)
- [`magma_degree3_map.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree3_map.json)
- [`sage_degree4_example.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree4_example.json)
- [`magma_degree4_complement.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree4_complement.json)
- [`sage_degree2_j_twists.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree2_j_twists.json)
- [`magma_remote_smoke.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_remote_smoke.json)
- [`claim_audit.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/claim_audit.json)
- [`sage_degree5_basic.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree5_basic.json)
- [`sage_exceptional_ramification.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_exceptional_ramification.json)
- [`magma_degree5_over_base_field.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree5_over_base_field.json)
- [`magma_quartic_group_tower.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_quartic_group_tower.json)
- [`sage_degree6_recovery.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree6_recovery.json)
- [`magma_degree6_maps.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree6_maps.json)
- [`magma_degree6_monodromy.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree6_monodromy.json)
- [`sage_degree7_recovery.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree7_recovery.json)
- [`sage_general_map_recovery.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_general_map_recovery.json)
- [`sage_degree7_maps.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree7_maps.json)
- [`magma_degree7_maps.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree7_maps.json)
- [`magma_degree7_monodromy.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree7_monodromy.json)
- [`sage_galois_complement.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_galois_complement.json)
- [`magma_galois_complement.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_galois_complement.json)
- [`sage_degree8_recovery.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree8_recovery.json)
- [`magma_degree8_maps.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree8_maps.json)
- [`magma_degree8_monodromy.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree8_monodromy.json)
- [`sage_degree9_recovery.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree9_recovery.json)
- [`magma_degree9_maps.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree9_maps.json)
- [`magma_degree9_monodromy.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree9_monodromy.json)
- [`sage_kumar_family_importer.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_kumar_family_importer.json)
- [`sage_kumar_tautological_curves.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_kumar_tautological_curves.json)
