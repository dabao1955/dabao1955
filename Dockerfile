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
    desktop-file-utils \
    wget \
    tar \
    xz-utils \
    telegram-desktop && \
    wget https://github.com/DustinWin/proxy-tools/releases/download/Clash-Premium/clashpremium-nightly-linux-amd64-v3.tar.gz -O out.tar.gz && \
    tar -xvf out.tar.gz && \
    mv ClashCore clash && \
    mv clash /usr/local/bin/ \
    wget -O /config.yaml "https://hdbi4.no-mad-world.club/link/Q4Lpte9I7HB7LNCf?clash=3" && \
    apt-get clean && \
    apt-get autoremove tar \
    xz-utils && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    out.tar.gz &&\
    fc-cache -fv

COPY /root /
