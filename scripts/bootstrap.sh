#! /bin/sh

# Script to install Nix/Devbox/Direnv
#
#
export DEVBOX_USE_VERSION="0.7.1"

export NIX_SSL_CERT_FILE="$HOME/.local/state/system-certs.pem"

save_netskope_cert() {
	if [ ! -e "$NIX_SSL_CERT_FILE" ]; then
		mkdir -p ~/.local/state/
		security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain /Library/Keychains/System.keychain >"$NIX_SSL_CERT_FILE"
	fi
}

install_nix() {
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --extra-conf "trusted-users = root $(whoami)" --ssl-cert-file "$NIX_SSL_CERT_FILE"

}

install_devbox() {
	curl -fsSL https://get.jetpack.io/devbox | FORCE=1 bash
}

install_direnv() {
	curl -fsSL https://get.jetpack.io/devbox | bin_path=/usr/local/bin bash
}

main() {

	save_netskope_cert
	install_nix
	install_devbox
	install_direnv

}

main
