#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "fails when not running in a devbox shell" {
	# Simulate not being in a devbox shell by unsetting devbox environment variables
	run \
		env -u DEVBOX_PROJECT_ROOT -u DEVBOX_PACKAGES_DIR -u DEVBOX_CONFIG_DIR \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Error: This script must be run inside a devbox shell."* ]]
	[[ "$output" != *"Command completed"* ]]

}
