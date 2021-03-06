#!/usr/bin/env bash

set -e

shopt -s globstar

import com.encodeering.ci.lang
import com.encodeering.ci.config

mkimageqemu "5.0.0"

chmod -Rv +x usr/**/bin/*

docker build -t "${REPOSITORY}/${PROJECT}:any" .
