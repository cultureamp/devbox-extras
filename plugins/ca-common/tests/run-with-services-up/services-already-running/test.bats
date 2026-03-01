#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup

	devbox services up --process-compose-file="$PCFILE" --background >/dev/null 2>&1
	sleep 2
}

teardown() {
	devbox services stop >/dev/null 2>&1
}

@test "fails when devbox services are already running" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Devbox is already running. Please stop it before using run-with-services-up."* ]]
	[[ "$output" != *"Command completed"* ]]
}
