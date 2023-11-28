load "$DEVBOX_SHARE_DIR/bats/bats-support/load.bash"
load "$DEVBOX_SHARE_DIR/bats/bats-assert/load.bash"

@test "hello-world" {
	run echo "Hello, world!"
	test "$status" -eq 0 
	assert_output "Hello, world!"
}
