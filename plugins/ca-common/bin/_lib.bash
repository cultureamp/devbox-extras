#!/usr/bin/env bash

# Shared helpers for the ensure-* scripts. Source this file; do not
# execute it directly.
#
# Functions communicate with process-compose's HTTP API via $PCPORT (must be
# exported by the caller before invoking any function that needs it).

readonly API_WAIT_TIMEOUT_SECONDS=60
readonly PC_STOP_REAP_TIMEOUT_SECONDS=5

# EXIT-trap helpers for callers that boot process-compose themselves and
# need to reap it on any failure path. `arm_reaper` records the pcfile and
# installs the trap; `disarm_reaper` clears it on the happy daemon-mode
# path so PC is left running.
#
# The trap body is single-quoted so `$pcfile` is not interpolated at
# trap-set time — the current value of _REAPER_PCFILE is read at trap-fire
# time, and its contents are passed as an argv, so paths containing single
# quotes, dollars, or backticks are safe.
arm_reaper() {
  _REAPER_PCFILE="$1"
  trap 'stop_and_reap_services "$_REAPER_PCFILE"' EXIT
}

disarm_reaper() {
  trap - EXIT
}

# `devbox services up --background` forks a `process-compose` master that
# inherits every FD 3+ from the parent (bats IPC pipes, CI stdin/stdout
# capture pipes, IDE terminals). Without closing them, the orphan can hold
# the parent's private pipes open indefinitely and callers hang. See
# docs/bugs/devbox-background-fd-leak.md.
devbox_services_up_background() {
  ( for fd in $(seq 3 20); do eval "exec $fd>&-" 2>/dev/null; done
    devbox services up --background "$@" )
}

# `devbox services stop` doesn't always reap the `process-compose … -f
# $pcfile` master (same bug). Actively kill any leftover master tied to the
# given pcfile and wait for it to exit so inherited FDs are released.
#
# pcfile is interpolated into a regex used by pkill -f / pgrep -f, so
# regex metachars must be escaped — otherwise paths containing `.` are
# looser than intended and paths with `[`, `(`, `+`, etc. (nix store
# paths, user dirs with parens) silently fail to match at all.
stop_and_reap_services() {
  local pcfile="$1"
  devbox services stop >/dev/null 2>&1 || true
  [ -z "$pcfile" ] && return 0
  local pcfile_re
  pcfile_re=$(printf '%s' "$pcfile" | sed -E 's/[][(){}.+*?^$|\\]/\\&/g')
  pkill -f "process-compose .* -f $pcfile_re" 2>/dev/null || true
  local deadline=$((SECONDS + PC_STOP_REAP_TIMEOUT_SECONDS))
  while pgrep -f "process-compose .* -f $pcfile_re" >/dev/null 2>&1; do
    if [ $SECONDS -ge $deadline ]; then
      pkill -9 -f "process-compose .* -f $pcfile_re" 2>/dev/null || true
      break
    fi
    sleep 0.1
  done
}

# Echo the port of a process-compose instance that's already up.
# `devbox services pcport` reports a port even when nothing listens, so
# probe the API for HTTP 200 to confirm it's actually serving. Returns 0
# with the port on stdout when reachable, 1 (no output) otherwise —
# callers using $() get an empty string on failure regardless, but the
# exit code is now meaningful for `if pcport_if_running; then ...` uses.
pcport_if_running() {
  local port
  port=$(devbox services pcport 2>/dev/null) || return 1
  [ -z "$port" ] && return 1
  local http_code
  http_code=$(curl -s -o /dev/null -w "%{http_code}" \
                --connect-timeout 1 \
                "http://localhost:$port/processes" 2>/dev/null) || return 1
  if [ "$http_code" = "200" ]; then
    echo "$port"
    return 0
  fi
  return 1
}

# Probe the API every 100ms for up to API_WAIT_TIMEOUT_SECONDS. Echo the
# port and return 0 once it answers HTTP 200; return 1 (no output) on
# timeout.
wait_for_port() {
  local deadline=$((SECONDS + API_WAIT_TIMEOUT_SECONDS))
  local port=""
  while [[ $SECONDS -lt $deadline ]]; do
    port=$(pcport_if_running)
    if [ -n "$port" ]; then
      echo "$port"
      return 0
    fi
    sleep 0.1
  done
  return 1
}

# Map a depends_on condition onto the runtime requirement it places on the
# dependency. An empty condition means process-compose applies no gating,
# so "started" is all a dependent can assume; an unrecognised condition
# maps to "completed" (the strictest) so new upstream conditions fail loud
# (timeout) instead of silently passing.
condition_to_requirement() {
  case "$1" in
    process_completed_successfully|process_completed) echo "completed" ;;
    process_healthy) echo "healthy" ;;
    process_started|process_log_ready|"") echo "started" ;;
    *) echo "completed" ;;
  esac
}

_requirement_rank() {
  case "$1" in
    completed) echo 3 ;;
    healthy) echo 2 ;;
    started) echo 1 ;;
    *) echo 0 ;;
  esac
}

# Whether a node's runtime state (from parse_processes_states) satisfies
# the requirement its in-graph dependents (or, for a root, this tool)
# place on it:
#   completed — Completed with exit 0. A merely-running process is NOT
#               satisfied: a slow one-shot mid-run must be waited out so
#               its exit code is actually checked.
#   healthy   — readiness_probe passing (or already completed cleanly).
#   started   — running is enough (or either stronger state above).
#   default   — roots/targets: ready or completed. Merely "running" is not
#               accepted — without a probe or a dependent's condition, a
#               running process is indistinguishable from a one-shot that
#               hasn't finished, and accepting it would report success
#               before the one-shot's exit code exists. Long-running
#               targets therefore need a readiness_probe.
node_satisfied() {
  local state="$1"
  local requirement="$2"
  case "$requirement" in
    completed) [ "$state" = "completed_ok" ] ;;
    started) [ "$state" = "running" ] || [ "$state" = "ready" ] || [ "$state" = "completed_ok" ] ;;
    *) [ "$state" = "ready" ] || [ "$state" = "completed_ok" ] ;;
  esac
}

# Resolve the depends_on dependency graph of one or more roots. Emits one
# TSV row per node — name<TAB>requirement — in dependency order: a real
# topological sort (depth-first post-order), so every node appears after
# all of its deps. (Reversed BFS order is NOT topological: for
# root -> {A, B} with B -> A, it emits B before A.)
#
# requirement is the strongest condition any in-graph dependent declares
# on the node (see condition_to_requirement); roots get "default".
# Requires $PCPORT.
expand_dependency_graph() {
  declare -A deps_of=() requirement=() fetched=()
  local roots=("$@")
  local queue=("${roots[@]}")

  while [ "${#queue[@]}" -gt 0 ]; do
    local name="${queue[0]}"
    queue=("${queue[@]:1}")
    if [ -n "${fetched[$name]+x}" ]; then
      continue
    fi
    fetched[$name]=1

    local response http_code info
    # $PCPORT is a caller-set global (see file-header docstring), not a typo of `pcport`.
    # shellcheck disable=SC2153
    response=$(curl -s -w $'\n%{http_code}' --connect-timeout 2 \
                 "http://localhost:$PCPORT/process/info/$name") || {
      echo "Error: failed to fetch /process/info/$name" >&2
      return 1
    }
    http_code="${response##*$'\n'}"
    info="${response%$'\n'*}"
    # process-compose answers an unknown name with HTTP 400 and a JSON body
    # ({"error":"no such process: ..."}), so the status code — not jq
    # parseability — is the existence check.
    if [ "$http_code" != "200" ]; then
      echo "Error: /process/info/$name returned HTTP $http_code — does process '$name' exist in the process-compose file?" >&2
      [ -n "$info" ] && echo "  $info" >&2
      return 1
    fi
    if [ -z "$info" ] || ! echo "$info" | jq -e . >/dev/null 2>&1; then
      echo "Error: /process/info/$name returned no JSON." >&2
      return 1
    fi

    deps_of[$name]=""
    local dep condition
    while IFS=$'\t' read -r dep condition; do
      [ -z "$dep" ] && continue
      deps_of[$name]+="$dep"$'\n'
      local req
      req=$(condition_to_requirement "$condition")
      if [ "$(_requirement_rank "$req")" -gt "$(_requirement_rank "${requirement[$dep]:-}")" ]; then
        requirement[$dep]="$req"
      fi
      queue+=("$dep")
    done < <(echo "$info" | jq -r '(.dependsOn // {}) | to_entries[] | [.key, (.value.condition // "")] | @tsv')
  done

  # Iterative depth-first post-order. A dep edge reaching a node that is
  # still "visiting" is a back-edge, i.e. a dependency cycle.
  declare -A state=()
  local order=() stack=("${roots[@]}")
  while [ "${#stack[@]}" -gt 0 ]; do
    local top=$(( ${#stack[@]} - 1 ))
    local n="${stack[top]}"
    if [ -z "${state[$n]:-}" ]; then
      state[$n]="visiting"
      local d
      while IFS= read -r d; do
        [ -z "$d" ] && continue
        case "${state[$d]:-}" in
          "") stack+=("$d") ;;
          visiting)
            echo "Error: dependency cycle detected involving '$d'." >&2
            return 1 ;;
        esac
      done <<< "${deps_of[$n]}"
    else
      unset "stack[top]"
      if [ "${state[$n]}" = "visiting" ]; then
        state[$n]="done"
        order+=("$n")
      fi
    fi
  done

  local node
  for node in "${order[@]}"; do
    printf '%s\t%s\n' "$node" "${requirement[$node]:-default}"
  done
}

# POST /process/<verb>/<name>. Returns 0 on success (200) or on a benign
# "already running/started" 400 from process-compose (a concurrent boot got
# there first). Any other response is warned to stderr and returned as a
# non-zero exit so callers can react — currently callers just log.
post_process() {
  local name="$1"
  local verb="$2"
  local body_file
  body_file="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm -f '$body_file'" RETURN

  local http_code
  http_code=$(curl -s -o "$body_file" -w "%{http_code}" -X POST \
                "http://localhost:$PCPORT/process/$verb/$name") || http_code="000"
  case "$http_code" in
    200) return 0 ;;
    400)
      if grep -Eiq 'already (running|started)|is running|already exists' "$body_file"; then
        return 0
      fi
      echo "    warning: POST /process/$verb/$name returned HTTP 400: $(cat "$body_file")" >&2
      return 1
      ;;
    *)
      local body_snippet=""
      [ -s "$body_file" ] && body_snippet=": $(cat "$body_file")"
      echo "    warning: POST /process/$verb/$name returned HTTP $http_code$body_snippet" >&2
      return 1
      ;;
  esac
}

# Emit one TSV row per process in a /processes response:
#   name<TAB>state<TAB>failed<TAB>action
# where:
#   state  ∈ {completed_ok, ready, running, pending}
#     completed_ok — Completed with exit code 0
#     ready        — readiness_probe defined and passing
#     running      — forked and running (probe, if any, not yet passing)
#     pending      — everything else (not yet started, restarting, …)
#   failed ∈ {ok, fail}  — non-transient non-zero exits are "fail"
#   action ∈ {completed, ready, running, restart, start}
#
# Whether a state satisfies a node depends on the node's requirement — see
# node_satisfied. Callers read this once per polling iteration into
# associative arrays and do O(graph) lookups instead of spawning O(graph)
# jq subprocesses per check.
parse_processes_states() {
  local processes_response="$1"
  echo "$processes_response" | jq -r '
    .data[] |
    [
      .name,
      (if (.status == "Completed" and .exit_code == 0) then "completed_ok"
       elif (.has_ready_probe == true and .is_ready == "Ready") then "ready"
       elif (.is_running == true) then "running"
       else "pending" end),
      (if (.exit_code != 0 and
           .status != "Restarting" and
           .status != "Disabled" and
           .status != "Skipped") then "fail" else "ok" end),
      (if (.status == "Completed" and .exit_code == 0) then "completed"
       elif (.has_ready_probe == true and .is_ready == "Ready") then "ready"
       elif (.is_running == true) then "running"
       elif (.status == "Completed" and .exit_code != 0) then "restart"
       else "start" end)
    ] | @tsv
  '
}

# Read the /processes response into three associative arrays scoped to the
# caller. Callers must `declare -A` the three arrays and pass their names.
# Requires bash 4.3+ (nameref).
load_state_maps() {
  local processes_response="$1"
  local -n _state="$2"
  local -n _fail="$3"
  local -n _action="$4"
  local name state failed action
  # SC2004 misfires here: nameref targets are associative arrays (callers
  # `declare -A`), so `$name` is a string subscript, not arithmetic.
  # shellcheck disable=SC2004
  while IFS=$'\t' read -r name state failed action; do
    _state[$name]=$state
    _fail[$name]=$failed
    _action[$name]=$action
  done < <(parse_processes_states "$processes_response")
}

# Iterate the dependency graph once, calling post_process to start/restart
# every member that isn't already satisfied. Buffers a per-process report
# and emits it only if at least one process needed work — a no-op warm
# start stays quiet. Requires $PCPORT.
start_dependency_graph_services() {
  local dependency_graph="$1"
  local processes_response
  processes_response=$(curl -s "http://localhost:$PCPORT/processes")

  # state_map and fail_map are required by load_state_maps's signature but
  # unused here.
  # shellcheck disable=SC2034
  declare -A state_map fail_map action_map
  load_state_maps "$processes_response" state_map fail_map action_map

  local lines=""
  local needs_report=0
  local name
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    local action="${action_map[$name]:-start}"
    case "$action" in
      completed)
        lines+="  - $name: already completed."$'\n' ;;
      ready)
        lines+="  - $name: already ready."$'\n' ;;
      running)
        lines+="  - $name: in progress."$'\n'
        needs_report=1 ;;
      restart)
        lines+="  - $name: previously failed, restarting."$'\n'
        needs_report=1
        post_process "$name" "restart" ;;
      start)
        lines+="  - $name: starting."$'\n'
        needs_report=1
        post_process "$name" "start" ;;
    esac
  done <<< "$dependency_graph"

  if [ "$needs_report" = "1" ]; then
    printf "%s" "$lines"
    echo ""
  fi
}

# Emit the failure-mode header and dump logs for every dependency graph
# member that is either failed, or (on timeout, rc == 2) still unsatisfied.
# $timeout_message is printed when $rc == 2; otherwise a generic "one or
# more services failed" message is printed. $4 names the caller's
# associative array of node requirements (from expand_dependency_graph).
# Requires $PCPORT.
handle_dependency_graph_failure() {
  local dependency_graph="$1"
  local rc="$2"
  local timeout_message="$3"
  local -n _requirements="$4"
  local processes_response
  processes_response=$(curl -s "http://localhost:$PCPORT/processes")

  echo ""
  if [ "$rc" -eq 2 ]; then
    echo "$timeout_message"
  else
    echo "Error: One or more services in the dependency graph failed."
  fi
  echo ""

  # action_map is required by load_state_maps's signature but unused here.
  # shellcheck disable=SC2034
  declare -A state_map fail_map action_map
  load_state_maps "$processes_response" state_map fail_map action_map

  local name
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    local failed="${fail_map[$name]:-ok}"
    if [ "$failed" = "fail" ] \
      || { [ "$rc" -eq 2 ] \
           && ! node_satisfied "${state_map[$name]:-pending}" "${_requirements[$name]:-default}"; }; then
      print_process_logs "$PCPORT" "Logs for $name" "$name"
    fi
  done <<< "$dependency_graph"
}

# Render the /processes JSON as a `process-compose list`-style table.
# Devbox bundles process-compose internally and doesn't put it on PATH, so
# we format the columns ourselves from the API response.
print_processes_table() {
  local processes_response="$1"
  local fmt="%-12s %-20s %-16s %-16s %-12s %-13s %-15s %s\n"
  # $fmt is a fixed literal defined above — safe to use as printf's format arg.
  # shellcheck disable=SC2059
  printf "$fmt" "PID" "NAME" "NAMESPACE" "STATUS" "AGE" "HEALTH" "RESTARTS" "EXIT CODE"
  echo "$processes_response" | jq -r '
    .data[] |
    [
      (.pid // 0),
      .name,
      (.namespace // "default"),
      .status,
      (.system_time // "0s"),
      (if (.is_ready == "Ready" or .is_ready == "Not Ready") then .is_ready else "-" end),
      (.restarts // 0),
      (.exit_code // 0)
    ] | @tsv
  ' | while IFS=$'\t' read -r pid name ns status age health restarts ec; do
    # shellcheck disable=SC2059
    printf "$fmt" "$pid" "$name" "$ns" "$status" "$age" "$health" "$restarts" "$ec"
  done
}

print_process_logs() {
  local pcport="$1"
  local header_prefix="$2"
  shift 2
  local process_names=("$@")

  for process_name in "${process_names[@]}"; do
    echo "::group::${header_prefix}: $process_name"
    local logs_response
    logs_response=$(curl -s "http://localhost:$pcport/process/logs/$process_name/0/0")
    if ! echo "$logs_response" | jq -r '.logs[]' 2>/dev/null; then
      echo "(Could not retrieve logs for this process)"
    fi
    echo "::endgroup::"
    echo ""
  done
}
