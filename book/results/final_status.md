# Final Verification Status

The article-level reconstruction is complete.

| Outcome | Count |
|---|---:|
| Verified claims | 36 |
| Disproved claims | 4 |
| Unresolved claims | 0 |
| Total claims | 40 |

The machine audit checks the ordered claim range C001-C040, terminal statuses,
source-line bounds, artifact existence, and JSON validity. See
[`claim_audit.json`](https://github.com/nasqret/isogeny_genus_2/blob/main/results/claim_audit.json).

## Degree-5 discrepancies

The only disproved claims are C027-C030.

| Claim | Printed assertion | Exact outcome |
|---|---|---|
| C027 | The displayed quartic is the divided-difference equation. | Four coefficients are wrong: \(19500\) must be \(1950\) twice, and \(-707130\) must be \(-708130\) twice. |
| C028 | The displayed quartic has geometric genus zero. | The printed quartic is smooth of genus \(3\). The corrected quartic has three ordinary nodes and geometric genus \(0\). |
| C029 | The corrected genus-zero curve has no nonsingular point over \(\mathbb Q(z)\). | An exact nonsingular \(\mathbb Q(z)\)-point exists. |
| C030 | A further field extension is required for the parametrization. | The curve parametrizes over \(\mathbb Q(z)\) itself, and Magma gives \(j(E')=-250888806400/56807829\). |

The full source and citation analysis is in
[`degree5_source_audit.md`](https://github.com/nasqret/isogeny_genus_2/blob/main/research/reports/degree5_source_audit.md).

:::{note}
“Disproved” means that the article's printed computational assertion is false
or not reproducible as stated. The reconstruction preserves the original
source and records the corrected statement separately.
:::
