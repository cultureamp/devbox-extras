#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "a process fails to start" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Error: A process failed."* ]]
	[[ "$output" != *"Command completed"* ]]
}
