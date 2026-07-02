#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "pure daemon graph succeeds and process-compose is left running" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" for-verify

	assert_succeeded
	run curl --silent --fail http://localhost:5055
	[ "$status" -eq 0 ]

	# Daemon-mode: PC must be left up so the daemon stays reachable.
	assert_pc_still_running
}
