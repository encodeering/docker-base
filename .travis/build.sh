#!/bin/bash

set -ev

shopt -s globstar

source ".travis/config/all.sh"   || true
source ".travis/config/$ARCH.sh" || true

BRANCH=${BRANCH##master}
BRANCH=${BRANCH:+-${BRANCH}}
TAG="$REPOSITORY/$PROJECT-$ARCH"
TAGSPECIFIER="$DISTRIBUTION$BRANCH"

mkdir -p mkimage
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage.sh" >mkimage.sh
curl "https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage/debootstrap" >mkimage/debootstrap
curl "https://anonscm.debian.org/git/pkg-qemu/qemu.git/plain/debian/qemu-debootstrap?h=debian-$DISTRIBUTION" >/usr/sbin/qemu-debootstrap
chmod -R u+x mkimage mkimage.sh /usr/sbin/qemu-debootstrap

patch -p0 --no-backup-if-mismatch < .patch/mkimage/rootfs.patch
patch -p0 --no-backup-if-mismatch < .patch/mkimage/docker.patch
patch -p0 --no-backup-if-mismatch < .patch/debootstrap/aptitude.patch
patch -p0 --no-backup-if-mismatch < .patch/debootstrap/source.patch

  mkimageqemu
./mkimage.sh -t "$PROJECT:$DISTRIBUTION" debootstrap --arch="$ARCH" --components=main,universe "$CONFIGURATION" "$DISTRIBUTION" "$MIRROR"

cat <<-EOF > "contrib/Dockerfile"
	FROM $PROJECT:$DISTRIBUTION
	COPY / /
EOF

chmod -Rv +x contrib/**/bin/*

docker build -t "$PROJECT:$DISTRIBUTION" contrib

docker tag "$PROJECT:$DISTRIBUTION" "$TAG:$TAGSPECIFIER"
docker run --rm                     "$TAG:$TAGSPECIFIER" cat /etc/debian_version

docker run --rm -e debug=true         "$TAG:$TAGSPECIFIER" docker-exec                             cat /etc/debian_version
docker run --rm -e eula-sample=accept "$TAG:$TAGSPECIFIER" docker-eula -k sample -u www.sample.org cat /etc/debian_version
