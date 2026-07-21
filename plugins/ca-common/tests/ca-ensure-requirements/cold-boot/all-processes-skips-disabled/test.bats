#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "all-mode skips disabled processes" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE"

	assert_succeeded
	[[ "$output" == *"All processes completed successfully"* ]]
	[ -f "$MARKER_DIR/some_oneshot.ran" ]
	# The disabled process never ran — its failing command would otherwise
	# have failed the run.
	[ ! -f "$MARKER_DIR/disabled_failing_process.ran" ]
	assert_pc_reaped
}
