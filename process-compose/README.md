# What is this?

This schema allows for validation of the `process-compose.yaml` file that devbox uses. It also provides autocompletion for the file in your editor.

To make use of this file you can include the schema in your file by adding the following line to the top of your `process-compose.yaml` file:

```yaml
# yaml-language-server: $schema: https://raw.githubusercontent.com/cultureamp/devbox-extras/main/process-compose/schema.yaml
```

This requires the yaml-language-server to be installed. You can install this LSP for VSCode [here](https://marketplace.visualstudio.com/items/?itemName=redhat.vscode-yaml)

## Detect process-compose.yaml files

You can configure the yaml-language-server to use this schema for all `process-compose.yaml` files by following the below.

### VSCode

By adding the following to your settings.json file:

```json
"yaml.schemas": {
  "https://raw.githubusercontent.com/cultureamp/devbox-extras/main/process-compose/schema.yaml": "/process-compose.yaml"
}
```

### Other editors

If you are using another editor, you can achieve this by adding the following to your language server settings:

```json
"yaml-language-server": {
  "settings": {
    "yaml": {
      "schemas": {
        "https://raw.githubusercontent.com/cultureamp/devbox-extras/main/process-compose/schema.yaml": "/process-compose.yaml"
      }
    }
  }
}
```
