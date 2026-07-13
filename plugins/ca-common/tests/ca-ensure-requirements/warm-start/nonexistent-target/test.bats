#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "warm-start with an unknown target exits non-zero and leaves process-compose running" {
	setup_unrelated_daemon_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" no-such-target

	[ "$status" -ne 0 ]
	[[ "$output" == *"no-such-target"* ]]
	[[ "$output" == *"Failed to expand dependency graph"* ]]

	# Warm start never arms the reaper — PC stays as we found it.
	assert_pc_still_running
}
