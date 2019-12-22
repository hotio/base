#!/bin/bash

if [[ ${1} == "checkpackages" ]]; then
    export DEBIAN_FRONTEND="noninteractive"
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker run --rm -v "${GITHUB_WORKSPACE}":/github -t arm64v8/ubuntu:18.04 bash -c 'apt list --installed > /github/upstream_packages.arm64.txt'
    docker run --rm -v "${GITHUB_WORKSPACE}":/github -t arm32v7/ubuntu:18.04 bash -c 'apt list --installed > /github/upstream_packages.arm.txt'
    docker run --rm -v "${GITHUB_WORKSPACE}":/github -t   amd64/ubuntu:18.04 bash -c 'apt list --installed > /github/upstream_packages.amd64.txt'
fi
