# Magma Computations

Magma jobs run remotely on `lts-faculty.wmi.amu.edu.pl` with
`/opt/magma/current/magma` (V2.28-3).

Each `.m` file must print machine-identifiable claim IDs, use assertions for
all decisive equalities, and end with a clear success marker. Long jobs run in
GNU screen; transcripts and exit codes are copied to `results/remote/`.

`verify_degree7_maps.m` independently constructs both morphisms for the Kumar
benchmark and asks Magma to certify that each has degree `7`.
