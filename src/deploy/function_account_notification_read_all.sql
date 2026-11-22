BEGIN;

CREATE FUNCTION vibetype.account_notification_read_all() RETURNS integer
    LANGUAGE sql
    AS $$
  WITH _read AS (
    UPDATE vibetype.account_notification
    SET read_at = CURRENT_TIMESTAMP
    WHERE account_id = vibetype.invoker_account_id()
      AND read_at IS NULL
    RETURNING 1
  )
  SELECT COUNT(*)::INTEGER FROM _read;
$$;

COMMENT ON FUNCTION vibetype.account_notification_read_all() IS 'Marks all unread notifications of the invoker as read and returns their number.';

GRANT EXECUTE ON FUNCTION vibetype.account_notification_read_all() TO vibetype_account;

COMMIT;
