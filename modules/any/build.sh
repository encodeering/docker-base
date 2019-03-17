#!/usr/bin/env bash

set -e

shopt -s globstar

import com.encodeering.ci.lang
import com.encodeering.ci.config

mkimageqemu "2.6.0"

chmod -Rv +x usr/**/bin/*

docker build -t "${REPOSITORY}/${PROJECT}:any" .
