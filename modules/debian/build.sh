#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

#pull an official image the first time due to debuerreotype's internal requirements
#docker-pull "${REPOSITORY}/debian-${ARCH}:bullseye" "debian:bullseye-slim"

docker-patch patch debuerreotype

mkdir -p           debuerreotype/output
(cd                debuerreotype && bash docker-run.sh --image "debuerreotype:latest" ./examples/debian.sh --arch "${ARCH}" output "${VERSION}" "1970-01-01T00:00:00Z" && docker rmi "debuerreotype:latest") # timestamp doesn't matter, see patch
rootfs="$(find     debuerreotype/output -iwholename "*/rootfs.tar.xz" | sort | head -n1)"

docker-build . --build-arg rootfs="${rootfs}"

docker-verify cat /etc/os-release | dup | matches "Debian.*?${VERSION}"

#remove the official image
docker rmi debian:bullseye-slim
