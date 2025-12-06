BEGIN;

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
