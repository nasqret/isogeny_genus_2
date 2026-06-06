# Computation Collection

## SageMath

Local exact computations live under `computations/sage/`.

- [`verify_degree3_basic.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree3_basic.sage):
  cover identities, birational normalization, explicit complementary map,
  and denominator factorization.
- [`verify_degree3_elimination.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree3_elimination.sage):
  exact symmetric elimination, polynomial GCD, binary-quartic invariants, and
  four additional Kuhn-family samples.
- [`verify_degree4_example.sage`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/sage/verify_degree4_example.sage):
  critical and fiber-product discriminants, explicit complement
  normalization, twist identification, arithmetic, and ramification
  invariant.

## Magma

Remote computations live under `computations/magma/` and execute with Magma
V2.28-3 on `lts-faculty.wmi.amu.edu.pl`.

- [`smoke_test.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/smoke_test.m):
  remote engine and exact-arithmetic smoke certificate.
- [`verify_degree3_map.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree3_map.m):
  direct construction of the displayed complementary map and degree
  computation.
- [`verify_degree4_complement.m`](https://github.com/nasqret/isogeny_genus_2/blob/main/computations/magma/verify_degree4_complement.m):
  independent genus-one and isomorphism check for the self-fiber-product
  cubic.

## Evidence

Committed certificates and remote transcripts live under `results/`.
Upstream author code under `sources/upstream/` is reference material and is
never sufficient by itself to mark a claim verified.

- [`sage_degree3_basic.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree3_basic.json)
- [`sage_degree3_elimination.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree3_elimination.json)
- [`magma_degree3_map.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree3_map.json)
- [`sage_degree4_example.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/sage_degree4_example.json)
- [`magma_degree4_complement.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_degree4_complement.json)
- [`magma_remote_smoke.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/magma_remote_smoke.json)
