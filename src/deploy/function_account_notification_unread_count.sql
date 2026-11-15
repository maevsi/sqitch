BEGIN;

CREATE FUNCTION vibetype.account_notification_unread_count() RETURNS integer
    LANGUAGE sql STABLE
    AS $$
  SELECT COUNT(*)::INTEGER
  FROM vibetype.account_notification
  WHERE account_id = vibetype.invoker_account_id()
    AND read_at IS NULL;
$$;

COMMENT ON FUNCTION vibetype.account_notification_unread_count() IS 'Returns the number of unread notifications of the invoker.';

GRANT EXECUTE ON FUNCTION vibetype.account_notification_unread_count() TO vibetype_account;

COMMIT;
