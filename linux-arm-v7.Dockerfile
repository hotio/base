FROM alpine@sha256:8483ecd016885d8dba70426fda133c30466f661bb041490d525658f1aac73822

ENV APP_DIR="/app" CONFIG_DIR="/config" PUID="1000" PGID="1000" UMASK="002" TZ="Etc/UTC" ARGS=""
ENV XDG_CONFIG_HOME="${CONFIG_DIR}/.config" XDG_CACHE_HOME="${CONFIG_DIR}/.cache" XDG_DATA_HOME="${CONFIG_DIR}/.local/share" LANG="C.UTF-8" LC_ALL="C.UTF-8"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

VOLUME ["${CONFIG_DIR}"]
ENTRYPOINT ["/init"]

# install packages
RUN apk add --no-cache tzdata shadow bash curl wget jq grep sed coreutils findutils python3 unrar unzip p7zip ca-certificates

# make folders
RUN mkdir "${APP_DIR}" && \
# create user
    useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false hotio && \
    usermod -G users hotio

# https://github.com/just-containers/s6-overlay/releases
ARG S6_VERSION=2.2.0.3

# install s6-overlay
RUN curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-arm.tar.gz" | tar xzf - -C /

ARG BUILD_ARCHITECTURE
ENV BUILD_ARCHITECTURE=$BUILD_ARCHITECTURE

COPY root/ /
