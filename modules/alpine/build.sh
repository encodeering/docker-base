#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

mkdir -p rootfs
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-alpine.sh" >rootfs/mkimage-alpine.sh
chmod -R u+x rootfs

docker-patch patch rootfs

case "${ARCH}" in
    amd64) (cd rootfs && ./mkimage-alpine.sh -r "v${VERSION}" -a x86_64    -s 1) ;;
    *    ) (cd rootfs && ./mkimage-alpine.sh -r "v${VERSION}" -a "${ARCH}" -s 1) ;;
esac

docker export -o ./rootfs/any.tar.gz `docker create "${REPOSITORY}/${PROJECT}:any" sh`

docker-build .

docker-verify                                         cat /etc/alpine-release | dup | matches "^${VERSION}"

docker-verify-config "-e debug=true"
docker-verify docker-exec                             cat /etc/alpine-release

docker-verify-config "-e eula-sample=accept"
docker-verify docker-eula -k sample -u www.sample.org cat /etc/alpine-release
