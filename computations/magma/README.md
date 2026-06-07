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
