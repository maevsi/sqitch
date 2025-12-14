BEGIN;

CREATE FUNCTION vibetype.jwt_update(jwt_id uuid) RETURNS vibetype.jwt
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  WITH params AS (
    SELECT
    EXTRACT(EPOCH FROM date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE))::bigint AS epoch_now,
    COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::interval AS expiry_interval
  ),
  found AS (
    SELECT j.id, (j.token).account_id AS account_id
    FROM vibetype_private.jwt j, params p
    WHERE j.id = jwt_update.jwt_id
    AND (j.token)."exp" >= p.epoch_now
    LIMIT 1
  ),
  u AS (
    UPDATE vibetype_private.jwt
    SET token.exp = EXTRACT(
      EPOCH FROM (
        date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)
        + (SELECT expiry_interval FROM params)
      )
    )
    WHERE id IN (SELECT id FROM found)
    RETURNING *
  ),
  account_update AS (
    UPDATE vibetype_private.account
    SET last_activity = DEFAULT
    WHERE id = (SELECT account_id FROM found)
    RETURNING id
  )
  SELECT token
  FROM u
  WHERE (token)."exp" >= (SELECT epoch_now FROM params);
$$;

COMMENT ON FUNCTION vibetype.jwt_update(UUID) IS 'Refreshes a JWT.';

GRANT EXECUTE ON FUNCTION vibetype.jwt_update(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
