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
	echo >&2 "$@"
	echo "$@" >>"$receipt_log_file"
}
logRed() {
	printf >&2 "\033[31m" # red
	echo >&2 "$@"
	printf >&2 "\033[0m" # reset
	echo "$@" >>"$receipt_log_file"
}

download_latest_hotel() {
	if [ -z "$github_token" ]; then
		log ""
		logRed "Github token not found. Please ensure it is correctly set."
		log ""
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
	download_latest_hotel
	mkdir -p "$hotel_bin_path/"
	mv hotel "$hotel_bin_path"
	cd "$INITIAL_DIR"
	rm -rf "$TMPDIR"
	if [ "$using_pat" = "true" ]; then
		mkdir -p ~/.config/hotel
		touch ~/.config/hotel/config.yaml
		echo "github.token: $github_token" >>~/.config/hotel/config.yaml
	fi
	log "=> installing hotel, this will ask for a sudo password"
	"$hotel_bin_path/hotel" setup launcher
}

main() {
	if [ -n "$1" ]; then
		github_token="$1"
		using_pat="true"
	else
		github_token="$(security find-generic-password -s "com.cultureamp.hotel" -a github.app -w)"
	fi

	install_hotel
}

main "$@"
