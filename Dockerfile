# Pterodactyl Debian yolk
FROM ghcr.io/pterodactyl/yolks:debian

USER root

# Pakketten installeren
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    curl \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Xray installeren
RUN set -eux; \
    ARCH="$(uname -m)"; \
    if [ "$ARCH" = "x86_64" ]; then \
        XRAY_ARCH="64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        XRAY_ARCH="arm64-v8a"; \
    else \
        echo "Niet-ondersteunde architectuur: $ARCH"; \
        exit 1; \
    fi; \
    curl -fL "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${XRAY_ARCH}.zip" \
        -o /tmp/xray.zip; \
    unzip -o /tmp/xray.zip -d /tmp/xray; \
    install -m 0755 /tmp/xray/xray /usr/local/bin/xray; \
    rm -rf /tmp/xray /tmp/xray.zip

USER container

ENV USER=container
ENV HOME=/home/container
