-- Deploy maevsi:function_account_password_change to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: schema_private
-- requires: role_account
-- requires: table_account_private
-- requires: extension_pgcrypto

BEGIN;

CREATE FUNCTION maevsi.account_password_change(
  password_current TEXT,
  password_new TEXT
) RETURNS VOID AS $$
DECLARE
  _current_account_id UUID;
BEGIN
  IF (char_length($2) < 8) THEN
      RAISE 'New password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  _current_account_id := current_setting('jwt.claims.account_id', true)::UUID;

  IF (EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.id = _current_account_id AND account.password_hash = maevsi.crypt($1, account.password_hash))) THEN
    UPDATE maevsi_private.account SET password_hash = maevsi.crypt($2, maevsi.gen_salt('bf')) WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.account_password_change(TEXT, TEXT) IS 'Allows to change an account''s password.';

GRANT EXECUTE ON FUNCTION maevsi.account_password_change(TEXT, TEXT) TO maevsi_account;

COMMIT;
