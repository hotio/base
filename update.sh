#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    docker pull arm64v8/ubuntu:18.04
    docker pull arm32v7/ubuntu:18.04
    docker pull   amd64/ubuntu:18.04
    docker inspect --format='{{index .RepoDigests 0}}' arm64v8/ubuntu:18.04 >  upstream_digests.txt
    docker inspect --format='{{index .RepoDigests 0}}' arm32v7/ubuntu:18.04 >> upstream_digests.txt
    docker inspect --format='{{index .RepoDigests 0}}'   amd64/ubuntu:18.04 >> upstream_digests.txt
fi
