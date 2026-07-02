#!/usr/bin/env bats

# Pins: a one-shot target with a daemon dep succeeds AND leaves PC
# running (daemon-in-graph → daemon-mode).

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "one-shot target with a daemon dep succeeds and process-compose is left running" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" oneshot-target

	assert_succeeded
	[ -f "$MARKER_DIR/oneshot_target.ran" ]
	run curl --silent --fail http://localhost:7100
	[ "$status" -eq 0 ]

	# Daemon in the graph → daemon-mode → PC left up.
	assert_pc_still_running
}
