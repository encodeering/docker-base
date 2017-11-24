#!/bin/bash

set -ev

BRANCH=${BRANCH##master}
BRANCH=${BRANCH:+-${BRANCH}}
TAG="$REPOSITORY/$PROJECT-$ARCH"
TAGSPECIFIER="$DISTRIBUTION$BRANCH"

mkdir -p mkimage
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh" >mkimage.sh
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap" >mkimage/debootstrap
curl "https://anonscm.debian.org/git/pkg-qemu/qemu.git/plain/debian/qemu-debootstrap?h=debian-$DISTRIBUTION" >/usr/sbin/qemu-debootstrap
chmod -R u+x mkimage mkimage.sh /usr/sbin/qemu-debootstrap

patch -p0 --no-backup-if-mismatch < patch/mkimage/rootfs.patch
patch -p0 --no-backup-if-mismatch < patch/mkimage/docker.patch
patch -p0 --no-backup-if-mismatch < patch/debootstrap/aptitude.patch
patch -p0 --no-backup-if-mismatch < patch/debootstrap/source.patch

./mkimage.sh -t "$PROJECT:$DISTRIBUTION" debootstrap --arch="$ARCH" --components=main,universe "$CONFIGURATION" "$DISTRIBUTION" "$MIRROR"

docker export -o debian.tar.gz `docker create "$PROJECT:$DISTRIBUTION" sh`
docker export -o any.tar.gz    `docker create "$PROJECT:any"           sh`

docker build -t "$TAG:$TAGSPECIFIER" .

docker run --rm                     "$TAG:$TAGSPECIFIER" cat /etc/debian_version

docker run --rm -e debug=true         "$TAG:$TAGSPECIFIER" docker-exec                             cat /etc/debian_version
docker run --rm -e eula-sample=accept "$TAG:$TAGSPECIFIER" docker-eula -k sample -u www.sample.org cat /etc/debian_version
