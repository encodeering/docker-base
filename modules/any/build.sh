#!/usr/bin/env bash
# configuration
#   env.PROJECT

set -e

shopt -s globstar

import com.encodeering.docker.lang
import com.encodeering.docker.config

mkimageqemu

chmod -Rv +x usr/**/bin/*

docker build -t "$PROJECT:any" .
