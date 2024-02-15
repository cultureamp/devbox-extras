bats_load_library bats-support
bats_load_library bats-assert

@test "direnv-integrated-to-fish" {
	run cat /root/.local/share/fish/vendor_conf.d/direnv.fish
	assert_output --partial "set -gx DIRENV_BIN"
	assert_output --partial "\$DIRENV_BIN hook fish | source"
	assert_output --partial "set -gx NIX_SSL_CERT_FILE "
}
