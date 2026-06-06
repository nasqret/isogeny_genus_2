# Genus 2 Complement Computation Reconstruction

This repository reconstructs and independently verifies the computational
claims in:

> Andrea Gallese, Davide Lombardo, Francesco Naccarato, and Umberto Zannier,
> *Finding the complement of an elliptic curve inside a Jacobian*,
> [arXiv:2606.02429](https://arxiv.org/abs/2606.02429).

The project prioritizes exact SageMath computations locally and Magma
computations on `lts-faculty.wmi.amu.edu.pl`. The central claim ledger is
[`research/data/claims.json`](research/data/claims.json); it drives the live
dashboard, Jupyter Book, and evidence index.

The article audit is complete: 36 claims are verified, four degree-5 claims
are disproved as printed, and none remain unresolved. Research beyond the
paper is tracked separately in
[`research/data/beyond_paper.json`](research/data/beyond_paper.json).

## Live surfaces

- Dashboard: `http://127.0.0.1:8765/dashboard/`
- Private repository: `https://github.com/nasqret/isogeny_genus_2`
- Jupyter Book after building: `book/_build/html/index.html`
- Final verification report: `research/reports/final_claim_audit.md`
- Degree-5 discrepancy report: `research/reports/degree5_source_audit.md`
- Obsidian vault: `vault/00-Project/Home.md`
- Plan: `PLAN.md`
- Journal: `JOURNAL.md`
- Durable memory: `MEMORY.md`

## Verification rule

A paper claim is marked verified only when an executable artifact, a successful
run, and a committed result or compact certificate are all present.

```bash
python3 scripts/audit-claims.py
./scripts/validate-all.sh
```
