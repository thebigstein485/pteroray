# Gebruik het officiële Pterodactyl Debian yolk als basis
FROM ghcr.io/pterodactyl/yolks:debian

# Installeer unzip (voor Xray zip) en ca-certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Download en installeer Xray (amd64)
# Als je arm64 nodig hebt, pas de URL aan naar Xray-linux-64 -> Xray-linux-arm64-v8a
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
      XRAY_ARCH="linux-64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
      XRAY_ARCH="linux-arm64-v8a"; \
    else \
      echo "Niet-ondersteunde architectuur: $ARCH" && exit 1; \
    fi && \
    curl -L "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-${XRAY_ARCH}.zip" -o /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/xray && \
    rm /tmp/xray.zip

# De container draait als non-root (Pterodactyl regelt dit zelf)
# Geen USER指令 nodig; Pterodactyl override dit
