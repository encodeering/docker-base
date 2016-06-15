#!/usr/bin/env bash

set -ev

shopt -s globstar

chmod -Rv +x usr/**/bin/*

docker build -t "$PROJECT:any" .
