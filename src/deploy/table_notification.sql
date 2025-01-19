BEGIN;

CREATE TABLE maevsi_private.notification (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  channel            TEXT NOT NULL,
  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_acknowledged    BOOLEAN,
  payload            TEXT NOT NULL CHECK (octet_length(payload) <= 8000)
);

COMMENT ON TABLE maevsi_private.notification IS 'A notification.';
COMMENT ON COLUMN maevsi_private.notification.id IS 'The notification''s internal id.';
COMMENT ON COLUMN maevsi_private.notification.channel IS 'The notification''s channel.';
COMMENT ON COLUMN maevsi_private.notification.created_at IS 'The timestamp of the notification''s creation.';
COMMENT ON COLUMN maevsi_private.notification.is_acknowledged IS 'Whether the notification was acknowledged.';
COMMENT ON COLUMN maevsi_private.notification.payload IS 'The notification''s payload.';

COMMIT;
