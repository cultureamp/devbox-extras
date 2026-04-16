#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "failed process logs are output with github actions group headers" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Error: One or more processes failed."* ]]
	[[ "$output" == *"this is a failure log message"* ]]

}
