# Final Computational Claim Audit

## Scope

The source was read line by line through all 783 lines. Computational
obligations occur in the following zones:

| Source lines | Topic | Claims |
|---|---|---|
| 242-274, 312-422 | General symmetric-square algorithm | C001-C005 |
| 427-527 | Divisor and interpolation algorithm | C006-C007 |
| 549-630 | Critical quartics and subgroup tower | C008-C011, C036-C038 |
| 637-671 | Degree-3 example | C012-C020, C035 |
| 674-677 | Degree-4 example | C021-C025 |
| 681-701 | Degree-5 example | C026-C030 |
| 709-742 | Degree-2 family and twists | C031-C033, C039-C040 |

Claims C035-C040 were added by the second audit after the initial inventory
had missed universal linearity, the quartic ellipticity criterion, the
subgroup tower, the exceptional values, dominance, and the converse twist
construction.

## Terminal outcomes

Every claim C001-C040 has executable evidence and a terminal status.

- `verified`: claims whose stated computational conclusion is reproduced.
- `disproved`: C027-C030, the four degree-5 statements that are false or not
  reproducible as printed.

The strict machine audit is
[`scripts/audit-claims.py`](../../scripts/audit-claims.py). It rejects missing
IDs, unresolved statuses, invalid source ranges, absent artifacts, malformed
JSON evidence, and undocumented discrepancies. Its certificate is
[`results/claim_audit.json`](../../results/claim_audit.json).
