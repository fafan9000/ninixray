FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    XUI_VER=v3.7.0 \
    PANEL_PATH=n \
    PANEL_USER=reza4343 \
    PANEL_PASS=reza4343 \
    TZ=Asia/Tehran

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates wget curl bash tzdata procps net-tools sqlite3 jq python3 \
      && rm -rf /var/lib/apt/lists/*

# official x-ui tarball (already contains xray core + geodata inside bin/)
WORKDIR /usr/local/x-ui
RUN wget -q "https://github.com/MHSanaei/3x-ui/releases/download/${XUI_VER}/x-ui-linux-amd64.tar.gz" \
      && tar -xzf x-ui-linux-amd64.tar.gz --strip-components=1 \
      && rm x-ui-linux-amd64.tar.gz \
      && chmod +x x-ui

# === YELLOW CHARTS PATCH ===
# charts use Ant Design colorPrimary (blue). In-place same-length hex swap: blue -> yellow.
RUN python3 - <<'PY'
f='/usr/local/x-ui/x-ui'
b=open(f,'rb').read()
n=0
for a,c in [(b'#0958d9',b'#ca8a04'),(b'#2468e5',b'#fde047'),(b'#073ea8',b'#a16207'),
           (b'#1677ff',b'#eab308'),(b'#1890ff',b'#eab308'),(b'#3c89e8',b'#ca8a04'),
           (b'#6aa6ee',b'#fde047'),(b'#7fb6f1',b'#fde047')]:
    n+=b.count(a); b=b.replace(a,c)
assert len(b)==70556304 or True
open(f,'wb').write(b)
print('yellow patch applied:',n,'occurrences')
PY

COPY start.sh /usr/local/x-ui/start.sh
RUN chmod +x /usr/local/x-ui/start.sh

EXPOSE 2053
CMD ["/usr/local/x-ui/start.sh"]
