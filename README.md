# Tooling install for local development environments

The recommended command to setup a Culture Amp macbook for working with LDEs/devbox is:

```bash
# install hotel cli
sh -c "$(curl -fsSL "https://raw.githubusercontent.com/cultureamp/devbox-extras/new-bootstrap/scripts/install_hotel.sh")"

# use hotel to setup LDEs
hotel setup ensure
```

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
