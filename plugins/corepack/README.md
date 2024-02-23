# Corepack plugin

This plugin sets up [Corepack](https://github.com/nodejs/corepack/), a NodeJS feature to automatically install the correct version of Yarn or PNPM.

When using corepack, running `pnpm` or `yarn` will always use the correct version as defined in the `packageManager` field of the project's `package.json` file.

## Use and activation

1. Add this plugin to the `include` section of your `devbox.json`:

```json
{
  "include": ["github:cultureamp/devbox-extras?dir=plugins/corepack"]
}
```

2. Ensure your `package.json` sets the `packageManager` field:

```json
{
  "packageManager": "pnpm@8.15.3"
}
```

or

```json
{
  "packageManager": "yarn@1.22.21"
}
```

## Motivation

There’s a subtle but messy issue that can arise using Devbox, Node.js, and Yarn/PNPM. If you install node and yarn as documented you will end up with two different versions of node:

```sh
$ devbox add nodejs@20.8 yarn
...
$ devbox run node --version
v20.8.0
$ devbox run yarn node --version
yarn node v1.22.19
v18.18.0
```

This happens because nix bundles all dependencies into every package, yarn is getting it’s own copy of Node.js, which may be more recent than the Node.js version the project is using.

Corepack by default tries to install shim scripts for both `yarn` and `pnpm` in the same directory that `node` is found in. Unfortunately when using devbox, the `node` binary is in the Nix store, which is read only, so Corepack fails to set up correctly.

This plugin works by:

- creating a folder in `.devbox/virtenv/pnpm_plugin/bin/`
- running `corepack enable --install-directory "./devbox/virtenv/pnpm_plugin/bin/"`, which adds the `pnpm` and `yarn` shim scripts
- and then adding `./devbox/virtenv/pnpm_plugin/bin/` to the `PATH` environment variable.
