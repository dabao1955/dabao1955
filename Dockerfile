FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

LABEL org.opencontainers.image.source="https://github.com/dabao1955/dabao1955"

ENV \
    CUSTOM_PORT="8080" \
    CUSTOM_HTTPS_PORT="8181" \
    HOME="/config" \
    TITLE="Telegram"


SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
RUN \
    apt-get update -y && apt-get install -y --no-install-recommends --no-install-suggests --fix-missing \
    fonts-noto-cjk \
    cinnamon \
    desktop-file-utils \
    wget \
    tar \
    xz-utils \
    xvfb \
    x11vnc \
    telegram-desktop && \
    wget https://github.com/DustinWin/proxy-tools/releases/download/Clash-Premium/clashpremium-nightly-linux-amd64.tar.gz -O out.tar.gz && \
    tar -xvf out.tar.gz && \
    mv ./CrashCore /usr/local/bin/clash && \
    apt-get clean && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    out.tar.gz && \
    fc-cache -fv && \
    printf "#!/bin/bash\n\nexport DISPLAY=:0\nXvfb :0 -screen 0 1280x960x24 -listen tcp -ac +extension GLX +extension RENDER & x11vnc -display :0 -forever -shared -rfbport 5900 -passwd 123456 &" > /defaults/autostart && \
    chmod 777 /defaults/autostart 