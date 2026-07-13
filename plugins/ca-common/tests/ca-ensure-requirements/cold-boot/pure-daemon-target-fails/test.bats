#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "daemon graph with a failing daemon fails and reaps process-compose" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify

	assert_failed_with_dependency_graph_error
	# Failure path: reaper trap fires regardless of graph shape.
	assert_pc_reaped
}
