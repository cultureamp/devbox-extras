#!/usr/bin/env bats

# Pins: a one-shot node that carries a readiness_probe is NOT treated as a
# daemon for the PC-lifecycle decision. Once the node has Completed, its
# is_running is false, so graph_has_long_running_process returns "no" and
# the reaper trap fires.

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "one-shot with readiness_probe is treated as command-mode and reaps process-compose" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" --process=for-verify

	assert_succeeded
	[ -f "$MARKER_DIR/probe_oneshot.ran" ]
	assert_pc_reaped
}
