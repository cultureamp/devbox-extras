#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "dep with condition process_completed may exit non-zero without failing the run" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify

	assert_succeeded
	[[ "$output" == *"completed successfully"* ]]

	# Pure one-shot graph → command-mode → PC reaped.
	assert_pc_reaped
}
