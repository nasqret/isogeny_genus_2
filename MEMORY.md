# Durable Project Memory

## Purpose

This project reconstructs every computational claim in
`sources/paper.tex` using SageMath locally and Magma remotely.

## Sources of truth

- Claim status: `research/data/claims.json`
- Environment readiness: `research/data/environments.json`
- Remote jobs: `research/data/remote_jobs.json`
- Recent evidence: `research/data/recent_results.json`
- Human progress log: `JOURNAL.md`
- Execution plan: `PLAN.md`
- Live dashboard payload: generated `dashboard/status.json`
- Ephemeral remote telemetry: generated `dashboard/remote_runtime.json`

## Verification policy

- Do not count copied upstream output as independent verification.
- Do not mark a claim verified without executable code and saved evidence.
- Keep implementation completeness separate from verification completeness.
- Preserve source discrepancies as `review_needed`; do not silently repair the
  paper.
- Keep live remote runtime telemetry separate from committed mathematical
  evidence.

## Environments

- Local: SageMath 10.8 on macOS.
- Remote: Magma V2.28-3 at `/opt/magma/current/magma` on
  `lts-faculty.wmi.amu.edu.pl`.
- Remote commands requiring Magma must use a Bash login shell or the absolute
  binary path.
- Long remote work should run in named GNU screen sessions with logs and exit
  files copied back under `results/remote/`.

## Upstream provenance

- Paper: arXiv `2606.02429`, source downloaded June 6, 2026.
- Companion repository:
  `https://github.com/G4ll/NoteOnGenus2Covers`.
- Inspected upstream commit:
  `d7f91b16b325e7832b3647c514e6cbbfb949f0d6`.

## Resume protocol

1. Read `PLAN.md` and the latest `JOURNAL.md` entry.
2. Regenerate dashboard state with `python3 scripts/update-dashboard.py`.
3. Check `git status`.
4. Check `research/data/remote_jobs.json` and refresh live telemetry.
5. Continue the current bounded task; update the ledger before claiming
   progress.
