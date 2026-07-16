# ca-common devbox plugin

Sets sensible defaults for cultureamp devbox repos and provides some common helper scripts.

## Features

- Sets the env var `npm_config_python` to point to the version installed by xcode-tools
  - if running on macOS and xcode-tools' version of python is found
  - this version of python always seems to be compatible with node-gyp
  - setting this env var does not affect non-npm projects

- Adds run-with-services-up command
  - A wrapper for running a command that handles spinning up and down devbox services
  - Usage: run-with-services-up [--timeout=SECONDS] [--service=SERVICE_NAME] [--process-compose-file=PATH] [--help] <command> [args...]

- Adds ca-ensure-requirements command
  - Runs the equivalent of `devbox services up`, waits for every process to be ready or completed, and logs errors on failure — daemons Ready (via readiness_probe), one-shots Completed with exit 0. With `--process=NAME` it instead ensures only the named process (or meta-process) and its full dependency graph. Autodetects mode: if the graph contains a long-running daemon, process-compose is left running; otherwise it is reaped after the graph completes.
  - Usage: ca-ensure-requirements [--process=NAME] [--timeout=SECONDS] [--process-compose-file=PATH] [--help]
  - Notes:
    - A long-running process must declare a readiness_probe — without one it cannot be verified and the run times out.
    - Processes marked `disabled: true` are skipped, matching `devbox services up`. If process-compose is already running from a targeted boot (e.g. `devbox services up some-name`), the default mode ensures only the processes that instance has enabled.
    - Breaking change: the process name used to be a positional argument (`ca-ensure-requirements <name>`); it is now `--process=<name>`, and running with no flag ensures everything.
