BEGIN;

CREATE FUNCTION vibetype.jwt_update_guest_add(guest_id uuid) RETURNS vibetype.jwt
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  WITH
  _current_time AS (
    SELECT date_trunc('second', CURRENT_TIMESTAMP) AS now
  ),
  _expiry_duration AS (
    SELECT COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::INTERVAL AS duration
  ),
  _existing_jwt_id AS (
    SELECT NULLIF(current_setting('jwt.claims.jti', true), '')::UUID AS id
  ),
  _jwt_claims AS (
    SELECT
      CASE
        WHEN existing_jwt.id IS NOT NULL THEN vibetype.attendance_claim_array()
        ELSE NULL
      END AS attendance_claims,
      CASE
        WHEN existing_jwt.id IS NOT NULL THEN
          (SELECT ARRAY(SELECT DISTINCT UNNEST(vibetype.guest_claim_array() || jwt_update_guest_add.guest_id) ORDER BY 1))
        ELSE ARRAY[jwt_update_guest_add.guest_id]
      END AS guest_claims,
      COALESCE(
        NULLIF(current_setting('jwt.claims.exp', true), '')::BIGINT,
        EXTRACT(EPOCH FROM (_current_time.now + _expiry_duration.duration))
      ) AS expiration,
      COALESCE(existing_jwt.id, gen_random_uuid()) AS token_id,
      COALESCE(NULLIF(current_setting('jwt.claims.role', true), ''), 'vibetype_anonymous') AS role,
      vibetype.invoker_account_id() AS account_id,
      NULLIF(current_setting('jwt.claims.username', true), '') AS username
    FROM _existing_jwt_id existing_jwt, _current_time, _expiry_duration
  ),
  _jwt_upsert AS (
    INSERT INTO vibetype_private.jwt (id, token)
    SELECT
      token_id,
      ROW(
        attendance_claims,
        expiration,
        guest_claims,
        token_id,
        role,
        account_id,
        username
      )::vibetype.jwt
    FROM _jwt_claims
    ON CONFLICT (id) DO UPDATE
    SET token = EXCLUDED.token
    RETURNING token
  )
  SELECT token FROM _jwt_upsert;
$$;

COMMENT ON FUNCTION vibetype.jwt_update_guest_add(UUID) IS 'Adds a guest claim to the current session.';

GRANT EXECUTE ON FUNCTION vibetype.jwt_update_guest_add(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
