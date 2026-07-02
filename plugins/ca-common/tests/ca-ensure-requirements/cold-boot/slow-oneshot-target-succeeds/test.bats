#!/usr/bin/env bats

# Pins: a probe-less one-shot target is only satisfied once it has
# Completed with exit 0. Declaring success while the one-shot is still
# running would return before the marker exists (and would misclassify
# the run as daemon-mode, leaking process-compose).

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "slow one-shot target succeeds only after completion and reaps process-compose" {
	setup_nothing_running

	run ca-ensure-requirements --process-compose-file="$PCFILE" slow-oneshot

	assert_succeeded
	[[ "$output" == *"completed successfully"* ]]
	# The marker only exists once the command finished — premature success
	# mid-`sleep` would observe no marker.
	[ -f "$MARKER_DIR/slow_oneshot.ran" ]

	# Pure one-shot graph → command-mode → PC reaped.
	assert_pc_reaped
}
