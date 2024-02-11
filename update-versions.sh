#!/bin/bash
version_pia=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/pia-foss/manual-connections/commits/master" | jq -re .sha) || exit 1
version_s6=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | jq -re .tag_name) || exit 1
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version_pia "${version_pia//v/}" \
    --arg version_s6 "${version_s6//v/}" \
    '.version_pia = $version_pia | .version_s6 = $version_s6' <<< "${json}" | tee VERSION.json

if ! git diff --quiet; then
    json=$(cat VERSION.json)
    jq --sort-keys \
        --arg version "$(date -u +'%Y%m%d%H%M%S')" \
        '.version = $version' <<< "${json}" | tee VERSION.json
fi
