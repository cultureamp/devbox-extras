ca-changesets is a devbox plugin that acts as a thin wrapper around the npm package [changesets](https://changesets-docs.vercel.app/).

This is provided so that any non-JS projects can make use of the `changeset` binary without managing `node` or a `node_modules/` directory.

To include changesets in your project, add the following to the top level of your `devbox.json`:

```json
"include": [
  "github:cultureamp/devbox-extras?dir=plugins/ca-changesets"
]
```

All usage should follow the [changesets documentation](https://changesets-docs.vercel.app/) with the exception of usage of the `yarn` command, which is not required and instead you can call the `changeset` binary directly.
