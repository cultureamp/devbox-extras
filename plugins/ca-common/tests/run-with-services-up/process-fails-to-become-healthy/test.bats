#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "process fails to become healthy and eventually times out" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		--timeout=5 \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Timeout waiting for services to start after 5s"* ]]
	[[ "$output" != *"Command completed"* ]]

}
