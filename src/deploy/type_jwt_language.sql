BEGIN;

-- Stored tokens are not rewritten and read the new attribute as NULL until their next refresh.
ALTER TYPE vibetype.jwt ADD ATTRIBUTE language vibetype.language;

CREATE OR REPLACE FUNCTION vibetype.jwt_create(username text, password text) RETURNS vibetype.jwt
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
  _account_lookup AS (
    SELECT
      CASE
        WHEN position('@' IN jwt_create.username) = 0 THEN
          (SELECT id FROM vibetype.account WHERE username = jwt_create.username)
        ELSE
          (SELECT id FROM vibetype_private.account WHERE email_address = jwt_create.username)
      END AS id
  ),
  _account_validation AS MATERIALIZED (
    SELECT
      account_lookup.id,
      public_account.username,
      private_account.email_address_verification IS NOT NULL AS email_not_verified,
      -- An unknown account hashes as well, so the time taken does not tell it apart from a wrong password.
      COALESCE(
        private_account.password_hash = public.crypt(jwt_create.password, private_account.password_hash),
        public.crypt(jwt_create.password, public.gen_salt('bf', 10)) IS NULL
      ) AS password_valid
    FROM _account_lookup account_lookup
    LEFT JOIN vibetype.account public_account ON public_account.id = account_lookup.id
    LEFT JOIN vibetype_private.account private_account ON private_account.id = account_lookup.id
  ),
  _authenticated_account AS (
    SELECT id, username
    FROM _account_validation
    WHERE id IS NOT NULL
      AND password_valid = true
      AND email_not_verified = false
  ),
  _account_activity_update AS (
    UPDATE vibetype_private.account
    SET
      last_activity = DEFAULT,
      -- A hash with a lower work factor is replaced on sign-in, the only time the password is known.
      password_hash = CASE
        WHEN account.password_hash LIKE '$2a$10$%' THEN account.password_hash
        ELSE public.crypt(jwt_create.password, public.gen_salt('bf', 10))
      END,
      password_reset_verification = NULL
    WHERE id = (SELECT id FROM _authenticated_account)
    RETURNING id
  ),
  _jwt_expired_delete AS (
    DELETE FROM vibetype_private.jwt
    USING _current_time
    WHERE jwt.subject = (SELECT id FROM _authenticated_account)
      AND jwt.expiry < _current_time.now
  ),
  _jwt_token AS (
    SELECT
      ROW(
        NULL,
        EXTRACT(EPOCH FROM (_current_time.now + _expiry_duration.duration)),
        NULL,
        gen_random_uuid(),
        'vibetype_account',
        authenticated_account.id,
        authenticated_account.username,
        (SELECT contact.language FROM vibetype.contact WHERE contact.created_by = authenticated_account.id AND contact.account_id = authenticated_account.id)
      )::vibetype.jwt AS token
    FROM _authenticated_account authenticated_account, _current_time, _expiry_duration
    WHERE EXISTS (SELECT 1 FROM _account_activity_update)
  ),
  _jwt_insert AS (
    INSERT INTO vibetype_private.jwt (id, token)
    SELECT (token).jti, token
    FROM _jwt_token
    RETURNING token
  )
  SELECT token FROM _jwt_insert;
$$;

CREATE OR REPLACE FUNCTION vibetype.jwt_update(jwt_id uuid) RETURNS vibetype.jwt
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
    SET
      token.exp = EXTRACT(EPOCH FROM (_current_time.now + _expiry_duration.duration)),
      token.language = (SELECT contact.language FROM vibetype.contact WHERE contact.created_by = jwt.subject AND contact.account_id = jwt.subject)
    FROM _current_time, _expiry_duration
    WHERE jwt.id = (SELECT id FROM _valid_jwt)
    RETURNING token
  )
  SELECT token FROM _jwt_update;
$$;

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
  _claimed_jwt_id AS (
    SELECT NULLIF(current_setting('jwt.claims.jti', true), '')::UUID AS id
  ),
  _existing_jwt_id AS (
    SELECT
      (SELECT jwt.id FROM vibetype_private.jwt WHERE jwt.id = claimed.id) AS id,
      claimed.id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE jwt.id = claimed.id) AS is_ended
    FROM _claimed_jwt_id claimed
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
        CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.exp', true), '')::BIGINT END,
        EXTRACT(EPOCH FROM (_current_time.now + _expiry_duration.duration))
      ) AS expiration,
      COALESCE(existing_jwt.id, gen_random_uuid()) AS token_id,
      COALESCE(CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.role', true), '') END, 'vibetype_anonymous') AS role,
      CASE WHEN NOT existing_jwt.is_ended THEN vibetype.invoker_account_id() END AS account_id,
      CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.username', true), '') END AS username,
      CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.language', true), '')::vibetype.language END AS language
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
        username,
        language
      )::vibetype.jwt
    FROM _jwt_claims
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
  _claimed_jwt_id AS (
    SELECT NULLIF(current_setting('jwt.claims.jti', true), '')::UUID AS id
  ),
  _existing_jwt_id AS (
    SELECT
      (SELECT jwt.id FROM vibetype_private.jwt WHERE jwt.id = claimed.id) AS id,
      claimed.id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE jwt.id = claimed.id) AS is_ended
    FROM _claimed_jwt_id claimed
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
        CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.exp', true), '')::BIGINT END,
        EXTRACT(EPOCH FROM (_current_time.now + _expiry_duration.duration))
      ) AS expiration,
      COALESCE(existing_jwt.id, gen_random_uuid()) AS token_id,
      COALESCE(CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.role', true), '') END, 'vibetype_anonymous') AS role,
      CASE WHEN NOT existing_jwt.is_ended THEN vibetype.invoker_account_id() END AS account_id,
      CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.username', true), '') END AS username,
      CASE WHEN NOT existing_jwt.is_ended THEN NULLIF(current_setting('jwt.claims.language', true), '')::vibetype.language END AS language
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
        username,
        language
      )::vibetype.jwt
    FROM _jwt_claims
    ON CONFLICT (id) DO UPDATE
    SET token = EXCLUDED.token
    RETURNING token
  )
  SELECT token FROM _jwt_upsert;
$$;

COMMIT;
