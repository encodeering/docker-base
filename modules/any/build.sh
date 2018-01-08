#!/usr/bin/env bash

set -e

shopt -s globstar

import com.encodeering.docker.lang
import com.encodeering.docker.config

mkimageqemu "2.6.0"

chmod -Rv +x usr/**/bin/*

docker build -t "$PROJECT:any" .
