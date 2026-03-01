load "../test_helper"

setup() {
	common_setup
}

@test "comprehensive integration test" {
	run \
		run-with-services-up \
		--process-compose-file="$PCFILE" \
		echo "Command completed"

	[ $status -eq 0 ]
	[[ "$output" == *"Command completed"* ]]

}
