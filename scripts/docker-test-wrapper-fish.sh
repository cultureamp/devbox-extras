#!/bin/sh

export SHELL="/bin/fish"
# REVIEW: how does this compare to installing fish in the container?
# NOTE: I was using the below, but was having issues, will a static path suffice?
# mkdir -p $XDG_DATA_HOME/fish/vendor_conf.d
mkdir -p /root/.local/share/fish/vendor_conf.d
. ./scripts/docker-test-wrapper-agnostic.sh
