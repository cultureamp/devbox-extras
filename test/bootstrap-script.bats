load "$DEVBOX_SHARE_DIR/bats/bats-support/load.bash"
load "$DEVBOX_SHARE_DIR/bats/bats-assert/load.bash"

@test "hello-world" {
	run echo "Hello, world!"
	test "$status" -eq 0 
	assert_output "Hello, world!"
}

@test "installed-nix" {
	run which nix
	test "$status" -eq 0
	assert_output "/nix/var/nix/profiles/default/bin/nix"
}

@test "installed-devbox" {
	run which devbox
	test "$status" -eq 0
	assert_output "/usr/local/bin/devbox"
}

@test "installed-direnv" {
	run which direnv
	test "$status" -eq 0
	assert_output --partial "/.nix-profile/bin/direnv"
}

@test "direnv-integrated-to-zsh" {
	run cat ~/.zshrc
	# QUESTION what is the best way to test this string?
	# NOTE: I am ignoring any cert file path in the final export
	assert_output --partial "export DIRENV_BIN=\"$DIRENV_BIN\""
	assert_output --partial "eval \"\$(\$DIRENV_BIN hook zsh)\""
	assert_output --partial "export NIX_SSL_CERT_FILE="
}

# TODO: rename test
@test "direnv-configured-" {
	run cat ~/.config/direnv/direnvrc
	assert_output "source \$HOME/.nix-profile/share/nix-direnv/direnvrc"
}

#TODO: shorten name
@test "nix-ssl-cert-env-var-set" {
	test -n $NIX_SSL_CERT_FILE
}
