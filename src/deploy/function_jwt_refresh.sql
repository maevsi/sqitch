BEGIN;

CREATE FUNCTION vibetype.jwt_refresh(jwt_id uuid) RETURNS vibetype.jwt
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _epoch_now BIGINT := EXTRACT(EPOCH FROM (SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)));
  _jwt vibetype.jwt;
BEGIN
  SELECT (token).id, (token).account_id, (token).account_username, (token)."exp", (token).guests, (token).role
  INTO _jwt
  FROM vibetype_private.jwt
  WHERE   id = jwt_refresh.jwt_id
  AND     (token)."exp" >= _epoch_now;

  IF (_jwt IS NULL) THEN
    RETURN NULL;
  ELSE
    UPDATE vibetype_private.jwt
    SET token.exp = EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::INTERVAL))
    WHERE id = jwt_refresh.jwt_id;

    UPDATE vibetype_private.account
    SET last_activity = DEFAULT
    WHERE account.id = _jwt.account_id;

    RETURN (
      SELECT token
      FROM vibetype_private.jwt
      WHERE   id = jwt_refresh.jwt_id
      AND     (token)."exp" >= _epoch_now
    );
  END IF;
END;
$$;

COMMENT ON FUNCTION vibetype.jwt_refresh(UUID) IS 'Refreshes a JWT.';

GRANT EXECUTE ON FUNCTION vibetype.jwt_refresh(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
