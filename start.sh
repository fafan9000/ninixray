#!/bin/bash
# NiniXray — minimal stable (no seeding; configure inbounds externally)
cd /usr/local/x-ui

PPORT="${PORT:-2053}"
PUSER="${PANEL_USER:-reza4343}"
PPASS="${PANEL_PASS:-reza4343}"
DB=/etc/x-ui/x-ui.db
mkdir -p /etc/x-ui

if [ ! -f "$DB" ]; then
  ./x-ui setting -port "$PPORT" -username "$PUSER" -password "$PPASS" -webBasePath "/n/" || true
fi

echo "[nini] starting 3x-ui (foreground) on :$PPORT"
exec ./x-ui
