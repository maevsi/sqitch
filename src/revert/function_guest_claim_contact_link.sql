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

CREATE OR REPLACE FUNCTION vibetype.account_email_address_verification(code uuid) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _account vibetype_private.account;
BEGIN
  SELECT *
    FROM vibetype_private.account
    INTO _account
    WHERE account.email_address_verification = account_email_address_verification.code;

  IF (_account IS NULL) THEN
    RAISE 'Unknown verification code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.email_address_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Verification code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE vibetype_private.account
    SET email_address_verification = NULL
    WHERE email_address_verification = account_email_address_verification.code;
END;
$$;

CREATE OR REPLACE FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text, time_zone text DEFAULT 'UTC'::text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _new_account_private vibetype_private.account;
  _new_account_public vibetype.account;
  _new_account_notify RECORD;
BEGIN
  IF account_registration.birth_date > CURRENT_DATE - INTERVAL '18 years' THEN
    RAISE EXCEPTION 'The birth date must be at least 18 years in the past'
      USING ERRCODE = 'VTBDA';
  END IF;

  IF (char_length(account_registration.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'VTPLL';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype.account WHERE account.username = account_registration.username)) THEN
    RAISE 'An account with this username already exists!' USING ERRCODE = 'VTAUV';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.email_address = account_registration.email_address)) THEN
    PERFORM public.crypt(account_registration.password, public.gen_salt('bf', 10)); -- the same work as for a new account
    RETURN; -- silent fail as we cannot return meta information about users' email addresses
  END IF;

  INSERT INTO vibetype_private.account(birth_date, email_address, password_hash, last_activity) VALUES
    (account_registration.birth_date, account_registration.email_address, public.crypt(account_registration.password, public.gen_salt('bf', 10)), CURRENT_TIMESTAMP)
    RETURNING * INTO _new_account_private;

  INSERT INTO vibetype.account(id, username) VALUES
    (_new_account_private.id, account_registration.username)
    RETURNING * INTO _new_account_public;

  SELECT
    _new_account_public.username,
    _new_account_private.email_address,
    _new_account_private.email_address_verification,
    _new_account_private.email_address_verification_valid_until
  INTO _new_account_notify;

  INSERT INTO vibetype.legal_term_acceptance(account_id, legal_term_id) VALUES
    (_new_account_private.id, account_registration.legal_term_id);

  INSERT INTO vibetype.contact(account_id, created_by, language) VALUES
    (_new_account_private.id, _new_account_private.id, CASE WHEN account_registration.language IN ('de', 'en') THEN account_registration.language::vibetype.language END);

  INSERT INTO vibetype_private.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', account_registration.language, 'time_zone', account_registration.time_zone)
    ))
  );

  -- not possible to return data here as this would make the silent return above for email address duplicates distinguishable from a successful registration
END;
$$;

DROP FUNCTION vibetype_private.guest_claim_contact_link(UUID, UUID[]);

ALTER TABLE vibetype_private.account DROP COLUMN guest_claims;

COMMIT;
