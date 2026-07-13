#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "one-shot target succeeds when an unrelated daemon is already running" {
	setup_unrelated_daemon_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify-oneshot

	assert_succeeded
	[ -f "$MARKER_DIR/oneshot.ran" ]

	# Unrelated daemon must still be reachable — warm-start never reaps.
	run curl --silent --fail http://localhost:7000
	[ "$status" -eq 0 ]
	assert_pc_still_running
}

@test "daemon target succeeds when an unrelated daemon is already running" {
	setup_unrelated_daemon_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify-daemon

	assert_succeeded

	# Target's daemon is up AND unrelated daemon is still reachable.
	run curl --silent --fail http://localhost:5055
	[ "$status" -eq 0 ]
	run curl --silent --fail http://localhost:7000
	[ "$status" -eq 0 ]
	assert_pc_still_running
}
