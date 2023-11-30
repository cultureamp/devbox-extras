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

@test "direnv-integrated-to-zsh" {
	run cat ~/.zshrc
	assert_output --partial "export DIRENV_BIN="
	assert_output --partial "eval \"\$(\$DIRENV_BIN hook zsh)\""
	assert_output --partial "export NIX_SSL_CERT_FILE="
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
