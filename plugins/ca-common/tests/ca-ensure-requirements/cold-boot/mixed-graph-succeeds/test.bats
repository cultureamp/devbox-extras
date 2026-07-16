#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "mixed graph succeeds and process-compose is left running" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" --process=for-verify

	assert_succeeded
	[ -f "$MARKER_DIR/install_dependencies.ran" ]
	[ -f "$MARKER_DIR/database_migrations.ran" ]
	run curl --silent --fail http://localhost:6090
	[ "$status" -eq 0 ]

	# Services outside the for-verify dependency graph should not have been started.
	run curl --silent --fail --connect-timeout 1 http://localhost:5055  # web-server
	[ "$status" -ne 0 ]
	run curl --silent --fail --connect-timeout 1 http://localhost:6060  # kafka-consumer
	[ "$status" -ne 0 ]
	run curl --silent --fail --connect-timeout 1 http://localhost:6070  # background-worker
	[ "$status" -ne 0 ]
	run curl --silent --fail --connect-timeout 1 http://localhost:6080  # frontend
	[ "$status" -ne 0 ]

	# Mixed graph contains a daemon (database-server) → daemon-mode → PC left up.
	assert_pc_still_running
}
