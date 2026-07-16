#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

# Pre-state: PC booted with a single target, so the instance's enabled
# scope is just already-up-daemon (the daemon keeps PC alive).
setup_scoped_instance_running() {
	devbox_services_up_background --process-compose-file="$PCFILE" already-up-daemon
	for _ in {1..30}; do
		curl --silent --fail http://localhost:7155 >/dev/null 2>&1 && return 0
		sleep 1
	done
	return 1
}

@test "warm-start all-mode ensures only the processes enabled in the running instance" {
	setup_scoped_instance_running

	run ca-ensure-requirements --process-compose-file="$PCFILE"

	assert_succeeded
	[[ "$output" == *"All processes are ready"* ]]

	# Processes outside the running instance's boot scope report Disabled
	# via the API (same as config-disabled), so all-mode leaves them alone.
	run curl --silent --fail --connect-timeout 1 http://localhost:7165
	[ "$status" -ne 0 ]
	[ ! -f "$MARKER_DIR/not_requested_oneshot.ran" ]

	assert_pc_still_running
}
