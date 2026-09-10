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

WORKDIR /usr/local/x-ui
RUN wget -q "https://github.com/MHSanaei/3x-ui/releases/download/${XUI_VER}/x-ui-linux-amd64.tar.gz" \
      && tar -xzf x-ui-linux-amd64.tar.gz --strip-components=1 \
      && rm x-ui-linux-amd64.tar.gz \
      && chmod +x x-ui

# === YELLOW CHARTS PATCH (in-place, same-length hex swap, binary + all embedded assets) ===
RUN python3 - <<'PY'
import re
f='/usr/local/x-ui/x-ui'
b=open(f,'rb').read()
n=0
pairs=[(b'#0958d9',b'#ca8a04'),(b'#2468e5',b'#fde047'),(b'#073ea8',b'#a16207'),
       (b'#1677ff',b'#eab308'),(b'#1890ff',b'#eab308'),(b'#3c89e8',b'#ca8a04'),
       (b'#6aa6ee',b'#fde047'),(b'#7fb6f1',b'#fde047'),
       (b'#1677FF',b'#EAB308'),
       (b'#3b82f6',b'#eab308'),(b'#60a5fa',b'#fde047'),
       (b'#1d4ed8',b'#a16207'),(b'#3b82f638',b'#eab30838'),(b'#3b82f666',b'#eab30866'),
       (b'#3b82f66b',b'#eab3086b'),(b'#60a5fa6b',b'#fde0476b')]
for a,c in pairs:
    n+=b.count(a); b=b.replace(a,c)
open(f,'wb').write(b)
print('yellow patch applied:',n,'occurrences')
PY

COPY start.sh /usr/local/x-ui/start.sh
RUN chmod +x /usr/local/x-ui/start.sh

EXPOSE 2053
CMD ["/usr/local/x-ui/start.sh"]
