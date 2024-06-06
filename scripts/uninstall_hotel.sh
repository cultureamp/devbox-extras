#!/bin/sh

set -e

# useful for testing the install script so we can start fresh
# probably not useful for someone trying to repair a broken system

launcher_path="/usr/local/bin/hotel"
hotel_state_dir="${XDG_DATA_DIR:-$HOME/.local/share}/hotel"
hotel_everything_dir="$HOME/hotel"
service_name="com.cultureamp.hotel"
account_name="github"

main() {
  if security find-generic-password -s "$service_name" -a "$account_name" >/dev/null 2>&1; then
    echo "==> removing saved github token"
    security delete-generic-password -s "$service_name" -a "$account_name" >/dev/null 2>&1 # remove if exists so write doesn't fail
  else
    echo "==> no saved github token (doing nothing)"
  fi

  if [ -d "$hotel_state_dir" ]; then
    echo "==> removing $hotel_state_dir"
    rm -rf "$hotel_state_dir"
  else
    echo "==> $hotel_state_dir does not exist (doing nothing)"
  fi

  if [ -d "$hotel_everything_dir" ]; then
    echo "==> removing $hotel_everything_dir"
    rm -rf "$hotel_everything_dir"
  else
    echo "==> $hotel_everything_dir does not exist (doing nothing)"
  fi

  if [ -f "$launcher_path" ]; then
    echo "==> removing launcher script (requires sudo)"
    sudo rm "$launcher_path"
  else
    echo "==> no launcher script to remove (doing nothing)"
  fi
}

main
