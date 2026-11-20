BEGIN;

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

DROP FUNCTION vibetype_private.guest_claim_contact_link(UUID);

COMMIT;
