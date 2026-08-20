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
    UPDATE vibetype.contact SET account_deleted = TRUE WHERE account_id = _current_account_id; -- marks peer contacts (created by other accounts) that reference this account, before the FK's ON DELETE SET NULL clears account_id below, so contact_identity_check always sees a valid state and these contacts survive the deletion instead of being wiped from someone else's contact book
    DELETE FROM vibetype_private.account WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$;

COMMENT ON FUNCTION vibetype.account_delete(TEXT) IS 'Allows to delete an account. Peer contacts that other accounts created referencing this account are kept, with account_id cleared and account_deleted set to true, instead of being deleted.\n\nError codes:\n- **23503** when the account still has events.\n- **28P01** when the password is invalid.';

GRANT EXECUTE ON FUNCTION vibetype.account_delete(TEXT) TO vibetype_account;

COMMIT;
