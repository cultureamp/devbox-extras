#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "process becomes healthy then exits with error" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Error: A process failed."* ]]
	[[ "$output" != *"Command completed"* ]]
}
