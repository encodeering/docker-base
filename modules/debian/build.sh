#!/usr/bin/env bash

set -e

import com.encodeering.ci.lang
import com.encodeering.ci.config
import com.encodeering.ci.docker

mkdir -p rootfs/mkimage
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh" >rootfs/mkimage.sh
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap" >rootfs/mkimage/debootstrap
curl "https://anonscm.debian.org/git/pkg-qemu/qemu.git/plain/debian/qemu-debootstrap?h=debian-${VERSION}" >/usr/sbin/qemu-debootstrap
chmod -R u+x rootfs /usr/sbin/qemu-debootstrap

patch -p1 --no-backup-if-mismatch --directory=rootfs < patch/mkimage-rootfs.patch
patch -p1 --no-backup-if-mismatch --directory=rootfs < patch/mkimage-docker.patch
patch -p1 --no-backup-if-mismatch --directory=rootfs < patch/mkimage/debootstrap-aptitude.patch
patch -p1 --no-backup-if-mismatch --directory=rootfs < patch/mkimage/debootstrap-source.patch

(cd rootfs && ./mkimage.sh -t "${PROJECT}:${VERSION}" debootstrap --arch="${ARCH}" --components=main,universe --variant=minbase "${VERSION}" http://ftp.us.debian.org/debian/)

docker export -o ./rootfs/rootfs.tar.gz `docker create "${PROJECT}:${VERSION}" sh`
docker export -o ./rootfs/any.tar.gz    `docker create "${PROJECT}:any"        sh`

docker-build .

docker-verify                                         cat /etc/debian_version

docker-verify-config "-e debug=true"
docker-verify docker-exec                             cat /etc/debian_version

docker-verify-config "-e eula-sample=accept"
docker-verify docker-eula -k sample -u www.sample.org cat /etc/debian_version
