BEGIN;

CREATE TABLE vibetype_private.outbox (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  channel            TEXT NOT NULL,
  is_acknowledged    BOOLEAN,
  payload            JSONB NOT NULL CHECK (pg_column_size(payload) <= 8000),

  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype_private.outbox IS 'An outbox event, captured via change data capture and published downstream.';
COMMENT ON COLUMN vibetype_private.outbox.id IS 'The outbox event''s internal id.';
COMMENT ON COLUMN vibetype_private.outbox.channel IS 'The outbox event''s channel.';
COMMENT ON COLUMN vibetype_private.outbox.is_acknowledged IS 'Whether the outbox event was acknowledged.';
COMMENT ON COLUMN vibetype_private.outbox.payload IS 'The outbox event''s payload.';
COMMENT ON COLUMN vibetype_private.outbox.created_at IS 'The timestamp of the outbox event''s creation.';

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`
GRANT SELECT ON TABLE vibetype_private.outbox TO :role_service_grafana_username;

COMMIT;
