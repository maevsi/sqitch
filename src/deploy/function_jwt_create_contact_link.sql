BEGIN;

-- Links each contact behind the session's guest claims to the account signing in, so its invitations outlast the session.
-- A contact is skipped when its creator already has one for the account, which the unique constraint on `created_by` and `account_id` would reject.
CREATE FUNCTION vibetype_private.guest_claim_contact_link(account_id UUID) RETURNS INTEGER
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
  _count INTEGER;
  _invoker_account_id TEXT := current_setting('jwt.claims.sub', true);
BEGIN
  -- The contact update trigger rejects updates without an invoker, and the guest claims should exclude the events of accounts the account blocks.
  PERFORM set_config('jwt.claims.sub', guest_claim_contact_link.account_id::TEXT, true);

  WITH _contact AS (
    SELECT DISTINCT ON (contact.created_by) contact.id
    FROM vibetype.guest
    INNER JOIN vibetype.contact ON contact.id = guest.contact_id
    WHERE guest.id = ANY (vibetype.guest_claim_array())
      AND contact.account_id IS NULL
      AND NOT EXISTS (
        SELECT 1
        FROM vibetype.contact existing
        WHERE existing.created_by = contact.created_by
          AND existing.account_id = guest_claim_contact_link.account_id
      )
    ORDER BY contact.created_by, contact.created_at
  )
  UPDATE vibetype.contact
  SET account_id = guest_claim_contact_link.account_id
  FROM _contact
  WHERE contact.id = _contact.id;

  GET DIAGNOSTICS _count = ROW_COUNT;

  PERFORM set_config('jwt.claims.sub', COALESCE(_invoker_account_id, ''), true);

  RETURN _count;
END;
$$;

COMMENT ON FUNCTION vibetype_private.guest_claim_contact_link(UUID) IS 'Links the contacts of the current guest claims to the given account, skipping a contact whose creator already has one for the account. Returns the number of linked contacts.';

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
  _guest_claim_contact_link AS (
    SELECT vibetype_private.guest_claim_contact_link(authenticated_account.id)
    FROM _authenticated_account authenticated_account
    WHERE EXISTS (SELECT 1 FROM _account_activity_update)
  ),
  _jwt_insert AS (
    INSERT INTO vibetype_private.jwt (id, token)
    SELECT (token).jti, token
    FROM _jwt_token
    RETURNING token
  )
  SELECT token FROM _jwt_insert, _guest_claim_contact_link;
$$;

COMMIT;
