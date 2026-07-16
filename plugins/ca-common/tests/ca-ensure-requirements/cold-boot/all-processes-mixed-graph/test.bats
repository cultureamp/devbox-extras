#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "all-mode satisfies every enabled process and leaves process-compose running" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE"

	assert_succeeded
	[[ "$output" == *"All processes are ready"* ]]
	[ -f "$MARKER_DIR/install_dependencies.ran" ]
	[ -f "$MARKER_DIR/database_migrations.ran" ]

	# All daemons started — including ones outside the for-verify graph,
	# which target mode would have left alone.
	run curl --silent --fail http://localhost:6190  # database-server
	[ "$status" -eq 0 ]
	run curl --silent --fail http://localhost:5155  # web-server
	[ "$status" -eq 0 ]
	run curl --silent --fail http://localhost:6170  # background-worker
	[ "$status" -eq 0 ]

	# The disabled process must be skipped, not started and waited on.
	[ ! -f "$MARKER_DIR/disabled_process.ran" ]

	# Daemons are running → daemon-mode → PC left up.
	assert_pc_still_running
}
