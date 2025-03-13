BEGIN;

CREATE FUNCTION maevsi.notification_acknowledge(
  id UUID,
  is_acknowledged BOOLEAN
) RETURNS VOID AS $$
DECLARE
  update_count INTEGER;
BEGIN

  UPDATE maevsi_private.notification SET
    is_acknowledged = notification_acknowledge.is_acknowledged
  WHERE id = notification_acknowledge.id;

  GET DIAGNOSTICS update_count = ROW_COUNT;
  IF update_count = 0 THEN
    RAISE 'Notification with given id not found!' USING ERRCODE = 'no_data_found';
  END IF;

END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.notification_acknowledge(UUID, BOOLEAN) IS 'Allows to set the acknowledgement state of a notification.';

GRANT EXECUTE ON FUNCTION maevsi.notification_acknowledge(UUID, BOOLEAN) TO maevsi_anonymous;

COMMIT;
