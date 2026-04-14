#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "quoted command argument should work" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		"echo Test completed successfully"

	[ $status -eq 0 ]
	[[ "$output" == *"Test completed successfully"* ]]
}

@test "unquoted command arguments should work" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		"echo Test completed successfully"

	[ $status -eq 0 ]
	[[ "$output" == *"Test completed successfully"* ]]
}
