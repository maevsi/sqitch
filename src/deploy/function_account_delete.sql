BEGIN;

CREATE FUNCTION vibetype.account_delete(
  password TEXT
) RETURNS VOID AS $$
DECLARE
  _current_account_id UUID;
BEGIN
  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = public.crypt(account_delete.password, account.password_hash))) THEN
    DELETE FROM vibetype_private.account WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_delete(TEXT) IS 'Allows to delete an account.\n\nError codes:\n- **23503** when the account still has events.\n- **28P01** when the password is invalid.';

GRANT EXECUTE ON FUNCTION vibetype.account_delete(TEXT) TO vibetype_account;

COMMIT;
