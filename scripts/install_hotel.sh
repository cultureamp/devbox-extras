#! /bin/sh

set -e

hotel_bin_path="${XDG_DATA_DIR:-$HOME/.local/share}/hotel/bin/hotel"
hotel_tarball_name="hotel_$(uname)_$(uname -m).tar.gz"

# {{{ secrets
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

retrieve_github_token() {
  if [ "$(uname)" = "Darwin" ]; then
    security find-generic-password -s "$service_name" -a "$account_name" 2>/dev/null
    return $?
  else
    if [ -f "$hotel_secrets_path/$account_name" ]; then
      cat "$hotel_secrets_path/$account_name"
    else
      return 1
    fi
  fi
}

is_github_token_valid() {
  scopes=$(curl -sLI -u "_:$1" "https://api.github.com/user" |
    grep '^x-oauth-scopes: ' |
    sed 's/^x-oauth-scopes: //')
  if [ "$scopes" = "" ]; then
    echo "token not valid"
    return 1
  fi
  if ! echo "$scopes" | grep "repo" >/dev/null 2>&1; then
    echo "token does not have the 'repo' scope"
    return 1
  fi
}
# }}}

get_and_store_github_key() {
  existing_token=$(retrieve_github_token)
  find_token_result=$?
  if [ $find_token_result -eq 0 ] && is_github_token_valid "$existing_token"; then
    # if token exists and is valid we can successfully exit this function
    echo "$existing_token"
    return 0
  fi
  echo
  echo "we need a github key to download hotel, and for hotel to use to pull git repos, it will be stored in the system keychain"
  echo "you can get this from:"
  echo "    https://github.com/settings/tokens/new?scopes=repo "
  echo
  # no token found, ask user
  stty -echo
  printf "Github token: "
  read -r PASSWORD
  stty echo
  if ! is_github_token_valid "$PASSWORD"; then
    echo "=> provided token not valid"
    exit 1
  fi
  echo "=> provided token okay"
  store_github_token "$PASSWORD"
  echo "$PASSWORD"
}

install_launcher() {
  TMPDIR=$(mktemp -d)
  launcher_url="https://raw.githubusercontent.com/cultureamp/devbox-extras/new-bootstrap/scripts/launcher.sh" # FIXME point to main branch before merging
  curl "$launcher_url" >"$TMPDIR/hotel"
  chmod +x "$TMPDIR/hotel"
  echo "==installing hotel, this will require a sudo password=="
  sudo mv "$TMPDIR/hotel" "/usr/local/bin/"
}

download_latest_hotel() {
  github_token="$1"
  if [ -z "$github_token" ]; then
    echo "github_token missing"
    exit 1
  fi

  # we can't get the specific release we want without a json parsing tool, so we get all
  # download links and download until we find the one matching the system's arch and os
  release_asset_urls=$(curl -sL -u "_:$github_token" https://api.github.com/repos/cultureamp/hotel/releases/latest |
    grep '"url": ".*/releases/assets/.*"' |
    cut -d\" -f4)

  for url in $release_asset_urls; do
    # the only way to get a release's file name is to download it and write-out the filename
    downloaded_file=$(curl -sL "$url" \
      -u "_:$github_token" \
      --remote-header-name --remote-name \
      --write-out "%{filename_effective}" \
      --header "Accept: application/octet-stream")

    if [ "$downloaded_file" = "$hotel_tarball_name" ]; then
      tar -xzf "$downloaded_file"
      return
    else
      rm "$downloaded_file"
    fi
  done
}

install_hotel() {
  INITIAL_DIR="$PWD"
  TMPDIR=$(mktemp -d)
  download_latest_hotel "$1"
  mv hotel "$hotel_bin_path"
  cd "$INITIAL_DIR"
  rm -rf "$TMPDIR"
}

main() {
  github_token=$(get_and_store_github_key)
  install_launcher
  install_hotel "$github_token"
}

main
