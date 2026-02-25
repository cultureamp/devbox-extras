
#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "processes all finish, exit 0 status from all processes" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 1 ]
	[[ "$output" == *"Error: Process manager is not running."* ]]
	[[ "$output" != *"Command completed"* ]]
}
