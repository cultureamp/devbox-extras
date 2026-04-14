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
