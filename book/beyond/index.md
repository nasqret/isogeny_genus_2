# Beyond the Paper

Paper verification and new research are tracked separately. Claims C001-C040
are frozen article obligations; workstreams B001 onward may strengthen,
generalize, or replace the paper's calculations.

## Initial program

| ID | Workstream | State |
|---|---|---|
| B001 | Universal torsion classification for quartic self-fibers | Complete |
| B002 | Generic degree-5 base-field parametrization locus | In progress |
| B003 | Generic degree-5 complementary \(j\)-formula | Planned |
| B004 | Large exact census in degrees \(3,4,5\) | Planned |
| B005 | Arithmetic of complementary factors over number fields | Planned |
| B006 | Automated TeX-to-CAS discrepancy detection | Planned |

The machine-readable program is
[`research/data/beyond_paper.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/research/data/beyond_paper.json).
Its progress is displayed separately on the live dashboard.

## First result

For a normalized quartic
\[
g(x)=x^4+px^2+qx,
\]
the off-diagonal self-fiber is birational to
\[
V^2=U^3+2pU^2+4q^2
\]
and carries the universal point \(P=(-2p,2q)\). Exact division-polynomial
factorization, together with Mazur's theorem, classifies every rational
parameter for which \(P\) is torsion. This is stronger than merely checking
the three exceptional values listed in the paper.
