#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "typo'd target exits non-zero and reaps process-compose" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" --process=no-such-target

	[ "$status" -ne 0 ]
	[[ "$output" == *"Failed to start process-compose"* ]]

	# The EXIT trap is armed before cold_start's devbox invocation, so
	# even a devbox-rejects-target failure leaves no leftover master.
	assert_pc_reaped
}
