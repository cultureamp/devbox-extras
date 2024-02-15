bats_load_library bats-support
bats_load_library bats-assert

@test "direnv-integrated-to-zsh" {
	run cat ~/.zshrc
	assert_output --partial "export DIRENV_BIN="
	assert_output --partial "eval \"\$(\$DIRENV_BIN hook zsh)\""
	assert_output --partial "export NIX_SSL_CERT_FILE="
}
