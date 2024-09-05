# Tooling install for local development environments

The recommended command to setup a Culture Amp macbook for working with LDEs/devbox is:

```bash
# install hotel cli
ruby -e "$(curl -fsSL https://github.com/cultureamp/devbox-extras/blob/main/scripts/github_auth.rb)"

# use hotel to setup LDEs
hotel setup ensure
```

Should this authentication flow not work, you can manually authenticate with the following script:
The PAT token should have read access to the `repository` scope and be enabled with SSO for Culture Amp.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/cultureamp/devbox-extras/main/scripts/install_hotel.sh) {insert_pat_token_here}"
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

# Netskope combined cert

This repo hosts a public CA cert bundle with Netskope's cert added. Netskope's public cert is not sensitive so there is no issue with it being available publicly. It's not intented to be useful outside the company.

The certificate can be accessed on the following stable urls:

```bash
# just Netskope's cert
curl https://raw.githubusercontent.com/cultureamp/devbox-extras/main/certs/nscacert.pem

# just bundle with Netskope's cert included
curl https://raw.githubusercontent.com/cultureamp/devbox-extras/main/certs/nscacert_combined.pem
```

The certificate bundles are generated using [Nix's cacert package](https://github.com/NixOS/nixpkgs/blob/2240a1a/pkgs/data/misc/cacert/default.nix#L32-L90), which gets it's certificates from [github.com/nss-dev/nss](https://github.com/nss-dev/nss), a Mozilla project.

The certificate bundle is updated whenever this project's `flake.lock` is updated, and the commited certificate bundle is ensured to up to date by a github action. To update the flake and certificate bundle:

```bash
nix flake update
nix run .#generate-netskope-combined-cert
```
