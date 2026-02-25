#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "with --service flag to start specific service and disable others" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		--service=good_process \
		echo "Command completed"

	[ $status -eq 0 ]
	[[ "$output" == *"Command completed"* ]]
}
