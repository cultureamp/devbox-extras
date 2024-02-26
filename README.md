# Tooling install for local development environments

You can find the install script for the local development environment at [./scripts/bootstrap.sh](./scripts/bootstrap.sh).
The recommended command to run this install script is `curl --proto '=https' --tlsv1.2 -sSf -L https://raw.githubusercontent.com/cultureamp/devbox-extras/main/scripts/bootstrap.sh | sh`

# devbox-plugins

Devbox is something we're trialing internally, we need some plugins. So putting them here for now, all in one place. Plugins are documented in their respective folders.

This repo is public as it's only used to configure open source software, there will likely be a bit of company specific stuff in here but nothing sensitive.

Once we're happy with there plugins we'll attempt to upstream them as appropriate.

# Formatting and linting

```sh
# check formatting and linting
devbox run lint

# autofix (where possible) formatting and linting
devbox run lint:fix
```
