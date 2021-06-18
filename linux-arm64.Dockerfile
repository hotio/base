FROM ubuntu@sha256:3f7c2c6e153e218a10ff78b3868811795fa09cc5d01be28296390ac75ab018b0

ARG DEBIAN_FRONTEND="noninteractive"

ENV APP_DIR="/app" CONFIG_DIR="/config" PUID="1000" PGID="1000" UMASK="002" TZ="Etc/UTC" ARGS=""
ENV XDG_CONFIG_HOME="${CONFIG_DIR}/.config" XDG_CACHE_HOME="${CONFIG_DIR}/.cache" XDG_DATA_HOME="${CONFIG_DIR}/.local/share" LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

VOLUME ["${CONFIG_DIR}"]
ENTRYPOINT ["/init"]

# make folders
RUN mkdir "${APP_DIR}" && \
# create user
    useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false hotio && \
    usermod -G users hotio

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        ca-certificates jq curl wget2 unzip p7zip-full unrar python3 \
        locales tzdata && \
# generate locale
    locale-gen en_US.UTF-8 && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# https://github.com/just-containers/s6-overlay/releases
ARG S6_VERSION=2.2.0.3

# install s6-overlay
RUN file="/tmp/s6-overlay.tar.gz" && curl -fsSL -o "${file}" "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-aarch64.tar.gz" && \
    tar xzf "${file}" -C / --exclude="./bin" && \
    tar xzf "${file}" -C /usr ./bin && \
    rm "${file}"

ARG BUILD_ARCHITECTURE
ENV BUILD_ARCHITECTURE=$BUILD_ARCHITECTURE
