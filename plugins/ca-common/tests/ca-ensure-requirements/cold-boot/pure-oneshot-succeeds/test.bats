#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "pure one-shot graph succeeds and process-compose is reaped" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify

	assert_succeeded
	[ -f "$MARKER_DIR/oneshot.ran" ]

	# Command-mode: PC must be reaped after a pure one-shot graph.
	assert_pc_reaped
}
