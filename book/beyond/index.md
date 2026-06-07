# Beyond the Paper

The article ledger C001-C040 is frozen. New mathematics is tracked in the
B-series, with a separate standard: a workstream may be exploratory, but every
claimed example must still have exact executable evidence.

## New target

The project is no longer limited to computing one complementary elliptic
factor from one map. The target is a practical theory and implementation for

1. accepting an arbitrary genus-2 to elliptic map and constructing its
   complement;
2. recovering primitive maps when only a split Jacobian or a moduli point is
   known;
3. handling degrees $5$ through $11$ with exact family data; and
4. scaling beyond degree $11$ by modular computation rather than enormous
   characteristic-zero formulas.

The distinction between **primitive** and **nonprimitive** maps is mandatory.
Composing a primitive degree-$n$ map with an elliptic isogeny produces valid
high-degree examples, but it does not discover a new maximal elliptic
subfield.

## Current gains

| Result | State | Evidence |
|---|---|---|
| Generic degree-5 self-fiber is a quartic with three ordinary nodes | Exact | `verify_degree5_family_structure.sage` |
| Its normalization is an explicit conic over $\mathbf Q(a,b)$ | Exact | `sage_degree5_family_structure.json` |
| Ten exact degree-5 source curves and maps | Exact | `census_degree5_family.sage` |
| All ten tested conics split over the branch quadratic field, none over $\mathbf Q$ | Experimental exact census | `sage_degree5_family_census.json` |
| Rational degree-6 Kumar specialization with two primitive maps and $S_6$ monodromy | Exact Sage identities, CRT scale recovery, and independent Magma degrees and Galois group | `recover_degree6_maps.sage`, `verify_degree6_maps.m`, `verify_degree6_monodromy.m` |
| Rational degree-7 Kumar specialization with two primitive maps and $S_7$ monodromy | Exact Sage identities, independent Magma degrees, Galois group, and elliptic-base disjointness | `verify_degree7_maps.sage`, `verify_degree7_maps.m`, `verify_degree7_monodromy.m` |
| Rational degree-8 Kumar specialization with two primitive maps and $S_8$ monodromy | Exact Sage full-function-field recovery, CRT scale discovery, source automorphism group, independent Magma degrees, and Galois group | `recover_degree8_maps.sage`, `verify_degree8_maps.m`, `verify_degree8_monodromy.m` |
| Rational degree-9 Kumar specialization with two primitive maps and $S_9$ monodromy | Exact Sage target-center CRT recovery, independent Magma degrees, deterministic modular cycle certificate, and discriminant base-change check | `recover_degree9_maps.sage`, `verify_degree9_maps.m`, `verify_degree9_monodromy.m` |
| Rational degree-10 and degree-11 Kumar specializations with both primitive map pairs | Exact Sage full-function-field identities, resumable scale CRT, and four independent Magma degree computations | `recover_degree10_maps.sage`, `recover_degree11_maps.sage`, `verify_degree10_maps.m`, `verify_degree11_maps.m` |
| Explicit degree-6 and degree-8 splitting kernels | Full torsion pullback to the genus-2 Jacobian, graph matrices, complete kernel enumeration, and inverse Weil pairings | `verify_degree6_splitting_kernel.m`, `verify_degree8_splitting_kernel.m` |
| Degree-independent Galois-closure complement quotient | Exact invariant equations, subgroup fixed fields, critical-quartic recovery, and genus-one signatures through degree 15 | `verify_galois_complement.sage`, `verify_galois_complement.m` |
| Kumar families in every degree 6 through 11 | Exact surface, Igusa, `j`-polynomial, and one nonsingular tautological curve per degree | `verify_kumar_family_importer.sage`, `verify_kumar_all_tautological_curves.sage` |
| Degree-13 Frey--Kani quotient curve | Exact theta quotient, invariant descent, explicit base-field model, and independent Sage/Magma Weil certificates | `reconstruct_degree13_curve.sage`, `reconstruct_degree13_curve.m` |
| Two degree-13 elliptic maps on the Rosenhain quotient | 34 exact theta evaluations, degree-13 interpolation, elliptic function-field identities, and linear differential pullbacks over $\mathbf F_{8009^{24}}$ | `recover_degree13_maps.sage`, `sage_degree13_maps.json` |
| Degree $20$ and $80$ maps from elliptic multiplication | Exact, nonprimitive | `verify_composed_high_degree_maps.sage` |

The machine-readable program is
[`research/data/beyond_paper.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/research/data/beyond_paper.json).
The live dashboard reports its progress independently of the completed paper
audit.

## Chapters

- [Theory and invariants](theory.md)
- [The generic degree-5 family](degree5.md)
- [Algorithms for degrees 6 and beyond](high_degree.md)
- [Executable examples](examples.md)
