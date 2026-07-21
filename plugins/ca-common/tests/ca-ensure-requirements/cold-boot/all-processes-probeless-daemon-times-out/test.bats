#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "all-mode times out on a long-running process without a readiness probe" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" --timeout=5

	[ "$status" -ne 0 ]
	[[ "$output" == *"Timeout: dependency graph did not become ready after 5s"* ]]
	[[ "$output" == *"Logs for probeless-daemon"* ]]

	# Timeout path: reaper trap fires.
	assert_pc_reaped
}
