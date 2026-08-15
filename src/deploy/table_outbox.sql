BEGIN;

CREATE TABLE vibetype_private.outbox (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aggregate_type     TEXT NOT NULL,
  aggregate_id       UUID NOT NULL,

  type               TEXT NOT NULL,
  is_acknowledged    BOOLEAN,
  payload            JSONB NOT NULL CHECK (pg_column_size(payload) <= 16000), -- base64'd encrypted content (see outbox_encrypt) needs more room than the plaintext payloads this cap was originally sized for

  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_outbox_aggregate_id ON vibetype_private.outbox USING btree (aggregate_id);

COMMENT ON TABLE vibetype_private.outbox IS 'An outbox event, captured via change data capture and published downstream.';
COMMENT ON COLUMN vibetype_private.outbox.id IS 'The outbox event''s internal id.';
COMMENT ON COLUMN vibetype_private.outbox.aggregate_type IS 'The kind of entity this outbox event is about, e.g. "account", "event", "guest" or "upload". Used as the Kafka routing key, so all types about the same aggregate type share one topic.';
COMMENT ON COLUMN vibetype_private.outbox.aggregate_id IS 'The id of the entity this outbox event is about. Not a foreign key since it references a different table depending on aggregate_type; also used as the Kafka partitioning key so that events about the same entity stay ordered relative to each other.';
COMMENT ON COLUMN vibetype_private.outbox.type IS 'The specific kind of event, e.g. "account_registration" or "event_invitation". Embedded in the payload too, since aggregate_type-based Kafka topics can carry more than one type.';
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
