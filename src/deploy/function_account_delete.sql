BEGIN;

CREATE FUNCTION vibetype.account_delete(password text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _current_account_id UUID;
BEGIN
  _current_account_id := current_setting('jwt.claims.sub')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = public.crypt(account_delete.password, account.password_hash))) THEN
    DELETE FROM vibetype.contact WHERE created_by = _current_account_id AND account_id = _current_account_id; -- needed because the ON DELETE SET NULL FK action on contact.account_id fires a BEFORE UPDATE trigger that blocks nullifying the own contact while the deleting account's JWT claims are still active in the same transaction
    DELETE FROM vibetype_private.account WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$;

COMMENT ON FUNCTION vibetype.account_delete(TEXT) IS 'Allows to delete an account.\n\nError codes:\n- **23503** when the account still has events.\n- **28P01** when the password is invalid.';

GRANT EXECUTE ON FUNCTION vibetype.account_delete(TEXT) TO vibetype_account;

COMMIT;
