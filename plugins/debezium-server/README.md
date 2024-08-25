# CA Debezium Server Devbox Plugin

At Culture Amp, we use [Debezium Server](https://debezium.io/documentation/reference/stable/operations/debezium-server.html) to publish data to a Kafka sink via the Outbox Event Router.  The debezium-server plugin allows us to run this locally.

Use this plugin to run Debezium Server locally and capture an outbox table within a Postgresql instance, before publishing to a local Kafka cluster such as provided by the `ca-kafka-local` plugin in conjunction with `kafka-local`.

What it provides:

- Environment variables.  See [plugin.json](./plugin.json) for which variables are supplied and their values.  These variables control configuration for the source Postgresql instance and Kafka sink.  By default, the Kafka sink configuration assumes the environment variables imported by `ca-kafka-local`.  Configuration is also provided for the seeding of data in the outbox table.
- Process compose job
  - Debezium Server instance pre-configured with the outbox event router
  - readme detailing environment variables and basic usage
  - init_outbox service that assumes an existing Postgresql setup and configures the required outbox table, publication and heartbeat table for Debezium to use.
  - init_topic service that attempts to auto-create the heartbeat topic, which is required by Debezium Server.  Normally auto topic creation would suffice, but debezium server will error if the heartbeat topic does not exist.'
- Various CLI tools
    - Kafka CLI tools are included for creating the heartbeat topic
    - psql is provided and used for setting up Postgresql
    - A nodejs based populate script.  This uses kafkajs to Avro-encode sample data provided according to the defined schema, before inserting this data into your outbox table

## Usage

To start Debezium Server

Include the plugin in your `devbox.json`:
    {
      "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/main/.schema/devbox.schema.json",
      "include": [
        "github:cultureamp/devbox-extras?dir=plugins/debezium-server"
      ]
    }

You will need to add the `ca-kafka-local` plugin and follow the plugin [README.md](../ca-kafka-local/README.md).
You will also need to add `postgresql` package to your project, and correctly define the postgresql service with WAL level set to logical:

```
  postgresql:
    command: 'pg_ctl start -o "-k $PGHOST -c wal_level=logical"'
    is_daemon: true
    shutdown:
      command: pg_ctl stop -m fast
    readiness_probe:
      period_seconds: 1
      exec:
        command: pg_isready -U postgres
    availability:
      restart: always
```