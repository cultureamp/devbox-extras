#!/usr/bin/env bats

load "../../../test_helper"

setup() {
	common_setup
}

teardown() {
	common_teardown
}

@test "exits with error when DEVBOX_PROJECT_ROOT is unset" {
	DEVBOX_PROJECT_ROOT="" run ca-ensure-requirements some-target
	[ "$status" -ne 0 ]
	[[ "$output" == *"must be run inside a devbox shell"* ]]
}
