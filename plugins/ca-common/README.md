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
  - Ensures a named process (or meta-process) and its full dependency graph is satisfied — daemons Ready (via readiness_probe), one-shots Completed with exit 0. Autodetects mode: if the graph contains a long-running daemon, process-compose is left running; otherwise it is reaped after the graph completes.
  - Usage: ca-ensure-requirements [--timeout=SECONDS] [--process-compose-file=PATH] [--help] <name>
