BEGIN;

CREATE TABLE vibetype_private.outbox (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aggregate_id       UUID NOT NULL,

  channel            TEXT NOT NULL,
  is_acknowledged    BOOLEAN,
  payload            JSONB NOT NULL CHECK (pg_column_size(payload) <= 8000),

  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outbox_aggregate_id ON vibetype_private.outbox USING btree (aggregate_id);

COMMENT ON TABLE vibetype_private.outbox IS 'An outbox event, captured via change data capture and published downstream.';
COMMENT ON COLUMN vibetype_private.outbox.id IS 'The outbox event''s internal id.';
COMMENT ON COLUMN vibetype_private.outbox.aggregate_id IS 'The id of the entity this outbox event is about, e.g. the event, account or guest id, depending on channel. Not a foreign key since it references a different table depending on channel; also used as the Kafka partitioning key so that events about the same entity stay ordered relative to each other.';
COMMENT ON COLUMN vibetype_private.outbox.channel IS 'The outbox event''s channel.';
COMMENT ON COLUMN vibetype_private.outbox.is_acknowledged IS 'Whether the outbox event was acknowledged.';
COMMENT ON COLUMN vibetype_private.outbox.payload IS 'The outbox event''s payload.';
COMMENT ON COLUMN vibetype_private.outbox.created_at IS 'The timestamp of the outbox event''s creation.';

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`
GRANT SELECT ON TABLE vibetype_private.outbox TO :role_service_grafana_username;

-- TODO: periodically purge acknowledged outbox events once they've had a chance to be captured
-- by Debezium and processed downstream. Requires confirming pg_cron is available in the
-- Postgres image `stack` runs; if not, this needs to move to an external scheduled job instead.
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- SELECT cron.schedule(
--   'outbox-purge',
--   '0 3 * * *',
--   $$DELETE FROM vibetype_private.outbox WHERE is_acknowledged AND created_at < now() - INTERVAL '30 days'$$
-- );

COMMIT;
