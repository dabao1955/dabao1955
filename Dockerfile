FROM ghcr.io/linuxserver/baseimage-kasmvnc:alpine321

LABEL org.opencontainers.image.source="https://github.com/dabao1955/dabao1955"

ENV \
    CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8181" \
    HOME="/config" \
    TITLE="Telegram"


SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
RUN \
    apk add --no-cache telegram-desktop lxde nano fastfetch fonts-noto-cjk openjdk21-jre-headless && \
    busybox wget https://github.com/DustinWin/proxy-tools/releases/download/Clash-Premium/clashpremium-nightly-linux-amd64.tar.gz -O out.tar.gz && \
    busybox tar -xvf out.tar.gz && \
    busybox mv ./CrashCore /usr/local/bin/clash && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    out.tar.gz && \
    fc-cache -fv && \
    printf "#!/bin/bash\n\nvncserver :0" > /defaults/autostart && \
    chmod 777 /defaults/autostart

EXPOSE 8080
