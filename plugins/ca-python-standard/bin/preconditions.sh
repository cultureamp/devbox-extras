#!/bin/sh

if [ "$__IGNORE_PRECONDITIONS" = "1" ]; then
  exit 0
fi

if .devbox/nix/profile/default/bin/granted browser 2>&1 | grep -q "Granted is using \."; then
  >&2 echo 'ERROR: granted does not have a default browser set'
  >&2 echo 'run `__IGNORE_PRECONDITIONS=1 devbox run granted-set-browser` to continue`'
  exit 1
fi
