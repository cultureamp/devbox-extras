#!/usr/bin/env bats

# Pins: on the warm-start API path, dependency graph members are started
# in topological order (deps before dependents). Started out of order,
# migrations would run before install-deps completed and record "before".

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "deps are started before dependents on the warm-start API path" {
	setup_unrelated_daemon_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify

	assert_succeeded
	[ -f "$MARKER_DIR/install_deps.ran" ]
	[ "$(cat "$MARKER_DIR/migrations_saw_install_deps")" = "after" ]
}
