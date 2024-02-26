ARG UPSTREAM_IMAGE
ARG UPSTREAM_DIGEST_AMD64

FROM alpine AS builder
ARG UNRAR_VER=6.2.12
RUN apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    build-base \
    cmake \
    cppunit-dev \
    curl-dev \
    libtool \
    linux-headers \
    zlib-dev \
# Install unrar from source
&& cd /tmp \
&& wget https://www.rarlab.com/rar/unrarsrc-${UNRAR_VER}.tar.gz -O /tmp/unrar.tar.gz \
&& tar -xzf /tmp/unrar.tar.gz \
&& cd unrar \
&& make -f makefile \
&& install -Dm 755 unrar /usr/bin/unrar


FROM ${UPSTREAM_IMAGE}@${UPSTREAM_DIGEST_AMD64}

ARG IMAGE_STATS
ARG BUILD_ARCHITECTURE
ENV IMAGE_STATS=${IMAGE_STATS} BUILD_ARCHITECTURE=${BUILD_ARCHITECTURE} \
    APP_DIR="/app" CONFIG_DIR="/config" PUID="1000" PGID="1000" UMASK="002" TZ="Etc/UTC" \
    XDG_CONFIG_HOME="${CONFIG_DIR}/.config" XDG_CACHE_HOME="${CONFIG_DIR}/.cache" XDG_DATA_HOME="${CONFIG_DIR}/.local/share" \
    LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 S6_SERVICES_GRACETIME=180000 S6_STAGE2_HOOK="/init-hook" \
    VPN_ENABLED="false" VPN_CONF="wg0" VPN_PROVIDER="generic" VPN_LAN_NETWORK="" VPN_EXPOSE_PORTS_ON_LAN="" VPN_AUTO_PORT_FORWARD="true" VPN_AUTO_PORT_FORWARD_TO_PORTS="" VPN_KEEP_LOCAL_DNS="false" PRIVOXY_ENABLED="false" UNBOUND_ENABLED="false" \
    VPN_PIA_USER="" VPN_PIA_PASS="" VPN_PIA_PREFERRED_REGION="" VPN_PIA_DIP_TOKEN="no" VPN_PIA_PORT_FORWARD_PERSIST="false"

VOLUME ["${CONFIG_DIR}"]

ENTRYPOINT ["/init"]

# install packages
RUN apk add --no-cache tzdata shadow bash curl wget jq grep sed coreutils findutils python3 unzip p7zip ca-certificates util-linux-misc libcap-utils unbound privoxy iproute2 openresolv wireguard-tools iptables ip6tables && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing wireguard-go && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community libnatpmp figlet

COPY --from=builder /usr/bin/unrar /usr/bin/

# https://github.com/just-containers/s6-overlay/releases
ARG VERSION_S6
RUN curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-noarch.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-x86_64.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-symlinks-noarch.tar.xz" | tar Jpxf - -C / && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${VERSION_S6}/s6-overlay-symlinks-arch.tar.xz" | tar Jpxf - -C /

# make folders
RUN mkdir "${APP_DIR}" && \
    mkdir "${CONFIG_DIR}" && \
# create user
    useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false hotio && \
    usermod -G users hotio

COPY root/ /
RUN chmod +x /init-hook
