BEGIN;

CREATE TABLE maevsi.notification (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  channel            TEXT NOT NULL,
  is_acknowledged    BOOLEAN,
  payload            TEXT NOT NULL CHECK (octet_length(payload) <= 8000),

  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE maevsi.notification IS 'A notification.';
COMMENT ON COLUMN maevsi.notification.id IS 'The notification''s internal id.';
COMMENT ON COLUMN maevsi.notification.channel IS 'The notification''s channel.';
COMMENT ON COLUMN maevsi.notification.is_acknowledged IS 'Whether the notification was acknowledged.';
COMMENT ON COLUMN maevsi.notification.payload IS 'The notification''s payload.';
COMMENT ON COLUMN maevsi.notification.created_at IS 'The timestamp of the notification''s creation.';

COMMIT;
