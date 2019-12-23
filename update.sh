#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    image="amd64/ubuntu:18.04"   && docker pull ${image} && digest=$(docker inspect --format='{{index .RepoDigests 0}}' ${image}) && sed -i "s/FROM .*$/FROM ${digest}/g" ./linux-amd64.Dockerfile
    image="arm32v7/ubuntu:18.04" && docker pull ${image} && digest=$(docker inspect --format='{{index .RepoDigests 0}}' ${image}) && sed -i "s/FROM .*$/FROM ${digest}/g" ./linux-arm.Dockerfile
    image="arm64v8/ubuntu:18.04" && docker pull ${image} && digest=$(docker inspect --format='{{index .RepoDigests 0}}' ${image}) && sed -i "s/FROM .*$/FROM ${digest}/g" ./linux-arm64.Dockerfile
fi
