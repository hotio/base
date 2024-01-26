#!/bin/bash

pia_version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/pia-foss/manual-connections/commits/master" | jq -r .sha)
[[ -z ${pia_version} ]] && exit 0
version_json=$(cat ./VERSION.json)
jq '.pia_version = "'"${pia_version}"'"' <<< "${version_json}" > VERSION.json
