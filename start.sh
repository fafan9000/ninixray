#!/bin/bash
# NiniXray — 3x-ui on Railway with non-fatal inbound seeding
cd /usr/local/x-ui

PPORT="${PORT:-2053}"                 # panel port (Railway injects PORT)
PROXY_PORT="${PROXY_PORT:-2056}"      # proxy port for domain2
PUSER="${PANEL_USER:-reza4343}"
PPASS="${PANEL_PASS:-reza4343}"
SS_PASS="${SS_PASS:-niniCOl0QeW6Hg6V}"
DB=/etc/x-ui/x-ui.db
mkdir -p /etc/x-ui

if [ ! -f "$DB" ]; then
  ./x-ui setting -port "$PPORT" -username "$PUSER" -password "$PPASS" -webBasePath "/n/" >/dev/null 2>&1 || true
fi

echo "[nini] starting x-ui (panel :$PPORT, proxy :$PROXY_PORT)"
./x-ui &
XUI_PID=$!

# wait for panel to answer (no pipe-to-python during this loop)
i=0
while [ $i -lt 30 ]; do
  i=$((i+1)); sleep 2
  if curl -sf -o /dev/null "http://127.0.0.1:$PPORT/n/" 2>/dev/null; then break; fi
done
echo "[nini] panel up; seeding inbounds (best effort)"

B="http://127.0.0.1:$PPORT"
seed() {
  set +e
  curl -sS -m 10 -c /tmp/cj.txt "$B/n/csrf-token" -o /tmp/c1.json 2>/dev/null
  CT=$(python3 -c "import json;print(json.load(open('/tmp/c1.json'))['obj'])" 2>/dev/null)
  [ -z "$CT" ] && { echo "[nini] no csrf token, skip seeding"; return 0; }
  curl -sS -m 10 -b /tmp/cj.txt -c /tmp/cj.txt -X POST "$B/n/login" \
    -H "Content-Type: application/json" -H "X-CSRF-Token: $CT" \
    -d "{\"username\":\"$PUSER\",\"password\":\"$PPASS\"}" -o /dev/null 2>/dev/null
  curl -sS -m 10 -b /tmp/cj.txt "$B/n/csrf-token" -o /tmp/c2.json 2>/dev/null
  CT2=$(python3 -c "import json;print(json.load(open('/tmp/c2.json'))['obj'])" 2>/dev/null)
  CNT=$(curl -sS -m 10 -b /tmp/cj.txt "$B/n/panel/api/inbounds/list" 2>/dev/null | python3 -c "import json,sys;print(len(json.load(sys.stdin).get('obj') or []))" 2>/dev/null)
  CNT=${CNT:-0}
  echo "[nini] inbounds present: $CNT"
  if [ "$CNT" -lt 1 ]; then
    curl -sS -m 15 -b /tmp/cj.txt -X POST "$B/n/panel/api/inbounds/add" \
      -H "Content-Type: application/json" -H "X-CSRF-Token: $CT2" -d "{
        \"listen\":\"0.0.0.0\",\"port\":$PROXY_PORT,\"protocol\":\"shadowsocks\",\"tag\":\"in-$PROXY_PORT-ss\",
        \"remark\":\"Nini-SS-WS\",\"enable\":true,
        \"settings\":\"{\\\"clients\\\":[{\\\"method\\\":\\\"chacha20-ietf-poly1305\\\",\\\"password\\\":\\\"$SS_PASS\\\",\\\"email\\\":\\\"reza@ss\\\",\\\"enable\\\":true}],\\\"disableInsecureEncryption\\\":false}\",
        \"streamSettings\":\"{\\\"network\\\":\\\"ws\\\",\\\"security\\\":\\\"none\\\",\\\"wsSettings\\\":{\\\"path\\\":\\\"/ssws\\\"}}\",
        \"sniffing\":\"{\\\"enabled\\\":true,\\\"destOverride\\\":[\\\"http\\\",\\\"tls\\\"]}\"}" -o /dev/null 2>/dev/null
    echo "[nini] seeded SS inbound"
  fi
  set -e
}
seed || echo "[nini] seeding failed (ignored)"

echo "[nini] ready — panel :$PPORT"
wait $XUI_PID
