#!/bin/sh

# this script should be run directly (not via devbox run) so that
# we can set the env var to disable the init_hook

export __IGNORE_PRECONDITIONS=1 
.devbox/nix/profile/default/bin/granted browser set
