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
    telegram-desktop && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* &&\
    fc-cache -fv
