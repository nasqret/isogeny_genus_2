# Degree 8 Benchmark

Kumar's `Y_-(64)` family is specialized at
`(r,s,z)=(4,-2,-1280)`.

## Certified data

- normalized rational genus-2 sextic
  `x^6+8*x^4+20*x^3+68*x^2+240*x+396`;
- elliptic factors with `j=-8780800/2187` and `j=5120/3`;
- unique rational twists `5` and `1`;
- Hasse-Witt eigenform lines `dx/y` and `(1+2*x) dx/y`;
- compact exact map with `X` in `Q(x)` and scale `2`;
- complementary exact map with `X=A(x)+yB(x)` and scale `2`;
- CRT scale-square reconstruction from primes `61` and `67`;
- exact Sage function-field identities and cover degrees;
- no rational target `2`-isogenies;
- source automorphism group of order `2`, excluding a degree-2 elliptic
  quotient and completing the primitivity proof;
- independent Magma degree computations;
- exact `S8` monodromy over the elliptic base.

## Evidence

- `computations/sage/recover_degree8_maps.sage`
- `computations/magma/verify_degree8_maps.m`
- `computations/magma/verify_degree8_monodromy.m`
- `results/sage_degree8_recovery.json`
- `results/magma_degree8_maps.json`
- `results/magma_degree8_monodromy.json`
- `results/remote/magma_degree8_maps.log`
- `results/remote/magma_degree8_monodromy.log`

## Next obligation

Use this benchmark to implement coefficient-level CRT lifting, then recover
rational degree-9 through degree-11 map pairs and compare their monodromy.
