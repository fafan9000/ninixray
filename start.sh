#!/bin/bash
# NiniXray — 3x-ui on Railway with SELF-HEAL inbound seeding
# On every boot (incl. after redeploy when DB is fresh):
#  1) start x-ui, wait for panel
#  2) login via panel API (csrf) and ensure VLESS/SS WS inbound exists on $PROXY_PORT
set -e
cd /usr/local/x-ui

PPORT="${PORT:-2053}"                 # panel port (Railway PORT)
PROXY_PORT="${PROXY_PORT:-2056}"      # exposed proxy port (domain2 targetPort)
PUSER="${PANEL_USER:-reza4343}"
PPASS="${PANEL_PASS:-reza4343}"
SS_PASS="${SS_PASS:-niniCOl0QeW6Hg6V}"
DB=/etc/x-ui/x-ui.db
mkdir -p /etc/x-ui

if [ ! -f "$DB" ]; then
  ./x-ui setting -port "$PPORT" -username "$PUSER" -password "$PPASS" -webBasePath "/n/" || true
fi

echo "[nini] starting x-ui (panel :$PPORT, proxy :$PROXY_PORT)"
./x-ui &
XUI_PID=$!

# wait for panel
for i in $(seq 1 30); do
  sleep 2
  if curl -sf "http://127.0.0.1:$PPORT/n/" >/dev/null 2>&1; then break; fi
done
echo "[nini] panel up, seeding inbounds..."

B="http://127.0.0.1:$PPORT"
J() { python3 -c "import json,sys;print(json.load(sys.stdin).get('obj',''))" 2>/dev/null; }
CT=$(curl -sS -m 10 -c /tmp/cj.txt "$B/n/csrf-token" | J)
curl -sS -m 10 -b /tmp/cj.txt -c /tmp/cj.txt -X POST "$B/n/login" -H "Content-Type: application/json" -H "X-CSRF-Token: $CT" -d "{\"username\":\"$PUSER\",\"password\":\"$PPASS\"}" >/dev/null
CT2=$(curl -sS -m 10 -b /tmp/cj.txt "$B/n/csrf-token" | J)

CNT=$(curl -sS -m 10 -b /tmp/cj.txt "$B/n/panel/api/inbounds/list" | python3 -c "import json,sys;print(len(json.load(sys.stdin).get('obj') or []))" 2>/dev/null)
echo "[nini] inbounds present: $CNT"
if [ "${CNT:-0}" -lt 1 ]; then
  curl -sS -m 15 -b /tmp/cj.txt -X POST "$B/n/panel/api/inbounds/add" \
    -H "Content-Type: application/json" -H "X-CSRF-Token: $CT2" -d "{
      \"listen\":\"0.0.0.0\",\"port\":$PROXY_PORT,\"protocol\":\"shadowsocks\",\"tag\":\"in-$PROXY_PORT-ss\",
      \"remark\":\"Nini-SS-WS\",\"enable\":true,
      \"settings\":\"{\\\"clients\\\":[{\\\"method\\\":\\\"chacha20-ietf-poly1305\\\",\\\"password\\\":\\\"$SS_PASS\\\",\\\"email\\\":\\\"reza@ss\\\",\\\"enable\\\":true}],\\\"disableInsecureEncryption\\\":false}\",
      \"streamSettings\":\"{\\\"network\\\":\\\"ws\\\",\\\"security\\\":\\\"none\\\",\\\"wsSettings\\\":{\\\"path\\\":\\\"/ssws\\\"}}\",
      \"sniffing\":\"{\\\"enabled\\\":true,\\\"destOverride\\\":[\\\"http\\\",\\\"tls\\\"]}\"}" | head -c 120
  echo
fi

# keep container alive attached to x-ui
wait $XUI_PID
