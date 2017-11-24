#!/usr/bin/env bash

set -ev

shopt -s globstar

source "config/all.source"   || true
source "config/$ARCH.source" || true

mkimageqemu

chmod -Rv +x usr/**/bin/*

docker build -t "$PROJECT:any" .
