#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

# Pre-state: the full set booted with no target — exactly what a bare
# `devbox services up` does. The daemons keep PC alive.
setup_full_set_already_up() {
	devbox_services_up_background --process-compose-file="$PCFILE"
	for _ in {1..30}; do
		curl --silent --fail http://localhost:7155 >/dev/null 2>&1 \
			&& curl --silent --fail http://localhost:7165 >/dev/null 2>&1 \
			&& return 0
		sleep 1
	done
	return 1
}

@test "warm-start all-mode over a full services-up instance is a no-op success" {
	setup_full_set_already_up

	run ca-ensure-requirements --process-compose-file="$PCFILE"

	assert_succeeded
	[[ "$output" == *"All processes are ready"* ]]
	[ -f "$MARKER_DIR/some_oneshot.ran" ]

	# Warm start never touches PC lifecycle; daemons running → PC left up.
	assert_pc_still_running
}
