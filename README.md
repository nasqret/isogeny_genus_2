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

## Live surfaces

- Dashboard: `http://127.0.0.1:8765/dashboard/`
- Private repository: `https://github.com/nasqret/isogeny_genus_2`
- Jupyter Book after building: `book/_build/html/index.html`
- Obsidian vault: `vault/00-Project/Home.md`
- Plan: `PLAN.md`
- Journal: `JOURNAL.md`
- Durable memory: `MEMORY.md`

## Verification rule

A paper claim is marked verified only when an executable artifact, a successful
run, and a committed result or compact certificate are all present.
