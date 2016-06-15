#!/usr/bin/env bash

QEMUBUILDPACK="$REPOSITORY/buildpack-amd64:jessie"
QEMUDIRECTORY="mkimage-qemu"
QEMUVERSION="v2.6.0"

mkimageqemu () {
    [ -z "$QEMU_TARGET" ] && return

    rm -rf   "$QEMUDIRECTORY"
    mkdir -p "$QEMUDIRECTORY"

    QEMU_NAME="qemu-${QEMU_TARGET%%-*}"
    QEMU_NAME_STATIC="$QEMU_NAME-static"

    cat <<-EOF > "$QEMUDIRECTORY/Dockerfile.qemu.static"
		FROM $QEMUBUILDPACK
		RUN apt-get update && apt-get -y install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev
		RUN git clone --depth 1 --branch "$QEMUVERSION" https://github.com/qemu/qemu.git /usr/src/qemu
		WORKDIR /usr/src/qemu
		RUN mkdir -p build
		WORKDIR      build
		RUN ../configure --static --target-list="$QEMU_TARGET"
EOF

    docker build -f   "$QEMUDIRECTORY/Dockerfile.qemu.static" -t qemu:static "$QEMUDIRECTORY"
    docker rm         "$QEMU_NAME" || true
    docker run --name "$QEMU_NAME" qemu:static make -j4
    docker cp         "$QEMU_NAME:/usr/src/qemu/build/$QEMU_TARGET/$QEMU_NAME" "/usr/bin/$QEMU_NAME_STATIC"

    strip -s "/usr/bin/$QEMU_NAME_STATIC"
}
