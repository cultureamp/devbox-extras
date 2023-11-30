load "$DEVBOX_SHARE_DIR/bats/bats-support/load.bash"
load "$DEVBOX_SHARE_DIR/bats/bats-assert/load.bash"

@test "installed-nix" {
	run which nix
	test "$status" -eq 0
}

@test "installed-devbox" {
	run which devbox
	test "$status" -eq 0
}

@test "installed-direnv" {
	run which direnv
	test "$status" -eq 0
}

@test "direnv-configured-to-nix" {
	run cat ~/.config/direnv/direnvrc
	assert_output "source \$HOME/.nix-profile/share/nix-direnv/direnvrc"
}

@test "nix-ssl-cert-set" {
	test -n $NIX_SSL_CERT_FILE
}

@test "generated-netskope-cert" {
	run cat /tmp/test-metadata/security.txt
	assert_output "security ran with args: find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain /Library/Keychains/System.keychain"
}

@test "netskope-cert-in-dir" {
	run cat "/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
	# TODO: is this an appropriate test of "key exists"?
	test "$status" -eq 0
}

@test "user-added-to-admin-group" {
	run cat /tmp/test-metadata/dseditgroup.txt
	assert_output "dseditgroup ran with args: -o edit -a $(whoami) -t user admin"
}
