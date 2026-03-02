BEGIN;

CREATE FUNCTION vibetype.jwt_update(jwt_id uuid) RETURNS vibetype.jwt
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  WITH
  _current_time AS (
    SELECT date_trunc('second', CURRENT_TIMESTAMP) AS now
  ),
  _expiry_duration AS (
    SELECT COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::INTERVAL AS duration
  ),
  _valid_jwt AS (
    SELECT
      jwt.id,
      jwt.token,
      (jwt.token).sub AS account_id
    FROM vibetype_private.jwt, _current_time
    WHERE jwt.id = jwt_update.jwt_id
      AND (jwt.token).exp >= EXTRACT(EPOCH FROM _current_time.now)
  ),
  _account_activity_update AS (
    UPDATE vibetype_private.account
    SET last_activity = DEFAULT
    WHERE id = (SELECT account_id FROM _valid_jwt)
    RETURNING id
  ),
  _jwt_update AS (
    UPDATE vibetype_private.jwt
    SET token.exp = EXTRACT(EPOCH FROM (_current_time.now + _expiry_duration.duration))
    FROM _current_time, _expiry_duration
    WHERE jwt.id = (SELECT id FROM _valid_jwt)
    RETURNING token
  )
  SELECT token FROM _jwt_update;
$$;

COMMENT ON FUNCTION vibetype.jwt_update(UUID) IS 'Refreshes a JWT.';

GRANT EXECUTE ON FUNCTION vibetype.jwt_update(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
