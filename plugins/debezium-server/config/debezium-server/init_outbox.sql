\echo Creating debezium user: :debezium_user
\echo Using schema: :schema_name
\echo Creating outbox table: :outbox_table_name
\echo Creating heartbeat table: :heartbeat_table_name

SET vars.debezium_user TO :debezium_user;
SET vars.debezium_password TO :debezium_password;
SET vars.schema_name TO :schema_name;
SET vars.outbox_table_name TO :outbox_table_name;
SET vars.heartbeat_table_name TO :heartbeat_table_name;

-- Basic permissions
DO $$
DECLARE
    debezium_user text := current_setting('vars.debezium_user');
    debezium_password text := current_setting('vars.debezium_password');
BEGIN
    -- Create role if it does not exist
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dbz_replication_role') THEN
        CREATE ROLE dbz_replication_role REPLICATION LOGIN;
    END IF;

    -- Create user if it does not exist
    IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_user WHERE usename = debezium_user) THEN
        EXECUTE FORMAT('CREATE USER %s WITH PASSWORD ''%s''', debezium_user, debezium_password);
    END IF;

    -- Alter user to add REPLICATION permission
    EXECUTE FORMAT('ALTER USER %s WITH REPLICATION', debezium_user);

    -- Grant role to user and postgres
    EXECUTE FORMAT('GRANT dbz_replication_role to %s', debezium_user);
    GRANT dbz_replication_role to postgres;
END $$;

-- Outbox table
DO $$
DECLARE
    schema_name text := current_setting('vars.schema_name');
    outbox_table_name text := current_setting('vars.outbox_table_name');
BEGIN
    -- Create table if it does not exist
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = outbox_table_name AND schemaname = schema_name) THEN
        EXECUTE FORMAT('
        CREATE TABLE %s.%s (
            id UUID NOT NULL PRIMARY KEY,
            topic TEXT NOT NULL,
            message_key UUID NOT NULL,
            partition_key UUID NOT NULL,
            payload BYTEA NOT NULL,
            account_id UUID NOT NULL,
            created_at TIMESTAMP NOT NULL
        )', schema_name, outbox_table_name);
    END IF;

    -- Set table owner if not already set
    IF (SELECT tableowner FROM pg_tables WHERE tablename = outbox_table_name AND schemaname = schema_name) != 'dbz_replication_role' THEN
        EXECUTE FORMAT('ALTER TABLE %s.%s OWNER TO dbz_replication_role', schema_name, outbox_table_name);
    END IF;
END $$;

-- Create heartbeat table
DO $$
DECLARE
    schema_name text := current_setting('vars.schema_name');
    heartbeat_table_name text := current_setting('vars.heartbeat_table_name');
BEGIN
    -- Create table if it does not exist
    EXECUTE FORMAT('
    CREATE TABLE IF NOT EXISTS %s.%s (
    id SERIAL PRIMARY KEY,
    heartbeat_recorded TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );', schema_name, heartbeat_table_name);

    EXECUTE FORMAT('ALTER TABLE %s.%s OWNER TO dbz_replication_role;', schema_name, heartbeat_table_name);
END $$;

-- Create publication
DO $$
DECLARE
    schema_name text := current_setting('vars.schema_name');
    outbox_table_name text := current_setting('vars.outbox_table_name');
    heartbeat_table_name text := current_setting('vars.heartbeat_table_name');
BEGIN
    -- Create publication if it does not exist
    IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'dbz_publication' AND schemaname = schema_name AND tablename = outbox_table_name) THEN
        DROP PUBLICATION IF EXISTS dbz_publication;
        EXECUTE FORMAT('CREATE PUBLICATION dbz_publication FOR TABLE %s.%s, %s.%s;', schema_name, outbox_table_name, schema_name, heartbeat_table_name);
    END IF;

    -- Set publication owner if not already set
	ALTER PUBLICATION dbz_publication OWNER TO dbz_replication_role;
END $$;

-- Allow UUID extension for inserting into the outbox table
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
