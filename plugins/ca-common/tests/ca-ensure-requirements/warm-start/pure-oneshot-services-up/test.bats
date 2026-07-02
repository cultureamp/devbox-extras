#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "pure one-shot: warm-start is a no-op past confirming the graph is satisfied" {
	setup_services_already_up for-verify

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify

	assert_succeeded
	[[ "$output" == *"already running on port"* ]]
	[ -f "$MARKER_DIR/oneshot.ran" ]

	# Warm-start never arms the reaper, so PC stays exactly as we found it.
	assert_pc_still_running
}
