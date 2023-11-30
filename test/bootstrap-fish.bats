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

@test "direnv-integrated-to-fish" {
	run cat /root/.local/share/fish/vendor_conf.d/direnv.fish
	assert_output --partial "set -gx DIRENV_BIN"
	assert_output --partial "\$DIRENV_BIN hook fish | source"
	assert_output --partial "set -gx NIX_SSL_CERT_FILE="
}

@test "direnv-configured-to-nix" {
	run cat ~/.config/direnv/direnvrc
	assert_output "source \$HOME/.nix-profile/share/nix-direnv/direnvrc"
}

@test "nix-ssl-cert-set" {
	test -n $NIX_SSL_CERT_FILE
}
