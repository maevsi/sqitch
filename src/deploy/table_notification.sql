-- Deploy maevsi:table_event to pg
-- requires: schema_private

BEGIN;

CREATE TABLE maevsi_private.notification (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  channel            TEXT NOT NULL,
  is_acknowledged    BOOLEAN,
  payload            TEXT NOT NULL CHECK (octet_length(payload) <= 8000),
  "timestamp"        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE maevsi_private.notification IS 'A notification.';
COMMENT ON COLUMN maevsi_private.notification.id IS 'The notification''s internal id.';
COMMENT ON COLUMN maevsi_private.notification.channel IS 'The notification''s channel.';
COMMENT ON COLUMN maevsi_private.notification.is_acknowledged IS 'Whether the notification was acknowledged.';
COMMENT ON COLUMN maevsi_private.notification.payload IS 'The notification''s payload.';
COMMENT ON COLUMN maevsi_private.notification.timestamp IS 'The notification''s timestamp.';

CREATE FUNCTION maevsi_private.notify() RETURNS TRIGGER AS $$
BEGIN
  IF (NEW.is_acknowledged IS NOT TRUE) THEN
    PERFORM pg_notify(
      NEW.channel,
      jsonb_pretty(jsonb_build_object(
          'id', NEW.id,
          'payload', NEW.payload
      ))
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_private.notify() IS 'Triggers a pg_notify for the given data.';

COMMIT;
