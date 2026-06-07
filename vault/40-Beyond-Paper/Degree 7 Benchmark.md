# Degree 7 Benchmark

Kumar's rational family on `Y_-(49)` was specialized at `u=1`.

## Certified data

- explicit genus-2 sextic;
- rational `j1=-20285403817/279936`;
- rational `j2=-97967097/128`;
- compatible rational quadratic twists;
- exact factorization of the genus-2 Frobenius polynomial at 41 good primes.
- both primitive degree-7 maps over `Q`;
- exact differential pullbacks `(49/12) dx/y` and `(-49/60) x dx/y`;
- independent Magma degree computations.

## Completed obligation

SageMath verifies the two function-field identities and Magma constructs both
morphisms and returns degree `7`. The Euler-factor calculation remains an
independent twist-selection and split-isogeny check.

## Evidence

- `computations/sage/verify_degree7_kumar_specialization.sage`
- `computations/sage/recover_degree7_maps.sage`
- `computations/sage/verify_degree7_maps.sage`
- `computations/magma/verify_degree7_maps.m`
- `results/sage_degree7_kumar_specialization.json`
- `results/sage_degree7_recovery.json`
- `results/sage_degree7_maps.json`
- `results/magma_degree7_maps.json`
