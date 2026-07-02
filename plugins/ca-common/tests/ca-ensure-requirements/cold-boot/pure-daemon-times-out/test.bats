#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "fails when a dep never passes its readiness probe" {
	setup_nothing_running

	run \
		ca-ensure-requirements \
		--process-compose-file="$PCFILE" \
		--timeout=5 \
		ready-check

	[ "$status" -ne 0 ]
	[[ "$output" == *"Timeout: dependency graph did not become ready after 5s"* ]]
	# Timeout path: reaper trap fires.
	assert_pc_reaped
}
