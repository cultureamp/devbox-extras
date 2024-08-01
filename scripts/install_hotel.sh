#!/usr/bin/env bash

set -e

hotel_bin_path="${XDG_DATA_DIR:-$HOME/.local/share}/hotel/bin"
hotel_tarball_name="hotel_$(uname)_$(uname -m).tar.gz"

receipt_log_dir="$HOME/hotel/receipts"
receipt_log_file="$receipt_log_dir/hotel-install-$(date -Iseconds).txt"
mkdir -p "$receipt_log_dir"

# this file does a log of echo-ing strings for use by calling function, logs
# intended for the user should always go to stderr - these functions makes it easier
log() {
  >&2 echo "$@"
  echo "$@" >>"$receipt_log_file"
}
logYellow() {
  >&2 printf "\033[33m" # yellow
  >&2 echo "$@"
  >&2 printf "\033[0m" # reset
  echo "$@" >>"$receipt_log_file"
}
logRed() {
  >&2 printf "\033[31m" # red
  >&2 echo "$@"
  >&2 printf "\033[0m" # reset
  echo "$@" >>"$receipt_log_file"
}

service_name="com.cultureamp.hotel"
account_name="github"
hotel_secrets_path="${XDG_DATA_DIR:-$HOME/.local/share}/hotel/secrets"

store_github_token() {
  new_password="$1"
  if [ "$(uname)" = "Darwin" ]; then
    # on macos use the built in secrets manager as this is usually real hardware
    if security find-generic-password -s "$service_name" -a "$account_name" >/dev/null 2>&1; then
      security delete-generic-password -s "$service_name" -a "$account_name" >/dev/null 2>&1 # remove if exists so write doesn't fail
    fi
    security add-generic-password -s "$service_name" -a "$account_name" -w "$new_password"
  else
    # other OSs may or may not have a keyring, are likely a container or VM so secrets handling is less of a concern
    # also it's difficult to setup a keyring in a linux container (https://unix.stackexchange.com/a/548005)
    mkdir -p "$hotel_secrets_path"
    echo "$new_password" >"$hotel_secrets_path/$account_name"
  fi
}

get_and_store_github_key() {
  if [ -n "$HOTEL_INSTALLER_GITHUB_TOKEN" ]; then
    # github_token can be provided as env var (used in scripts to avoid prompt)
    github_token="$HOTEL_INSTALLER_GITHUB_TOKEN"
  else
    log ""
    log "We need a github key to download hotel, and for hotel to use to pull git repos"
    log "It will be stored in the system keychain"
    log ""
    log "You can generate a token here:"
    log "    https://github.com/settings/tokens/new?scopes=repo "
    log ""
    logYellow "The token MUST have CultureAmp SSO configured or this script WILL FAIL"
    log ""
    # no token found, ask user
    read -s -r -p "Github token: " github_token
  fi

  store_github_token "$github_token"
  echo "$github_token"
}

download_latest_hotel() {
  github_token="$1"
  if [ -z "$github_token" ]; then
    log "github_token missing"
    exit 1
  fi

  releases_file="$(mktemp)"
  # set the output flag to write reponse to json and write out flag to write response code to stdout
  # this allows us to get them separately from one request without having to parse anything
  response_code="$(
    curl -sL https://api.github.com/repos/cultureamp/hotel/releases/latest \
      --user "_:$github_token" \
      --output "$releases_file" \
      --write-out "%{http_code}" \
      --header "Accept: application/json"
  )"
  if [ "$response_code" != "200" ]; then
    log ""
    logRed "Could not get latest hotel release from github. This is likely because your github token is invalid."
    log ""
    log "Ensure you have enabled SSO on the token, and entered it correctly"
    exit 1
  fi
  releases_json="$(cat "$releases_file")"
  rm "$releases_file"

  # we can't get the specific release we want without a json parsing tool, so we get all
  # download links and download until we find the one matching the system's arch and os
  release_asset_urls=$(echo "$releases_json" |
    grep '"url": ".*/releases/assets/.*"' |
    cut -d\" -f4)

  for url in $release_asset_urls; do
    # the only way to get a release's file name is to download it and write-out the filename
    downloaded_file=$(
      curl -sL "$url" \
        --user "_:$github_token" \
        --remote-header-name --remote-name \
        --write-out "%{filename_effective}" \
        --header "Accept: application/octet-stream"
    )
    if [ "$downloaded_file" = "$hotel_tarball_name" ]; then
      tar -xzf "$downloaded_file"
      return
    else
      rm "$downloaded_file"
    fi
  done
}

install_hotel() {
  log "=> downloading hotel binary..."
  INITIAL_DIR="$PWD"
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  download_latest_hotel "$1"
  mkdir -p "$hotel_bin_path/"
  mv hotel "$hotel_bin_path"
  cd "$INITIAL_DIR"
  rm -rf "$TMPDIR"
  log "=> installing hotel, this will ask for a sudo password"
  sudo "$hotel_bin_path/hotel" setup launcher
}

main() {
  github_token=$(get_and_store_github_key)
  install_hotel "$github_token"
}

main
