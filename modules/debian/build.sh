#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

mkdir -p                                                                                         rootfs/mkimage
curl -sSL "https://raw.githubusercontent.com/docker/docker/72c21a7/contrib/mkimage.sh"          >rootfs/mkimage.sh
curl -sSL "https://raw.githubusercontent.com/docker/docker/72c21a7/contrib/mkimage/debootstrap" >rootfs/mkimage/debootstrap
chmod -R u+x                                                                                     rootfs

docker-patch patch rootfs

(cd rootfs && ./mkimage.sh -t "${REPOSITORY}/${PROJECT}:${VERSION}" debootstrap --arch="${ARCH}" --components=main,universe --variant=minbase "${VERSION}" http://ftp.us.debian.org/debian/)

docker export -o ./rootfs/rootfs.tar.gz `docker create "${REPOSITORY}/${PROJECT}:${VERSION}" sh`
docker export -o ./rootfs/any.tar.gz    `docker create "${REPOSITORY}/${PROJECT}:any"        sh`

docker-build .

docker-verify                                         cat /etc/os-release | dup | contains "(${VERSION})"

docker-verify-config "-e debug=true"
docker-verify docker-exec                             cat /etc/os-release

docker-verify-config "-e eula-sample=accept"
docker-verify docker-eula -k sample -u www.sample.org cat /etc/os-release
