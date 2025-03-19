BEGIN;

CREATE TABLE vibetype.notification (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  channel            TEXT NOT NULL,
  is_acknowledged    BOOLEAN,
  payload            TEXT NOT NULL CHECK (octet_length(payload) <= 8000),

  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype.notification IS 'A notification.';
COMMENT ON COLUMN vibetype.notification.id IS 'The notification''s internal id.';
COMMENT ON COLUMN vibetype.notification.channel IS 'The notification''s channel.';
COMMENT ON COLUMN vibetype.notification.is_acknowledged IS 'Whether the notification was acknowledged.';
COMMENT ON COLUMN vibetype.notification.payload IS 'The notification''s payload.';
COMMENT ON COLUMN vibetype.notification.created_at IS 'The timestamp of the notification''s creation.';

COMMIT;
