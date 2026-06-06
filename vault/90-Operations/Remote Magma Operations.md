# Remote Magma Operations

## Contract

1. Copy a tracked `.m` file from `computations/magma/`.
2. Launch it in a named GNU screen session.
3. Redirect output to a stable remote log and write an exit-code file.
4. Record the job in `research/data/remote_jobs.json`.
5. Copy completed logs and certificates to `results/remote/`.
6. Mark a claim verified only after local import and validation.

## Host

`lts-faculty.wmi.amu.edu.pl`

## Magma

`/opt/magma/current/magma` (V2.28-3)
