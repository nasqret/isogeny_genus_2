# Execution Environments

## Local SageMath

- Version: SageMath 10.8.
- Role: symbolic identities, number fields, elliptic curves, independent
  cross-checks, result serialization.

## Remote Magma

- Host: `lts-faculty.wmi.amu.edu.pl`.
- Binary: `/opt/magma/current/magma`.
- Version: V2.28-3.
- Long jobs: GNU screen with named sessions and persisted logs.
- Important: the binary is available in a Bash login shell but not on the
  default non-login SSH PATH.
