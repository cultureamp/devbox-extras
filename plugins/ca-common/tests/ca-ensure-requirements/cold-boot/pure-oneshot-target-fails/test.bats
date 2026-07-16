#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "pure one-shot graph with a failing dep fails and reaps process-compose" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" --process=for-verify

	assert_failed_with_dependency_graph_error
	assert_pc_reaped
}
