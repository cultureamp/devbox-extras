#! /bin/sh

set -e

# Script to install `nix`, `devbox`, `direnv`, and `nix-direnv` and get them all working together

NETSKOPE_DATA_DIR="/Library/Application Support/Netskope/STAgent/data"

# This variable is set by docker in mock_functions.sh to provide the linux path rather than the typical MacOS path
NIX_FINAL_SSL_FILE="${NIX_FINAL_SSL_FILE:-$NETSKOPE_DATA_DIR/nscacert_combined.pem}"

verify_setup_conditions() {
	if ! test -d "/Library/Application Support/Netskope";then
		echo "=== It appears as if Netskope is not installed on your machine, please make a post in the community_devbox channel in slack"
		exit 1		
	fi
	if command -v nix > /dev/null && ! test -e /nix/nix-installer; then
		echo "=== It appears as if your nix was not installed with our preferred installer, please make a post in the community_devbox channel in slack"
		exit 1
	fi
}

# Copy create Netskope combined cert and save to known location recommended by their docs:
# https://docs.netskope.com/en/netskope-help/data-security/netskope-secure-web-gateway/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception/#mac-1
generate_combined_netskope_cert() {
	echo "=== generating combined CA certificate from system keychain..."
	if [ "$TMPDIR" = "" ]; then
		TMPDIR=$(getconf DARWIN_USER_TEMP_DIR)
	fi

	security find-certificate -a -p \
		/System/Library/Keychains/SystemRootCertificates.keychain \
		/Library/Keychains/System.keychain \
		>"$TMPDIR/nscacert_combined.pem"
	echo "=== combined CA certificate generated"

	if test -f "$NETSKOPE_DATA_DIR"/nscacert_combined.pem ; then
		if diff -q "$NETSKOPE_DATA_DIR"/nscacert_combined.pem "$TMPDIR/nscacert_combined.pem";then 
			echo "=== Netskope Cert is already placed, doing nothing"
		else
		CERT_NOT_MATCHING=1
		fi
	else
	 CERT_NOT_MATCHING=1
	fi

	if [ -n "$CERT_NOT_MATCHING" ]; then
		echo "=== moving combined CA certificate to Netskope data folder (requires sudo)..."
		sudo mkdir -p "$NETSKOPE_DATA_DIR"
		sudo cp "$TMPDIR/nscacert_combined.pem" "$NETSKOPE_DATA_DIR"
		echo "=== moved combined CA certificate"
	fi


}

# Install nix using the determinate systems installer because it has good defaults and an uninstall script
# Also set current user as a trusted user so they can add substituters/caches
# And set the ssl cert file globally
install_nix() {

	# TODO: Check a suitable nix is installed, what are the reqs?
	# Reqs:
	# - root and admin are trusted users
	# - nix has the ssl file which points to $NIX_FINAL_SSL_FILE

	# NOTE: https://github.com/juspay/nix-browser/tree/main/crates/nix_health
	# Could be useful

	# TODO: Check nix-installer path exists
	# TODO: Check self-test returns 0
	if command -v /nix/nix-installer > /dev/null && /nix/nix-installer self-test > /dev/null 2>&1; then
		echo "=== nix is already installed, doing nothing"
	else
	echo "=== installing nix (requires sudo)..."
	# # shellcheck disable=SC2086
	# curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
	# 	# $INSTALLER_EXTRA_ARGS below is required by docker as default install expects systemd for a linux install
	# 	# That alone is able to be set by an env var in the docker environment,
	# 	# however we also have to provide 'linux' as an argument for the installing script
	# 	sh -s -- install $INSTALLER_EXTRA_ARGS --no-confirm \
	# 		--extra-conf "trusted-users = root @admin" \
	# 		--ssl-cert-file "$NIX_FINAL_SSL_FILE"
	# echo "=== nix installed..."
	fi


	# TODO: Check nix daemon sourced
	# echo "=== sourcing nix daemon so we can use it in this script..."
	# export NIX_SSL_CERT_FILE="$NIX_FINAL_SSL_FILE"
	# # shellcheck source=/dev/null
	# . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	# echo "=== nix daemon sourced..."
}

install_devbox() {
	if command -v devbox version >/dev/null 2>&1; then
		echo "=== devbox is already installed, doing nothing"
	else
		echo "=== installing devbox..."
		curl -fsSL https://get.jetpack.io/devbox | FORCE=1 bash
		echo "=== devbox installed..."
	fi
}

add_current_user_to_admin_group() {
	if id -Gn "$USER" | grep -q -w admin;
	then
		echo "=== user is already added to admin group, doing nothing"
	else
	echo "=== add current user to admin group"
	sudo dseditgroup -o edit -a "$(whoami)" -t user admin
	fi
}

install_direnv() {
	if command -v direnv >/dev/null 2>&1; then
		echo "=== direnv is already installed, doing nothing"
		DIDNT_INSTALL_DIRENV=1
	else
		echo "=== direnv is not installed, installing..."
		nix profile install nixpkgs#direnv
		echo "=== direnv installed"
	fi
}

shell_integrations() {
	# TODO: Based on shell, test inclusion of shell integration in rc file

	DIRENV_BIN="$(command -v direnv)"
	DIRENV_BIN="${DIRENV_BIN:-$HOME/.nix-profile/bin/direnv}"
	shell=$(basename "$SHELL")
	case "$shell" in
	*bash*)
		rcfile="$HOME/.bashrc"
		printf "\n" >>"$rcfile"
		cat <<-EOF >>"$rcfile"
			### Do not edit. This was autogenerated by 'bootstrap.sh' ###
			export DIRENV_BIN="$DIRENV_BIN"
			eval "\$(\$DIRENV_BIN hook bash)"
			export NIX_SSL_CERT_FILE='$NETSKOPE_DATA_DIR/nscacert_combined.pem'
		EOF
		;;
	*zsh*)
		rcfile="${ZDOTDIR:-$HOME}/.zshrc"
		printf "\n" >>"$rcfile"
		cat <<-EOF >>"$rcfile"
			### Do not edit. This was autogenerated by 'bootstrap.sh' ###
			export DIRENV_BIN="$DIRENV_BIN"
			eval "\$(\$DIRENV_BIN hook zsh)"
			export NIX_SSL_CERT_FILE='$NETSKOPE_DATA_DIR/nscacert_combined.pem'
		EOF
		;;
	*fish*)
		rcfile="${XDG_DATA_HOME:-$HOME/.local/share}/fish/vendor_conf.d/direnv.fish"

		# TODO: Currently grep requires partial match, need to enforce perfect match
		integration_string="### Do not edit. This was autogenerated by 'bootstrap.sh' ###
set -gx DIRENV_BIN $DIRENV_BIN
\$DIRENV_BIN hook fish | source
set -gx NIX_SSL_CERT_FILE '$NETSKOPE_DATA_DIR/nscacert_combined.pem'"

		# Test for all four strings seperately
		# Otherwise, try grep -z
		# if awk '/### Do not/,/set -gx NIX_SSL_CERT_FILE/' "$rcfile" 2>/dev/null | grep -q .; then
		if grep -zq "$integration_string" "$rcfile"; then
			echo "=== fish shell integration already exists, doing nothing"
		else
			# NOTE: any file here can be overwritten
			echo "NAUGHTY PATH"
			# mkdir -p "$(dirname "$rcfile")"
			# printf "\n" >>"$rcfile"
			# cat <<-EOF >>"$rcfile"
			# 	$integration_string
			# EOF
		fi
			;;
	*)
		echo "Don't know how to setup for shell $SHELL. checkout https://direnv.net/docs/hook.html"
		;;
	esac
}

install_nix_direnv() {
	# This is giving a broken pipe error ¯\_(ツ)_/¯
	if nix profile list | grep -q -w nix-direnv; then
		echo "=== nix-direnv already installed, doing nothing"
	else
		echo "=== installing nix-direnv..."
		nix profile install nixpkgs#nix-direnv
		echo "=== nix-direnv installed"

		if [ ! -e "$HOME/.config/direnv/direnvrc" ]; then
			echo "=== direnvrc doesn't exist, creating it with config"
			mkdir -p "$HOME/.config/direnv"
			echo "source \$HOME/.nix-profile/share/nix-direnv/direnvrc" >"$HOME/.config/direnv/direnvrc"
		else
			if grep -q "^source.*\/nix-direnv\/direnvrc$" "$HOME/.config/direnv/direnvrc"; then
				echo "=== direnvrc exists and is configured to use nix-direnv, doing nothing"
			else
				echo "=== direnvrc exists but is not configured to use nix-direnv, updating..."
				echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" >>"$HOME/.config/direnv/direnvrc"
				echo "=== direnvrc updated to use nix-direnv"
			fi
		fi
	fi
}

print_further_steps() {
	echo "================================================================"
	echo "Nix, direnv, and devbox have been installed and setup"

	if [ "$DIDNT_INSTALL_DIRENV"  ]; then
		echo "You had direnv already installed, if you've already configured it you can skip the last step"
	fi

	echo "direnv setup will only be activated if you start a new shell session (e.g. open a new tab on your terminal)"
	echo "================================================================"

	echo ""
	echo "If you've had any issues with this install process please reach out to #team_delivery_eng on slack"
}

main() {
	verify_setup_conditions
	add_current_user_to_admin_group
	generate_combined_netskope_cert
	install_nix
	install_devbox
	install_direnv
	shell_integrations
	install_nix_direnv
	print_further_steps
}

main
