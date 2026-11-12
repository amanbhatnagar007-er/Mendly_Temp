#!/usr/bin/env sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$ROOT"
if ! command -v python3 >/dev/null 2>&1; then
  if command -v node >/dev/null 2>&1; then exec node runtime/server.mjs; fi
  printf 'Install Python 3.11+ or Node.js 20+ to start Mendaly.\n' >&2
  exit 1
fi
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
uvicorn app.main:app --host 127.0.0.1 --port 8000 &
API_PID=$!
WEB_PID=
cleanup() { kill "$API_PID" 2>/dev/null || true; if [ -n "$WEB_PID" ]; then kill "$WEB_PID" 2>/dev/null || true; fi; }
trap cleanup INT TERM EXIT
cd frontend
npm install
npm run dev -- --host 127.0.0.1 &
WEB_PID=$!
printf 'Mendaly API: http://localhost:8000/docs\nMendaly Web: http://localhost:5173\n'
wait
