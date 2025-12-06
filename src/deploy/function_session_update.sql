BEGIN;

CREATE FUNCTION vibetype.session_update(session_id uuid) RETURNS vibetype.session
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _epoch_now BIGINT := EXTRACT(EPOCH FROM (SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)));
  _session vibetype.session;
BEGIN
  SELECT (token).id, (token).account_id, (token).account_username, (token)."exp", (token).guests, (token).role
  INTO _session
  FROM vibetype_private.session
  WHERE   id = session_update.session_id
  AND     (token)."exp" >= _epoch_now;

  IF (_session IS NULL) THEN
    RETURN NULL;
  ELSE
    UPDATE vibetype_private.session
    SET token.exp = EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('vibetype.session_expiry_duration', true), '1 day')::INTERVAL))
    WHERE id = session_update.session_id;

    UPDATE vibetype_private.account
    SET last_activity = DEFAULT
    WHERE account.id = _session.account_id;

    RETURN (
      SELECT token
      FROM vibetype_private.session
      WHERE   id = session_update.session_id
      AND     (token)."exp" >= _epoch_now
    );
  END IF;
END;
$$;

COMMENT ON FUNCTION vibetype.session_update(UUID) IS 'Refreshes a session.';

GRANT EXECUTE ON FUNCTION vibetype.session_update(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
