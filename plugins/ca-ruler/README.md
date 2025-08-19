ca-ruler is a devbox plugin that acts as a thin wrapper around the npm package [ruler](https://github.com/intellectronica/ruler).

This is provided so that any non-JS projects can make use of the `ruler` binary without managing `node` or a `node_modules/` directory.

To include ruler in your project, add the following to the top level of your `devbox.json`:

```json
"include": [
  "github:cultureamp/devbox-extras?dir=plugins/ca-ruler"
]
```

All usage should follow the [ruler documentation](https://github.com/intellectronica/ruler#core-concepts).
