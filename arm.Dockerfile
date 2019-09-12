FROM ubuntu:18.04
LABEL maintainer="hotio"

ARG DEBIAN_FRONTEND="noninteractive"

ENV APP_DIR="/app" CONFIG_DIR="/config" PUID="1000" PGID="1000" UMASK="022" VERSION="image"
ENV XDG_CONFIG_HOME="${CONFIG_DIR}/.config" XDG_CACHE_HOME="${CONFIG_DIR}/.cache" XDG_DATA_HOME="${CONFIG_DIR}/.local/share" LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

VOLUME ["${CONFIG_DIR}"]
ENTRYPOINT ["/init"]

# make folders
RUN mkdir "${APP_DIR}" && \
# create user
    useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false hotio && \
    usermod -G users hotio

COPY versions/ /tmp/

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        ca-certificates jq unzip curl fuse python \
        libfuse-dev autoconf automake build-essential \
        locales tzdata && \
# generate locale
    locale-gen en_US.UTF-8 && \
# install s6-overlay
    version=$(sed -n '2p' /tmp/version.s6-overlay) && \
    curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${version}/s6-overlay-arm.tar.gz" | tar xzf - -C / && \
# install rclone
    version=$(sed -n '2p' /tmp/version.rclone) && \
    curl -fsSL -o "/tmp/rclone.deb" "https://github.com/ncw/rclone/releases/download/v${version}/rclone-v${version}-linux-arm.deb" && dpkg --install "/tmp/rclone.deb" && \
# install rar2fs
    tempdir="$(mktemp -d)" && \
    version=$(sed -n '2p' /tmp/version.rar2fs) && \
    curl -fsSL "https://github.com/hasse69/rar2fs/archive/v${version}.tar.gz" | tar xzf - -C "${tempdir}" --strip-components=1 && \
    version=$(sed -n '2p' /tmp/version.unrarsrc) && \
    curl -fsSL "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz" | tar xzf - -C "${tempdir}" && \
    cd "${tempdir}/unrar" && \
    make lib && make install-lib && \
    cd "${tempdir}" && \
    autoreconf -f -i && \
    ./configure && make && make install && \
    cd ~ && \
    rm -rf "${tempdir}" && \
# clean up
    apt purge -y libfuse-dev autoconf automake build-essential && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
