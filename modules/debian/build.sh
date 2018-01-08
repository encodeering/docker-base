#!/usr/bin/env bash

set -e

import com.encodeering.docker.lang
import com.encodeering.docker.config
import com.encodeering.docker.docker

mkdir -p mkimage
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh" >mkimage.sh
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap" >mkimage/debootstrap
curl "https://anonscm.debian.org/git/pkg-qemu/qemu.git/plain/debian/qemu-debootstrap?h=debian-${VERSION}" >/usr/sbin/qemu-debootstrap
chmod -R u+x mkimage mkimage.sh /usr/sbin/qemu-debootstrap

patch -p0 --no-backup-if-mismatch < patch/mkimage/rootfs.patch
patch -p0 --no-backup-if-mismatch < patch/mkimage/docker.patch
patch -p0 --no-backup-if-mismatch < patch/debootstrap/aptitude.patch
patch -p0 --no-backup-if-mismatch < patch/debootstrap/source.patch

./mkimage.sh -t "${PROJECT}:${VERSION}" debootstrap --arch="${ARCH}" --components=main,universe --variant=minbase "${VERSION}" http://ftp.us.debian.org/debian/

docker export -o rootfs.tar.gz `docker create "${PROJECT}:${VERSION}" sh`
docker export -o any.tar.gz    `docker create "${PROJECT}:any"        sh`

docker build -t "${DOCKER_IMAGE}" .

docker run --rm                       "${DOCKER_IMAGE}" cat /etc/debian_version
docker run --rm -e debug=true         "${DOCKER_IMAGE}" docker-exec                             cat /etc/debian_version
docker run --rm -e eula-sample=accept "${DOCKER_IMAGE}" docker-eula -k sample -u www.sample.org cat /etc/debian_version
