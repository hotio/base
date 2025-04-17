#!/bin/bash
version_s6=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/just-containers/s6-overlay/releases/latest" | jq -re .tag_name) || exit 1
[[ -z ${version_s6} ]] && exit 0
[[ ${version_s6} == null ]] && exit 0
version_root_files=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/hotio/root-files/tags" | jq -re .[0].name) || exit 1
[[ -z ${version_root_files} ]] && exit 0
[[ ${version_root_files} == null ]] && exit 0
json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${version_s6//v/}" \
    --arg version_root_files "${version_root_files//v/}" \
    --arg version_s6 "${version_s6//v/}" \
    '.version = $version | .version_s6 = $version_s6 | .version_root_files = $version_root_files' <<< "${json}" | tee VERSION.json
