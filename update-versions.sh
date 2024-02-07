#!/bin/bash
set -e
pia_version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/pia-foss/manual-connections/commits/master" | jq -re .sha)
json=$(cat VERSION.json)
jq --sort-keys \
    --arg pia_version "${pia_version//v/}" \
    '.pia_version = $pia_version' <<< "${json}" | tee VERSION.json
