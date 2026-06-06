# Reproducibility

## Local environment

- SageMath 10.8
- Jupyter Book 1.0.4.post1
- Pandoc 3.8.2.1
- latexmk 4.86a

## Remote environment

- Host: `lts-faculty.wmi.amu.edu.pl`
- Magma: `/opt/magma/current/magma`
- Version: V2.28-3
- Supervisor: GNU screen

## Build

```bash
./scripts/build-book.sh
```

## Strict audit

```bash
python3 scripts/audit-claims.py
./scripts/validate-all.sh
```

The audit requires every claim C001-C040 to be terminal and every linked
artifact to exist. Remote Magma transcripts are preserved under
`results/remote/`.

## Dashboard

```bash
./scripts/start-dashboard.sh
```

The dashboard separates completed paper verification from workstreams B001
onward.
