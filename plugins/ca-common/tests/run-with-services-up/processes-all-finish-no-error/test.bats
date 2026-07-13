
#!/usr/bin/env bats

load "../test_helper"

setup() {
	common_setup
}

@test "one-shots that all complete successfully run the command, then tear down" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 0 ]
	[[ "$output" == *"Command completed"* ]]
}
