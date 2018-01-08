#!/usr/bin/env bash

set -e

import com.encodeering.docker.lang
import com.encodeering.docker.config
import com.encodeering.docker.docker

curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-alpine.sh" >mkimage-alpine.sh
chmod -R u+x mkimage-alpine.sh

patch -p0 --no-backup-if-mismatch < patch/mkimage/alpine.patch

case "${ARCH}" in
    amd64) ./mkimage-alpine.sh -r "v${VERSION}" -a x86_64    -s 1 ;;
    *    ) ./mkimage-alpine.sh -r "v${VERSION}" -a "${ARCH}" -s 1 ;;
esac

docker export -o any.tar.gz `docker create "${PROJECT}:any" sh`

docker build -t "${DOCKER_IMAGE}" .

docker run --rm                       "${DOCKER_IMAGE}" cat /etc/alpine-release
docker run --rm -e debug=true         "${DOCKER_IMAGE}" docker-exec                             cat /etc/alpine-release
docker run --rm -e eula-sample=accept "${DOCKER_IMAGE}" docker-eula -k sample -u www.sample.org cat /etc/alpine-release
