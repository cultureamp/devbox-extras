# Corepack plugin

This plugin sets up [Corepack](https://github.com/nodejs/corepack/), a NodeJS feature to automatically install the correct version of Yarn or PNPM.

When using corepack, running `pnpm` or `yarn` will always use the correct version as defined in the `packageManager` field of the project's `package.json` file.

## Use and activation

1. Make sure you already have a `nodejs` listed as one of your packages in `devbox.json`. You don't need to list `pnpm` or `yarn`:

```json
{
  "packages": ["nodejs@18.19.1"]
}
```

1. Add this plugin to the `include` section of your `devbox.json`:

```json
{
  "packages": ["nodejs@18.19.1"],
  "include": ["github:cultureamp/devbox-extras?dir=plugins/corepack"]
}
```

2. Ensure your `package.json` sets a `packageManager` field, for example:

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

When you run `pnpm -v` or `yarn -v` you should see that the versions used match what you've set in the `packageManager` field.

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

Corepack is a tool included with Node.js that manages PNPM and Yarn versions for you, installing the requested versions as needed and switching seamlessly. Using Corepack would mean that we don't need Devbox / Nix to provide pnpm or Yarn binaries.

But corepack by default tries to install shim scripts for both `yarn` and `pnpm` in the same directory that `node` is found in. Unfortunately when using devbox, the `node` binary is in the Nix store, which is read only, so Corepack gives an error similar to:

> `Internal Error: EACCES: permission denied, unlink '/nix/store/0r6wvd9rr6lsrv8j9b3nv9s9lw7vfb37-profile/bin/pnpm'`

This Devbox plugin works by:

- creating a folder in `.devbox/virtenv/pnpm_plugin/bin/`
- running `corepack enable --install-directory "./devbox/virtenv/pnpm_plugin/bin/"`, which adds the `pnpm` and `yarn` shim scripts
- and then adding `./devbox/virtenv/pnpm_plugin/bin/` to the `PATH` environment variable.
