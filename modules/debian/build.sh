#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

# additional tag is required for the scan process. the debian image would be considered an alien if the newly generated image gets tagged with bullseye
docker-pull "debian:bullseye-slim" "debian:bullseye-slim" "${REPOSITORY}/debuerreotype:base"

mkdir -p           debuerreotype/output
(cd                debuerreotype && bash docker-run.sh --image "debuerreotype:latest" ./examples/debian.sh --arch "${ARCH}" output "${VERSION}" "2024-09-10T02:37:34Z" && docker rmi "debuerreotype:latest") # timestamp taken from http://snapshot.debian.org/archive/debian/?year=2024&month=9
rootfs="$(find     debuerreotype/output -iwholename "*${VARIANT}/rootfs.tar.xz" | sort | head -n1 | dup)"

docker-build . --build-arg rootfs="${rootfs}"

docker-verify cat /etc/os-release | dup | matches "Debian.*?${VERSION}"
