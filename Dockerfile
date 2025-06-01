FROM jlesage/baseimage-gui:alpine-3.19-v4

LABEL org.opencontainers.image.source="https://github.com/dabao1955/dabao1955"

ENV \
    HOME="/config" \
    TITLE="Telegram" \
    APP_NAME="Telegram" \
    DISPLAY=":1" \
    ENABLE_CJK_FONT=1 \
    TZ=Asia/Shanghai

RUN \
    busybox sed -i 's#v3.19#edge#g' /etc/apk/repositories && \
    apk upgrade && \
    apk del openbox && \
    apk add --no-cache telegram-desktop xfce4 nano fastfetch font-noto-cjk openjdk21-jre-headless && \
    busybox wget https://github.com/DustinWin/proxy-tools/releases/download/Clash-Premium/clashpremium-nightly-linux-amd64.tar.gz -O out.tar.gz && \
    busybox tar -xvf out.tar.gz && \
    busybox mv -v ./CrashCore /usr/local/bin/clash && \
    ln -sfv /usr/bin/xfwm4 /usr/bin/openbox && \
    rm -rf /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    out.tar.gz && \
    fc-cache -fv && \
    printf "#!/bin/sh\n\nexec startxfce" > /startapp.sh && \
    chmod 777 -v /startapp.sh

EXPOSE 5800
EXPOSE 5900
