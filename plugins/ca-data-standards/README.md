ca-data-standards is a devbox plugin that performs Culture Amp data standards validation logic against Avro schemas. It uses [data-standards-cli](https://github.com/cultureamp/data-standards/blob/main/packages/cli/README.md#cli-pacakge) under the hood.

To include ca-data-standards in your project, add the following to the top level of your `devbox.json`:

```json
"include": [
  "github:cultureamp/devbox-extras?dir=plugins/ca-data-standards"
]
```
You can then use `data-standards-validate` command in your devbox shell.
See [CLI options](https://github.com/cultureamp/data-standards/blob/main/packages/cli/README.md#cli-options) for more info.
