FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    XUI_VER=v3.7.0 \
    XRAY_VER=v25.8.1 \
    PANEL_PORT=2053 \
    PANEL_PATH=n \
    PANEL_USER=reza4343 \
    PANEL_PASS=reza4343 \
    TZ=Asia/Tehran

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates wget curl bash tzdata procps net-tools sqlite3 jq unzip \
      && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/x-ui

# 3x-ui binary (linux amd64)
RUN wget -q "https://github.com/MHSanaei/3x-ui/releases/download/${XUI_VER}/x-ui-linux-amd64.tar.gz" \
      && tar -xzf x-ui-linux-amd64.tar.gz \
      && rm x-ui-linux-amd64.tar.gz \
      && chmod +x x-ui x-ui.sh

# Xray-core
RUN wget -q "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip" \
      && unzip -o Xray-linux-64.zip -d /usr/local/x-ui/ \
      && rm Xray-linux-64.zip \
      && chmod +x /usr/local/x-ui/xray

COPY start.sh /usr/local/x-ui/start.sh
RUN chmod +x /usr/local/x-ui/start.sh

EXPOSE 2053
CMD ["bash", "/usr/local/x-ui/start.sh"]
