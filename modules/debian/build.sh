#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

# additional tag is required for the scan process. the debian image would be considered an alien if the newly generated image gets tagged with bullseye
docker-pull "${REPOSITORY}/debian-${ARCH}:bullseye" "debian:bullseye-slim" "${REPOSITORY}/debuerreotype:base"

docker-patch patch debuerreotype

mkdir -p           debuerreotype/output
(cd                debuerreotype && bash docker-run.sh --image "debuerreotype:latest" ./examples/debian.sh --arch "${ARCH}" output "${VERSION}" "1970-01-01T00:00:00Z" && docker rmi "debuerreotype:latest") # timestamp doesn't matter, see patch
rootfs="$(find     debuerreotype/output -iwholename "*${VARIANT}/rootfs.tar.xz" | sort | head -n1 | dup)"

docker-build . --build-arg rootfs="${rootfs}"

docker-verify cat /etc/os-release | dup | matches "Debian.*?${VERSION}"
