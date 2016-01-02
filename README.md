# Automatically created docker image for a Debian system

[![Build Status](https://travis-ci.org/encodeering/docker-debian.svg?branch=master)](https://travis-ci.org/encodeering/docker-debian)

## Docker

```docker pull encodeering/debian-armhf```

- jessie, latest, 8
- https://hub.docker.com/r/encodeering/debian-armhf/

## Modification

Uses a [variant](https://github.com/encodeering/armhf-debian-docker) of the build script of [djmaze](https://github.com/djmaze/armhf-debian-docker) and customizes the following parts.

- [Foot print reduction](https://wiki.ubuntu.com/ReducingDiskFootprint#Documentation)
- ENV LC_ALL C.UTF-8
- ENV DEBIAN_FRONTEND noninteractive
