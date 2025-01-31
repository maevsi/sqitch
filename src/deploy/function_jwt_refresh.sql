BEGIN;

CREATE FUNCTION maevsi.jwt_refresh(
  jwt_id UUID
) RETURNS maevsi.jwt AS $$
DECLARE
  _epoch_now BIGINT := EXTRACT(EPOCH FROM (SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)));
  _jwt maevsi.jwt;
BEGIN
  SELECT (token).id, (token).account_id, (token).account_username, (token)."exp", (token).guests, (token).role INTO _jwt
  FROM maevsi_private.jwt
  WHERE   id = $1
  AND     (token)."exp" >= _epoch_now;

  IF (_jwt IS NULL) THEN
    RETURN NULL;
  ELSE
    UPDATE maevsi_private.jwt
    SET token.exp = EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('maevsi.jwt_expiry_duration', true), '1 day')::INTERVAL))
    WHERE id = $1;

    UPDATE maevsi_private.account
    SET last_activity = DEFAULT
    WHERE account.id = _jwt.account_id;

    RETURN (
      SELECT token
      FROM maevsi_private.jwt
      WHERE   id = $1
      AND     (token)."exp" >= _epoch_now
    );
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.jwt_refresh(UUID) IS 'Refreshes a JWT.';

GRANT EXECUTE ON FUNCTION maevsi.jwt_refresh(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
