#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

mkdir -p rootfs/mkimage
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh" >rootfs/mkimage.sh
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap" >rootfs/mkimage/debootstrap
curl "https://salsa.debian.org/qemu-team/qemu/raw/debian-unstable/debian/qemu-debootstrap" >/usr/sbin/qemu-debootstrap
chmod -R u+x rootfs /usr/sbin/qemu-debootstrap

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
