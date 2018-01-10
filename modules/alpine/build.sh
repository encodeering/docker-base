#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-alpine.sh" >mkimage-alpine.sh
chmod -R u+x mkimage-alpine.sh

patch -p0 --no-backup-if-mismatch < patch/mkimage/alpine.patch

case "${ARCH}" in
    amd64) ./mkimage-alpine.sh -r "v${VERSION}" -a x86_64    -s 1 ;;
    *    ) ./mkimage-alpine.sh -r "v${VERSION}" -a "${ARCH}" -s 1 ;;
esac

docker export -o any.tar.gz `docker create "${PROJECT}:any" sh`

docker-build .

docker-verify                                         cat /etc/alpine-release

docker-verify-config "-e debug=true"
docker-verify docker-exec                             cat /etc/alpine-release

docker-verify-config "-e eula-sample=accept"
docker-verify docker-eula -k sample -u www.sample.org cat /etc/alpine-release
