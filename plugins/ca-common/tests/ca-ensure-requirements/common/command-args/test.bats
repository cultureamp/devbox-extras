#!/usr/bin/env bats

# Argument-parsing tests for ca-ensure-requirements. The --help, -h and
# --timeout tests exit before invoking `devbox services up`, so no real
# devbox project is needed. The fallback-file tests stage a tmp dir as
# $DEVBOX_PROJECT_ROOT holding a trivial one-shot fixture; a successful
# run proves the default file was resolved and the pipeline ran.

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "--help prints usage and exits 0" {
	run ca-ensure-requirements --help
	[ "$status" -eq 0 ]
	[[ "$output" == *"Usage:"* ]]
}

@test "-h prints usage and exits 0" {
	run ca-ensure-requirements -h
	[ "$status" -eq 0 ]
	[[ "$output" == *"Usage:"* ]]
}

@test "rejects non-numeric --timeout" {
	run ca-ensure-requirements --timeout=abc
	[ "$status" -ne 0 ]
	[[ "$output" == *"Invalid --timeout value"* ]]
}

@test "rejects zero --timeout" {
	run ca-ensure-requirements --timeout=0
	[ "$status" -ne 0 ]
	[[ "$output" == *"Invalid --timeout value"* ]]
}

@test "rejects negative --timeout" {
	run ca-ensure-requirements --timeout=-5
	[ "$status" -ne 0 ]
	[[ "$output" == *"Invalid --timeout value"* ]]
}

# The argument-count check requires exactly one positional target. It runs
# after the devbox-shell guard, so DEVBOX_PROJECT_ROOT must be set to reach
# it; --process-compose-file skips the default-file lookup.
@test "rejects invocation with no target" {
	DEVBOX_PROJECT_ROOT="$BATS_TEST_TMPDIR" run ca-ensure-requirements --process-compose-file=/dev/null
	[ "$status" -ne 0 ]
	[[ "$output" == *"exactly one process name is required"* ]]
}

@test "rejects invocation with multiple targets" {
	DEVBOX_PROJECT_ROOT="$BATS_TEST_TMPDIR" run ca-ensure-requirements --process-compose-file=/dev/null target1 target2
	[ "$status" -ne 0 ]
	[[ "$output" == *"exactly one process name is required"* ]]
}

# When --process-compose-file is omitted, the script falls back to
# \$DEVBOX_PROJECT_ROOT/process-compose.yaml. A successful run of a trivial
# one-shot proves the default resolved.
@test "falls back to \$DEVBOX_PROJECT_ROOT/process-compose.yaml when flag omitted" {
	local proj_root="$BATS_TEST_TMPDIR/proj"
	mkdir -p "$proj_root"
	cat > "$proj_root/process-compose.yaml" <<'YAML'
version: "0.5"
processes:
  some-oneshot:
    command: "true"
YAML

	DEVBOX_PROJECT_ROOT="$proj_root" run ca-ensure-requirements some-oneshot
	[ "$status" -eq 0 ]
	[[ "$output" == *"completed successfully"* ]]
}

@test "errors with helpful message when default process-compose.yaml is missing" {
	local proj_root="$BATS_TEST_TMPDIR/empty-proj"
	mkdir -p "$proj_root"

	DEVBOX_PROJECT_ROOT="$proj_root" run ca-ensure-requirements some-target
	[ "$status" -ne 0 ]
	[[ "$output" == *"process-compose file not found"* ]]
	[[ "$output" == *"$proj_root/process-compose.yaml"* ]]
}

# Same fixture as the .yaml fallback test but saved as process-compose.yml,
# to prove the default lookup also accepts the .yml extension.
@test "falls back to process-compose.yml when only .yml is present" {
	local proj_root="$BATS_TEST_TMPDIR/yml-proj"
	mkdir -p "$proj_root"
	cat > "$proj_root/process-compose.yml" <<'YAML'
version: "0.5"
processes:
  some-oneshot:
    command: "true"
YAML

	DEVBOX_PROJECT_ROOT="$proj_root" run ca-ensure-requirements some-oneshot
	[ "$status" -eq 0 ]
	[[ "$output" == *"completed successfully"* ]]
}
