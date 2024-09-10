import pgPromise from "pg-promise";
import { SchemaRegistry, SchemaType } from "@kafkajs/confluent-schema-registry";
import { readFileSync } from "fs";
import { v4 as uuid } from "uuid";

// Schema and sample data configuration
const registry = new SchemaRegistry({
  host: `http://${process.env.SCHEMA_REGISTRY_URL}`,
});
const schemaPath = process.env.SCHEMA_PATH;
const sampleDataPath = process.env.SAMPLE_DATA_PATH;

// Kafka sink configuration
const outboxTable = process.env.OUTBOX_TABLE;
const targetTopic = process.env.TARGET_TOPIC;

// Postgres source configuration
const dbSchema = process.env.DB_SCHEMA;
const dbHost = process.env.DB_HOST;
const dbPort = parseInt(process.env.DB_PORT);
const dbName = process.env.DB_NAME;
const dbUsername = process.env.DB_USERNAME;
const dbPassword = process.env.DB_PASSWORD;

let db: pgPromise.IDatabase<{}>;

const connectDatabase = () => {
  db = pgPromise()({
    host: dbHost,
    port: dbPort,
    database: dbName,
    user: dbUsername,
    password: dbPassword,
  });
};

const disconnectDatabase = async () => {
  await db.$pool.end();
};

const registerSchema = async () => {
  const schema = readFileSync(schemaPath, "utf-8");
  const { id } = await registry.register({
    type: SchemaType.AVRO,
    schema,
  });
  console.log(`Auto-registered schema ${schemaPath} with id ${id}`);

  return id;
};

const encodePayload = async (schemaId: number, payload: any) => {
  const encodedPayload = await registry.encode(schemaId, payload);

  return encodedPayload;
};

const addToOutboxTable = async (payload: Buffer) => {
  const id = uuid();
  const messageKey = uuid();
  const partitionKey = uuid();
  const accountId = uuid();
  const createdAt = new Date().toISOString();

  console.log(
    `Publishing encoded payload to table ${dbSchema}.${outboxTable} with target topic ${targetTopic}`
  );

  await db.none(
    `INSERT INTO ${dbSchema}.${outboxTable} (id, topic, message_key, partition_key, payload, account_id, created_at) VALUES (\${id}, \${topic}, \${message_key}, \${partition_key}, \${payload}, \${account_id}, \${created_at})`,
    {
      id: id,
      topic: targetTopic,
      message_key: messageKey,
      partition_key: partitionKey,
      payload: payload,
      account_id: accountId,
      created_at: createdAt,
    }
  );
};

(async () => {
  try {
    const sampleData = readFileSync(sampleDataPath, "utf8");
    const sampleJson = JSON.parse(sampleData);

    connectDatabase();

    const schemaId = await registerSchema();
    for (const payload of sampleJson) {
      const encodedPayload = await encodePayload(schemaId, payload);
      addToOutboxTable(encodedPayload);
    }
    disconnectDatabase();
  } catch (error) {
    console.error("Error: ", error);
  }
})();
