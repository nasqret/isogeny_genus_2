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
| Rational degree-7 Kumar specialization with two primitive maps | Exact Sage identities and independent Magma degrees | `verify_degree7_maps.sage`, `verify_degree7_maps.m` |
| Kumar families in every degree 6 through 11 | Exact surface, Igusa, `j`-polynomial, and one nonsingular tautological curve per degree | `verify_kumar_family_importer.sage`, `verify_kumar_all_tautological_curves.sage` |
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
