#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SESSION="isogeny-genus2-dashboard"

python3 "$ROOT/scripts/update-dashboard.py"

if screen -list | grep -q "[.]${SESSION}[[:space:]]"; then
  echo "Dashboard already running in screen session ${SESSION}."
else
  screen -dmS "$SESSION" bash -lc \
    "cd '$ROOT' && python3 -m http.server 8765 > dashboard/server.log 2>&1"
fi

echo "Dashboard: http://127.0.0.1:8765/dashboard/"
