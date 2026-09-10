FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    XUI_VER=v3.7.0 \
    XRAY_VER=v26.3.27 \
    PANEL_PATH=n \
    PANEL_USER=reza4343 \
    PANEL_PASS=reza4343 \
    TZ=Asia/Tehran

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates wget curl bash tzdata procps net-tools sqlite3 jq unzip \
      && rm -rf /var/lib/apt/lists/*

# x-ui tarball nests files inside an "x-ui/" dir → strip it
# BINARY SOURCE: patched binary (yellow charts) from own release xyellow1
WORKDIR /usr/local/x-ui
RUN wget -q "https://github.com/fafan9000/ninixray/releases/download/xyellow1/x-ui" \
      -O x-ui && chmod +x x-ui

# xray core into bin/ (x-ui expects ./bin/xray-linux-amd64) + geodata
RUN mkdir -p /usr/local/x-ui/bin \
    && wget -q "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip" \
    && unzip -o Xray-linux-64.zip -d /usr/local/x-ui/bin/ \
    && mv /usr/local/x-ui/bin/xray /usr/local/x-ui/bin/xray-linux-amd64 \
    && rm Xray-linux-64.zip \
    && chmod +x /usr/local/x-ui/bin/xray-linux-amd64 \
    && wget -q "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/geosite.dat" -O /usr/local/x-ui/bin/geosite.dat \
    && wget -q "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/geoip.dat" -O /usr/local/x-ui/bin/geoip.dat

COPY start.sh /usr/local/x-ui/start.sh
RUN chmod +x /usr/local/x-ui/start.sh

EXPOSE 2053
CMD ["/usr/local/x-ui/start.sh"]
