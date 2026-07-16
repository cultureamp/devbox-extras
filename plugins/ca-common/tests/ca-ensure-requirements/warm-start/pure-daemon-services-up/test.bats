#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "pure daemon: warm-start is a no-op past confirming the graph is ready" {
	setup_services_already_up for-verify

	run ca-ensure-requirements --process-compose-file="$PCFILE" --process=for-verify

	assert_succeeded
	[[ "$output" == *"already running on port"* ]]
	run curl --silent --fail http://localhost:5055
	[ "$status" -eq 0 ]

	# Warm-start never arms the reaper; also this is daemon-mode.
	assert_pc_still_running
}
