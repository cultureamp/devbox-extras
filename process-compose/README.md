This schema allows for validation and autocompletion of the `process-compose.yaml` file that devbox uses.

To make use of this file you can include the schema in your file by adding the following line to the top of your `process-compose.yaml` file:

```yaml
# yaml-language-server: $schema: https://raw.githubusercontent.com/cultureamp/devbox-extras/main/process-compose/schema.yaml
```

This requires the yaml-language-server to be installed. You can install an extension for VSCode that provides this functionality [here](https://marketplace.visualstudio.com/items/?itemName=redhat.vscode-yaml)
