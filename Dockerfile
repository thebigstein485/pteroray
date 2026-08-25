FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="pteroray"
LABEL org.opencontainers.image.description="Xray container for Pterodactyl"
LABEL org.opencontainers.image.source="https://github.com/thebigstein485/pteroray"

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=container
ENV HOME=/home/container

# ---------------------------------------------------------
# Install required packages
# ---------------------------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------
# Create Pterodactyl container user
# ---------------------------------------------------------
RUN useradd \
        --create-home \
        --home-dir /home/container \
        --shell /bin/bash \
        --uid 1000 \
        container \
    && mkdir -p /home/container \
    && chown -R container:container /home/container

# ---------------------------------------------------------
# Install Xray
# ---------------------------------------------------------
ARG XRAY_VERSION=26.7.28

RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "$ARCH" in \
        amd64) XRAY_ARCH="64" ;; \
        arm64) XRAY_ARCH="arm64-v8a" ;; \
        *) \
            echo "Unsupported architecture: $ARCH"; \
            exit 1 ;; \
    esac; \
    curl -fL --retry 3 \
        "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-${XRAY_ARCH}.zip" \
        -o /tmp/xray.zip; \
    mkdir -p /tmp/xray; \
    unzip -q /tmp/xray.zip -d /tmp/xray; \
    install -m 0755 /tmp/xray/xray /usr/local/bin/xray; \
    rm -rf /tmp/xray /tmp/xray.zip

# ---------------------------------------------------------
# Verify Xray installation
# ---------------------------------------------------------
RUN /usr/local/bin/xray version

# ---------------------------------------------------------
# Pterodactyl working directory
# ---------------------------------------------------------
WORKDIR /home/container

# ---------------------------------------------------------
# Run as Pterodactyl's unprivileged user
# ---------------------------------------------------------
USER container

CMD ["/bin/bash"]
