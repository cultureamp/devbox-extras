#!/usr/bin/env bash

# Common setup function for run-with-services-up tests
common_setup() {
  # Get the directory containing the test file
  local test_dir="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

  # Find the ca-common plugin directory by going up from the test directory
  local plugin_dir="$( cd "$test_dir" && while [[ $PWD != "/" && $(basename $PWD) != "ca-common" ]]; do cd .. || break; done && pwd )"

  # Ensure we actually found the ca-common plugin directory
  if [[ "$(basename "$plugin_dir")" != "ca-common" ]]; then
    echo "Error: could not locate 'ca-common' plugin directory starting from '$test_dir'" >&2
    return 1
  fi
  
  # Add the bin directory to PATH
  export PATH="$plugin_dir/bin:$PATH"

  # Set the process compose file path
  PCFILE="$(realpath "$(dirname "$BATS_TEST_FILENAME")/process-compose.yaml")"
}