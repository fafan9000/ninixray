#!/bin/bash
# NiniXray — 3x-ui panel on Railway (foreground, env-driven config)
set -e
cd /usr/local/x-ui

PORT="${PORT:-2053}"
PPATH="${PANEL_PATH:-n}"
PUSER="${PANEL_USER:-reza4343}"
PPASS="${PANEL_PASS:-reza4343}"
DB=/etc/x-ui/x-ui.db
mkdir -p /etc/x-ui

echo "[nini] panel: port=$PORT basePath=/$PPATH/ user=$PUSER"

# First run: seed the settings DB with panel port/user/pass/basePath.
if [ ! -f "$DB" ]; then
  ./x-ui setting -port "$PORT" -username "$PUSER" -password "$PPASS" -webBasePath "/$PPATH/" || true
fi

# PORT env: Railway injects its own PORT (usually 8080-ish public routing target).
# Railway's router expects the app to listen on $PORT. Use it if set, else default 2053.
if [ -n "$PORT" ] && [ "$PORT" != "2053" ]; then
  ./x-ui setting -port "$PORT" >/dev/null 2>&1 || true
fi

echo "[nini] starting 3x-ui (foreground)..."
exec ./x-ui
