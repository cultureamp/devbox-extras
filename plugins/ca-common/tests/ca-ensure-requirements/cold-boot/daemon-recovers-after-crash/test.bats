#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "daemon that crashes once and is policy-restarted succeeds" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" --process=for-verify

	assert_succeeded
	# The first run really did crash…
	[ -f "$MARKER_DIR/flaky_daemon_crashed_once" ]
	# …and the replacement run is serving.
	run curl --silent --fail http://localhost:7300
	[ "$status" -eq 0 ]

	# Daemon in the graph → daemon-mode → PC left up.
	assert_pc_still_running
}
