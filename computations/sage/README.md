# SageMath Computations

Each `.sage` file must:

1. state the claim IDs it verifies;
2. use exact arithmetic;
3. fail with an assertion on disagreement;
4. write a compact JSON or text certificate under `results/`;
5. document SageMath version and elapsed time.

## Beyond-paper artifacts

- `verify_degree5_family_structure.sage`: generic branch quadratic,
  three-node quartic, and normalization conic.
- `census_degree5_family.sage`: exact degree-5 source curves, maps, and conic
  solubility over the rational and branch fields.
- `verify_degree7_kumar_specialization.sage`: rational degree-7 benchmark and
  41 exact Euler-factor identities.
- `verify_composed_high_degree_maps.sage`: exact nonprimitive maps of degrees
  20 and 80.
