FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL org.opencontainers.image.source="https://github.com/dabao1955/dabao1955"

ENV \
    CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8181" \
    HOME="/config" \
    TITLE="Telegram" \
    DISPLAY=":1" \
    ENABLE_CJK_FONT=1 \
    TZ=Asia/Shanghai

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
RUN \
    apt-get update && apt-get install -y --no-install-recommends --no-install-suggests --fix-missing lxde* telegram-desktop \
    openjdk-17-jre-headless fonts-noto-cjk htop neofetch \
    desktop-file-utils wget tar xz-utils && \
    apt clean && \
    rm -rf /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    out.tar.gz && \
    fc-cache -fv && \
    printf "#!/bin/bash\n\nvncserver :0" > /defaults/autostart && \
    chmod 777 /defaults/autostart

EXPOSE 8080
