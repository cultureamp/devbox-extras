#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "one-shots all finish but one errors: the run fails before the command" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Error: One or more processes failed."* ]]
	[[ "$output" != *"Command completed"* ]]
}
