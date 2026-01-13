ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_ARM64

FROM alpine AS builder
ARG UNRAR_VER=7.1.10
ADD https://www.rarlab.com/rar/unrarsrc-${UNRAR_VER}.tar.gz /tmp/unrar.tar.gz
RUN apk --update --no-cache add build-base linux-headers && \
    tar -xzf /tmp/unrar.tar.gz && \
    cd unrar && \
    sed -i 's|LDFLAGS=-pthread|LDFLAGS=-pthread -static|' makefile && \
    sed -i 's|CXXFLAGS=-march=native|CXXFLAGS=-march=armv8-a+crypto+crc|' makefile && \
    make -f makefile && \
    install -Dm 755 unrar /usr/bin/unrar


FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_ARM64}

ARG IMAGE_STATS
ENV IMAGE_STATS=${IMAGE_STATS} \
    APP_DIR="/app" CONFIG_DIR="/config" XDG_CONFIG_HOME="/config/.config" XDG_CACHE_HOME="/config/.cache" XDG_DATA_HOME="/config/.local/share" \
    PUID="1000" PGID="1000" UMASK="002" TZ="Etc/UTC" \
    LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 S6_SERVICES_GRACETIME=180000 S6_STAGE2_HOOK="/etc/s6-overlay/init-hook" \
    VPN_ENABLED="false" VPN_CONF="wg0" VPN_PROVIDER="generic" VPN_LAN_NETWORK="" VPN_LAN_LEAK_ENABLED="false" VPN_EXPOSE_PORTS_ON_LAN="" VPN_AUTO_PORT_FORWARD="false" VPN_PORT_REDIRECTS="" VPN_HEALTHCHECK_ENABLED="false" VPN_NAMESERVERS="" PRIVOXY_ENABLED="false" UNBOUND_ENABLED="false" UNBOUND_NAMESERVERS="" \
    VPN_PIA_USER="" VPN_PIA_PASS="" VPN_PIA_PREFERRED_REGION="" VPN_PIA_DIP_TOKEN="" VPN_PIA_PORT_FORWARD_PERSIST="false"

VOLUME ["${CONFIG_DIR}"]

ENTRYPOINT ["/init"]

# install packages
RUN apk add --no-cache bash ca-certificates coreutils curl dos2unix findutils grep ipcalc iproute2 jq libcap-utils nftables outils-rs p7zip privoxy python3 sed shadow tzdata unbound unzip wget wireguard-tools && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community figlet libnatpmp

COPY --from=builder /usr/bin/unrar /usr/bin/unrar

# https://github.com/just-containers/s6-overlay/releases
ARG VERSION_S6
RUN curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-noarch.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-aarch64.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-symlinks-noarch.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-symlinks-arch.tar.xz" | tar Jpxf - -C /

# make folders
RUN mkdir "${APP_DIR}" && \
    mkdir "${CONFIG_DIR}" && \
# create user
    useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false hotio && \
    usermod -G users hotio

COPY root/ /
RUN chmod +x /etc/s6-overlay/init-hook && \
    find /etc/s6-overlay/s6-rc.d -name "run*" -execdir chmod +x {} +
