# Magma Computations

Magma jobs run remotely on `lts-faculty.wmi.amu.edu.pl` with
`/opt/magma/current/magma` (V2.28-3).

Each `.m` file must print machine-identifiable claim IDs, use assertions for
all decisive equalities, and end with a clear success marker. Long jobs run in
GNU screen; transcripts and exit codes are copied to `results/remote/`.

`verify_degree7_maps.m` independently constructs both morphisms for the Kumar
benchmark and asks Magma to certify that each has degree `7`.

`verify_degree6_maps.m` independently constructs both morphisms for the
`Y_-(36)` benchmark. The complementary coordinate is evaluated in the full
function field as `A(x)+y*B(x)`; Magma certifies both target equations and
returns degree `6` for each map.

`verify_degree6_monodromy.m` computes the exact group `S6` for the compact
quotient's generic sextic fiber and checks that the elliptic-base quadratic
extension has a different square class from the unique quadratic subfield of
the splitting field.

`verify_degree8_maps.m` independently constructs both morphisms for the
`Y_-(64)` benchmark. It checks the compact rational coordinate, reconstructs
the complementary `A(x)+yB(x)` coordinate in the full function field,
computes both degrees as `8`, and verifies that the source automorphism group
has order `2`.

`verify_degree8_monodromy.m` computes the exact group `S8` for the compact
quotient's generic octic fiber and proves that the elliptic-base quadratic
extension does not absorb the unique quadratic subfield of the splitting
field.

`lib/splitting_kernel.m` implements the reusable torsion-pullback and
anti-isometry certificate. `verify_degree6_splitting_kernel.m` and
`verify_degree8_splitting_kernel.m` recover explicit graph matrices at good
reduction, enumerate all kernel pairs, and verify inverse Weil pairings.

`verify_degree5_conic_generic.m` certifies the universal branch-field point
on the degree-5 normalization conic over `Q(a)(b,c)`.

`derive_degree5_complement_j_generic.m` is the full two-parameter expansion
path for the compact quartic-invariant formula. The compact, routinely
validated implementation is `computations/sage/lib/degree5_complement.sage`;
the expanded Magma trace/norm form is intentionally treated as a heavy
derived artifact.

`verify_degree13_anti_isometry.m` independently certifies the first
beyond-degree-11 Frey-Kani synthesis: full rational `13`-torsion on two
curves over `F_8009`, the matrix `diag(1,3)`, inverse Weil pairings, all
`169` graph points, the count of `2184` compatible matrices, distinct CM
squareclasses, and the quotient Weil polynomial.
