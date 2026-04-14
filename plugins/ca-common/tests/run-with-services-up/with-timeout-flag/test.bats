#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "with --timeout flag" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		--timeout=1 \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Timeout waiting for services to start after 1s"* ]]
	[[ "$output" != *"Command completed"* ]]
}
