#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "all-mode fails and dumps logs when any process fails" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE"

	assert_failed_with_dependency_graph_error
	[[ "$output" == *"Logs for failing-oneshot"* ]]
	[[ "$output" == *"distinctive-failure-log-line"* ]]

	# Failure path: reaper trap fires.
	assert_pc_reaped
}
