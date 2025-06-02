BEGIN;

CREATE TABLE vibetype_private.notification (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  channel            TEXT NOT NULL,
  is_acknowledged    BOOLEAN,
  payload            TEXT NOT NULL CHECK (octet_length(payload) <= 8000),

  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype_private.notification IS 'A notification.';
COMMENT ON COLUMN vibetype_private.notification.id IS 'The notification''s internal id.';
COMMENT ON COLUMN vibetype_private.notification.channel IS 'The notification''s channel.';
COMMENT ON COLUMN vibetype_private.notification.is_acknowledged IS 'Whether the notification was acknowledged.';
COMMENT ON COLUMN vibetype_private.notification.payload IS 'The notification''s payload.';
COMMENT ON COLUMN vibetype_private.notification.created_at IS 'The timestamp of the notification''s creation.';

\set role_service_grafana_username `cat /run/secrets/postgres_role_service_grafana_username`
GRANT SELECT ON TABLE vibetype_private.notification TO :role_service_grafana_username;

COMMIT;
