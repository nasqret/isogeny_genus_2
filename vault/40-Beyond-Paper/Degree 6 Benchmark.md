# Degree 6 Benchmark

Kumar's `Y_-(36)` family is specialized at
`(r,s,z)=(-9,9/2,39366)`.

## Certified data

- normalized rational genus-2 sextic;
- elliptic factors with `j=-972` and `j=1296`;
- unique rational twist `-1` for both targets;
- Hasse-Witt eigenform lines `x dx/y` and `dx/y`;
- first exact map with `X` in `Q(x)` and scale `-1`;
- complementary exact map with `X=A(x)+yB(x)` and scale `2/3`;
- CRT scale-square reconstruction from primes `101` and `103`;
- exact Sage function-field identities and cover degrees;
- no rational target isogenies of degree `2` or `3`, proving primitivity;
- independent Magma degree computations.
- exact `S6` monodromy over the elliptic base, ruling out the exceptional
  `PGL(2,5)` action for this specialization.

## Evidence

- `computations/sage/recover_degree6_maps.sage`
- `computations/magma/verify_degree6_maps.m`
- `results/sage_degree6_recovery.json`
- `results/magma_degree6_maps.json`
- `results/remote/magma_degree6_maps.log`

## Next obligation

Certify the explicit `(6,6)` splitting kernel, implement the full
Galois-closure quotient, and search the `Y_-(36)` family for genuinely
exceptional `PGL(2,5)` specializations.
