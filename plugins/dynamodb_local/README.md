# DynamoDB local plugin

Plugin [DynamoDB local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.DownloadingAndRunning.html). Note: this isn't packaged in nixpkgs, but we have packaged in in this repo.

## Use and activation

1. Add the `dynamodb_local` package from this repo to your `devbox.json`
2. Add this plugin to the `include` section of your `devbox.json`

```json
{
  "packages": ["github:cultureamp/devbox-extras#dynamodb_local"],
  "include": ["github:cultureamp/devbox-extras?dir=plugins/dynamodb_local"]
}
```

## Services provided

- `dynamodb_local`: the dynamodb_local service

## Notable files

- `.devbox/virtenv/dynamodb_local/data/shared-local-instance.db` database location
  - this happens to be a sqlite file if you want to poke around with it
- `.devbox/virtenv/dynamodb_local/data/dynamodb-local-metadata.json`
  - seems to be a generated config file, could not find docs for it
  - you can disable telemetry in there

## Environment variables

- `DYNAMODB_DATA_PATH`
  - the directory to store the local dynamodb database file
  - defaults to `{{ .Virtenv }}/data`
- `DYNAMODB_PORT`
  - the port to run dynamodb on
  - defaults to `8000`
