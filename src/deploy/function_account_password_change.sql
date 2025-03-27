BEGIN;

CREATE FUNCTION vibetype.account_password_change(
  password_current TEXT,
  password_new TEXT
) RETURNS VOID AS $$
DECLARE
  _current_account_id UUID;
BEGIN
  IF (char_length(account_password_change.password_new) < 8) THEN
      RAISE 'New password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = public.crypt(account_password_change.password_current, account.password_hash))) THEN
    UPDATE vibetype_private.account SET password_hash = public.crypt(account_password_change.password_new, public.gen_salt('bf')) WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_password_change(TEXT, TEXT) IS 'Allows to change an account''s password.';

GRANT EXECUTE ON FUNCTION vibetype.account_password_change(TEXT, TEXT) TO vibetype_account;

COMMIT;
