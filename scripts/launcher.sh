#!/bin/sh

# this file is intended to be placed in /usr/local/bin and not change very often, as
# updating this it in this location will require sudo
#
# the purpose of this script is to allow the hotel binary to update itself without sudo

set -e

HOTEL_LAUNCHER_VERSION="1"

hotel_bin="${XDG_DATA_DIR:-$HOME/.local/share}/hotel/bin/hotel"

if [ -x "$hotel_bin" ]; then
  HOTEL_LAUNCHER_VERSION=$HOTEL_LAUNCHER_VERSION "$hotel_bin" "$@"
else
  echo
  echo "The hotel binary does not exist or is not executable"
  echo
  echo "To [re]install follow the LDE setup instructions here"
  echo "    https://cultureamp.atlassian.net/wiki/spaces/DE/pages/3342434338"
  echo
  echo "If you continue to have problems reach out in slack"
  echo "    https://cultureamp.slack.com/archives/C05RYPQ62KE"
  echo
fi
