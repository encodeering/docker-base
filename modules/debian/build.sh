#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

docker-pull "${REPOSITORY}/debian-${ARCH}:bullseye" "debian:bullseye-slim"

mkdir -p           debuerreotype/output
(cd                debuerreotype && bash docker-run.sh --image "debuerreotype:latest" ./examples/debian.sh --arch "${ARCH}" output "${VERSION}" "2022-03-01T21:24:08Z" && docker rmi "debuerreotype:latest") # timestamp doesn't matter, see patch
rootfs="$(find     debuerreotype/output -iwholename "*/rootfs.tar.xz" | sort | head -n1)"

docker-build . --build-arg rootfs="${rootfs}"

docker-verify cat /etc/os-release | dup | matches "Debian.*?${VERSION}"
