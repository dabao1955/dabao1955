FROM jlesage/baseimage-gui:debian-12-v4

LABEL org.opencontainers.image.source="https://github.com/dabao1955/dabao1955"

ENV \
    HOME="/config" \
    TITLE="dde"


SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
RUN \
    apt-get update -y && apt-get install -y --no-install-recommends --no-install-suggests --fix-missing \
    fonts-noto-cjk \
    desktop-file-utils \
    wget \
    tar \
    xterm \
    xz-utils \
    telegram-desktop && \
    wget https://github.com/DustinWin/proxy-tools/releases/download/Clash-Premium/clashpremium-nightly-linux-amd64.tar.gz -O out.tar.gz && \
    tar -xvf out.tar.gz && \
    mv ./CrashCore /usr/local/bin/clash && \
    wget https://repo.gxde.top/gxde-os/bixie/g/gxde-source/gxde-source_1.1.6_all.deb -O main.deb && \
    apt-get -y install ./main.deb && \
    apt-get update && \
    apt-get install gxde-desktop && \
    apt-get clean && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    out.tar.gz && \
    fc-cache -fv && \
    printf "#!/bin/sh \nexec startdde\n" > /startapp.sh
