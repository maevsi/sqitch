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

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`
-- The dashboard only needs metadata columns for its statistics.
GRANT SELECT (
  id,
  channel,
  is_acknowledged,
  created_at
) ON TABLE vibetype_private.notification TO :role_service_grafana_username;

CREATE FUNCTION vibetype.notification_acknowledge(id uuid, is_acknowledged boolean) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  IF (EXISTS (SELECT 1 FROM vibetype_private.notification WHERE "notification".id = notification_acknowledge.id)) THEN
    UPDATE vibetype_private.notification SET is_acknowledged = notification_acknowledge.is_acknowledged WHERE "notification".id = notification_acknowledge.id;
  ELSE
    RAISE 'Notification with given id not found!' USING ERRCODE = 'no_data_found';
  END IF;
END;
$$;

COMMENT ON FUNCTION vibetype.notification_acknowledge(UUID, BOOLEAN) IS 'Allows to set the acknowledgement state of a notification.\n\nError codes:\n- **P0002** when no notification with the given id is found.';

GRANT EXECUTE ON FUNCTION vibetype.notification_acknowledge(UUID, BOOLEAN) TO vibetype_anonymous;

COMMIT;
