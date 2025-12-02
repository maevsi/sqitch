BEGIN;

CREATE FUNCTION vibetype.session_create(username text, password text) RETURNS vibetype.session
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account_id UUID;
  _session_id UUID := gen_random_uuid();
  _session_exp BIGINT := EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::INTERVAL));
  _session vibetype.session;
  _username TEXT;
BEGIN
  IF (session_create.username = '' AND session_create.password = '') THEN
    -- Create session as guest.
    _session := (_session_id, NULL, NULL, _session_exp, vibetype.guest_claim_array(), 'vibetype_anonymous')::vibetype.session;
  ELSIF (session_create.username IS NOT NULL AND session_create.password IS NOT NULL) THEN
    -- if session_create.username contains @ then treat it as an email adress otherwise as a user name
    IF (strpos(session_create.username, '@') = 0) THEN
      SELECT id FROM vibetype.account WHERE account.username = session_create.username INTO _account_id;
    ELSE
      SELECT id FROM vibetype_private.account WHERE account.email_address = session_create.username INTO _account_id;
    END IF;

    IF (_account_id IS NULL) THEN
      RAISE 'Account not found!' USING ERRCODE = 'no_data_found';
    END IF;

    SELECT account.username INTO _username FROM vibetype.account WHERE id = _account_id;

    IF ((
        SELECT account.email_address_verification
        FROM vibetype_private.account
        WHERE
              account.id = _account_id
          AND account.password_hash = public.crypt(session_create.password, account.password_hash)
      ) IS NOT NULL) THEN
      RAISE 'Account not verified!' USING ERRCODE = 'object_not_in_prerequisite_state';
    END IF;

    WITH updated AS (
      UPDATE vibetype_private.account
      SET (last_activity, password_reset_verification) = (DEFAULT, NULL)
      WHERE
            account.id = _account_id
        AND account.email_address_verification IS NULL -- Has been checked before, but better safe than sorry.
        AND account.password_hash = public.crypt(session_create.password, account.password_hash)
      RETURNING *
    ) SELECT _session_id, updated.id, _username, _session_exp, NULL, 'vibetype_account'
      FROM updated
      INTO _session;

    IF (_session IS NULL) THEN
      RAISE 'Could not get token!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  INSERT INTO vibetype_private.session(id, token) VALUES (_session_id, _session);
  RETURN _session;
END;
$$;

COMMENT ON FUNCTION vibetype.session_create(TEXT, TEXT) IS 'Creates a session token that will securely identify an account and give it certain permissions.\n\nError codes:\n- **P0002** when an account is not found or when the token could not be created.\n- **55000** when the account is not verified yet.';

GRANT EXECUTE ON FUNCTION vibetype.session_create(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
