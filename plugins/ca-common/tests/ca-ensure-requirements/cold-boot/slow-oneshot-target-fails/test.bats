#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "slow one-shot target that exits non-zero fails and reaps process-compose" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" slow-failing-oneshot

	assert_failed_with_dependency_graph_error
	# Failure path: reaper trap fires.
	assert_pc_reaped
}
