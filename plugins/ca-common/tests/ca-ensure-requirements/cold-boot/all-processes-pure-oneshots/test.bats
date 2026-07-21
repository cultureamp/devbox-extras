#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "all-mode with only one-shots completes them all and reaps process-compose" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE"

	assert_succeeded
	[[ "$output" == *"All processes completed successfully"* ]]
	[ -f "$MARKER_DIR/install_dependencies.ran" ]
	[ -f "$MARKER_DIR/database_migrations.ran" ]
	[ -f "$MARKER_DIR/compile_assets.ran" ]

	# Nothing long-running → command-mode → PC reaped.
	assert_pc_reaped
}
