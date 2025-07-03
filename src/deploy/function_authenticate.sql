BEGIN;

CREATE FUNCTION vibetype.authenticate(
  username TEXT,
  password TEXT
) RETURNS vibetype.jwt AS $$
DECLARE
  _account_id UUID;
  _jwt_id UUID := gen_random_uuid();
  _jwt_exp BIGINT := EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::INTERVAL));
  _jwt vibetype.jwt;
  _username TEXT;
BEGIN
  IF (authenticate.username = '' AND authenticate.password = '') THEN
    -- Authenticate as guest.
    _jwt := (_jwt_id, NULL, NULL, _jwt_exp, vibetype.guest_claim_array(), 'vibetype_anonymous')::vibetype.jwt;
  ELSIF (authenticate.username IS NOT NULL AND authenticate.password IS NOT NULL) THEN
    -- if authenticate.username contains @ then treat it as an email adress otherwise as a user name
    IF (strpos(authenticate.username, '@') = 0) THEN
      SELECT id FROM vibetype.account WHERE account.username = authenticate.username INTO _account_id;
    ELSE
      SELECT id FROM vibetype_private.account WHERE account.email_address = authenticate.username INTO _account_id;
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
          AND account.password_hash = public.crypt(authenticate.password, account.password_hash)
      ) IS NOT NULL) THEN
      RAISE 'Account not verified!' USING ERRCODE = 'object_not_in_prerequisite_state';
    END IF;

    WITH updated AS (
      UPDATE vibetype_private.account
      SET (last_activity, password_reset_verification) = (DEFAULT, NULL)
      WHERE
            account.id = _account_id
        AND account.email_address_verification IS NULL -- Has been checked before, but better safe than sorry.
        AND account.password_hash = public.crypt(authenticate.password, account.password_hash)
      RETURNING *
    ) SELECT _jwt_id, updated.id, _username, _jwt_exp, NULL, 'vibetype_account'
      FROM updated
      INTO _jwt;

    IF (_jwt IS NULL) THEN
      RAISE 'Could not get token!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  INSERT INTO vibetype_private.jwt(id, token) VALUES (_jwt_id, _jwt);
  RETURN _jwt;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.authenticate(TEXT, TEXT) IS 'Creates a JWT token that will securely identify an account and give it certain permissions.\n\nError codes:\n- **P0002** when an account is not found or when the token could not be created.\n- **55000** when the account is not verified yet.';

GRANT EXECUTE ON FUNCTION vibetype.authenticate(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
