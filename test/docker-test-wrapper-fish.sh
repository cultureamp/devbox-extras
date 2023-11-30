#!/bin/sh

mkdir -p /root/.local/share/fish/vendor_conf.d
export SHELL="/bin/fish"
. ./test/docker-test-wrapper-agnostic.sh
