# CA Kafka Local Devbox Plugin

At Culture Amp we use Kafka for sharing data between services, and the private [kafka-local](https://github.com/cultureamp/kafka-local) repo is how we run that locally.

Use this plugin to interact with `kafka-local` in your service. You still need to launch Kafka on your own, but this plugin provides environment variables and tools to make it easy for your project to connect to `kafka-local`.

What it provides:

- Environment variables
  - `KAFKA_BROKERS` set to `"localhost:14231"`
  - `SCHEMA_REGISTRY_URL` set to `"localhost:14228"`
- Process Compose job
  - Will print information to the terminal about Kafka, once `kafka-local` is up and running.
  - Allows you to add a `depends_on` clause so other services wait for `kafka-local`.

## Usage

To start Kafka

- Use [Hotel CLI](https://github.com/cultureamp/hotel)
- Run `hotel services up kafka-local`
- In your repo run `devbox services up`

Include the plugin in your `devbox.json`:

    {
      "$schema": "https://raw.githubusercontent.com/jetify-com/devbox/main/.schema/devbox.schema.json",
      "include": [
        "github:cultureamp/devbox-extras?dir=plugins/ca-kafka-local"
      ]
    }

You can have another service depend on Kafka in your `process-compose.yaml`:

    projectors_process:
      command: "./gradlew run-projectors"
      depends_on:
        kafka_local:
          condition: process_healthy

## Anti-patterns to avoid: circular dependency on hotel

Please don't start Kafka within your projects `process-compose.yaml` file. For example

    # PLEASE DO NOT DO THIS
    kafka:
      command: hotel services up kafka-local

We don't want to set up circular loops where Hotel launches `devbox services up` and then this launches Hotel again.

For now run Hotel commands in a separate terminal. In future we might provide helpers in Hotel that launch services in your project as well as projects you depend on.
