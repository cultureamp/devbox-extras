#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "warm-start: an already-failed process is reported, not restarted and waited out" {
	# Warm pre-state: the graph is already up and failing-oneshot has
	# terminally failed (Completed, exit 1) before we run ensure.
	setup_process_already_failed failing-oneshot

	# A short timeout: the fix must fail fast. The buggy behaviour (restart
	# the failed one-shot, then wait for its hung replacement) burns the whole
	# timeout instead.
	run ca-ensure-requirements --process-compose-file="$PCFILE" --timeout=10

	assert_failed_with_dependency_graph_error
	[[ "$output" == *"Logs for failing-oneshot"* ]]
	[[ "$output" == *"distinctive-failure-log-line"* ]]

	# The already-failed one-shot must NOT have been restarted: exactly one
	# invocation, and the hung-replacement marker line never printed.
	[ "$(wc -l <"$MARKER_DIR/failing_oneshot.runs")" -eq 1 ]
	[[ "$output" != *"restarted-when-it-should-not-be"* ]]

	# Warm start never touches PC lifecycle, and the daemon is still up.
	assert_pc_still_running
}
