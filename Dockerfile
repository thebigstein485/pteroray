# Gebruik het officiële Pterodactyl Debian yolk als basis
FROM ghcr.io/pterodactyl/yolks:debian

# Schakel tijdelijk naar root om pakketten te kunnen installeren
USER root

# Installeer unzip, curl (voor Xray download) en ca-certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    curl \
    ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Download en installeer Xray (amd64)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
      XRAY_ARCH="linux-64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
      XRAY_ARCH="linux-arm64-v8a"; \
    else \
      echo "Niet-ondersteunde architectuur: $ARCH" && exit 1; \
    fi && \
    curl -L "https://github.com{XRAY_ARCH}.zip" -o /tmp/xray.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/xray && \
    rm /tmp/xray.zip

# Schakel terug naar de standaard Pterodactyl gebruiker
USER container
ENV USER=container HOME=/home/container
