#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SESSION="isogeny-genus2-dashboard"

screen -S "$SESSION" -X quit 2>/dev/null || true
echo "Stopped ${SESSION}."
