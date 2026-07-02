#!/usr/bin/env bash

# Per-test setup: PATH (with the plugin's bin/ at the front), PCFILE,
# per-test MARKER_DIR, plus a defensive stop_all_services so each test
# starts from a known-empty state.
common_setup() {
  _setup_paths_and_pcfile

  export MARKER_DIR="$BATS_TEST_TMPDIR/markers"
  mkdir -p "$MARKER_DIR"

  stop_all_services
}

common_teardown() {
  stop_all_services
}

_setup_paths_and_pcfile() {
  # Anchor on this file's own path: test_helper.bash lives at
  # plugins/ca-common/tests/, so `..` is the plugin dir. Independent of the
  # calling test's location or the plugin's directory name.
  local plugin_dir
  plugin_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

  export PATH="$plugin_dir/bin:$PATH"

  # shellcheck source=../bin/_lib.bash disable=SC1091
  source "$plugin_dir/bin/_lib.bash"

  local test_dir
  test_dir="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"

  # command-args tests don't ship a process-compose.yaml (they stage a tmp
  # dir instead), so tolerate a missing file here.
  local pcfile_candidate="$test_dir/process-compose.yaml"
  if [ -f "$pcfile_candidate" ]; then
    PCFILE="$(realpath "$pcfile_candidate")"
    export PCFILE
  else
    unset PCFILE
  fi
}

stop_all_services() {
  stop_and_reap_services "${PCFILE:-}"
}

# --- Pre-state helpers (called from inside @test) ---

setup_nothing_running() {
  :  # common_setup already cleared state
}

# Start the meta-process and wait until process-compose has finished
# running its dependency graph. For one-shot-only graphs we need
# --keep-project so the API stays alive long enough to poll for completion.
setup_services_already_up() {
  local meta="${1:-for-verify}"
  devbox_services_up_background --pcflags=--keep-project --process-compose-file="$PCFILE" "$meta"
  wait_for_meta_completed "$meta"
}

# For daemon test fixtures that include an `unrelated_daemon` long-running
# process the daemon itself keeps process-compose alive, so no
# --keep-project needed.
setup_unrelated_daemon_running() {
  devbox_services_up_background --process-compose-file="$PCFILE" unrelated_daemon
  wait_for_unrelated_daemon_ready
}

# --- Polling helpers ---

wait_for_meta_completed() {
  local meta="$1"
  local pcport
  pcport=$(devbox services pcport 2>/dev/null)
  local state
  for _ in {1..30}; do
    state=$(curl -s "http://localhost:$pcport/processes" 2>/dev/null \
            | jq -r --arg n "$meta" '.data[] | select(.name == $n) | "\(.status):\(.exit_code)"')
    [ "$state" = "Completed:0" ] && return 0
    sleep 1
  done
  return 1
}

wait_for_unrelated_daemon_ready() {
  for _ in {1..30}; do
    curl --silent --fail http://localhost:7000 >/dev/null 2>&1 && return 0
    sleep 1
  done
  return 1
}

# --- Assertion helpers ---
#
# $status and $output in the assertions below are set by bats's `run`
# before these helpers are called.

# shellcheck disable=SC2154
assert_succeeded() {
  [ "$status" -eq 0 ]
}

# shellcheck disable=SC2154
assert_failed_with_dependency_graph_error() {
  [ "$status" -ne 0 ]
  [[ "$output" == *"Error: One or more services in the dependency graph failed."* ]]
}

# PC lifecycle assertions used by the ca-ensure-requirements suite. Uses
# `pcport_if_running` (curl-based) rather than pgrep so the checks work
# under macOS sandbox modes that block sysmond (needed by pgrep).
assert_pc_still_running() {
  pcport_if_running >/dev/null
}

assert_pc_reaped() {
  ! pcport_if_running >/dev/null 2>&1
}
