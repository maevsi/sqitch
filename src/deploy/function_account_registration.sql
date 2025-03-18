BEGIN;

CREATE FUNCTION vibetype.account_registration(
  username TEXT,
  email_address TEXT,
  "password" TEXT,
  "language" TEXT
) RETURNS UUID AS $$
DECLARE
  _new_account_private vibetype_private.account;
  _new_account_public vibetype.account;
  _new_account_notify RECORD;
BEGIN
  IF (char_length(account_registration.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype.account WHERE account.username = account_registration.username)) THEN
    RAISE 'An account with this username already exists!' USING ERRCODE = 'unique_violation';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.email_address = account_registration.email_address)) THEN
    RAISE 'An account with this email address already exists!' USING ERRCODE = 'unique_violation';
  END IF;

  INSERT INTO vibetype_private.account(email_address, password_hash, last_activity) VALUES
    (account_registration.email_address, crypt(account_registration.password, gen_salt('bf')), CURRENT_TIMESTAMP)
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

  INSERT INTO vibetype.contact(account_id, created_by) VALUES (_new_account_private.id, _new_account_private.id);

  INSERT INTO vibetype.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', account_registration.language)
    ))
  );

  RETURN _new_account_public.id;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_registration(TEXT, TEXT, TEXT, TEXT) IS 'Creates a contact and registers an account referencing it.';

GRANT EXECUTE ON FUNCTION vibetype.account_registration(TEXT, TEXT, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
