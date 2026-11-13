BEGIN;

-- A session that has ended is not stored again.

CREATE OR REPLACE FUNCTION vibetype.jwt_update_guest_add(guest_id uuid) RETURNS vibetype.jwt
    LANGUAGE sql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
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
    WHERE NOT EXISTS (SELECT 1 FROM _existing_jwt_id existing_jwt WHERE existing_jwt.id IS NOT NULL)
      OR EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE jwt.id = _jwt_claims.token_id)
    ON CONFLICT (id) DO UPDATE
    SET token = EXCLUDED.token
    RETURNING token
  )
  SELECT token FROM _jwt_upsert;
$$;

CREATE OR REPLACE FUNCTION vibetype.jwt_update_attendance_add(attendance_id uuid) RETURNS vibetype.jwt
    LANGUAGE sql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
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
        WHEN existing_jwt.id IS NOT NULL THEN
          (SELECT ARRAY(SELECT DISTINCT UNNEST(vibetype.attendance_claim_array() || jwt_update_attendance_add.attendance_id) ORDER BY 1))
        ELSE ARRAY[jwt_update_attendance_add.attendance_id]
      END AS attendance_claims,
      CASE
        WHEN existing_jwt.id IS NOT NULL THEN vibetype.guest_claim_array()
        ELSE NULL
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
    WHERE NOT EXISTS (SELECT 1 FROM _existing_jwt_id existing_jwt WHERE existing_jwt.id IS NOT NULL)
      OR EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE jwt.id = _jwt_claims.token_id)
    ON CONFLICT (id) DO UPDATE
    SET token = EXCLUDED.token
    RETURNING token
  )
  SELECT token FROM _jwt_upsert;
$$;

COMMIT;
