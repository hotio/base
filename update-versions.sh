#!/bin/bash
set -exuo pipefail

version_s6=$(curl -fsSL "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | jq -re .tag_name)
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version_s6 "${version_s6//v/}" \
    '.version_s6 = $version_s6' <<< "${json}" | tee VERSION.json
