BEGIN;

COMMENT ON FUNCTION vibetype.account_delete(TEXT) IS 'Allows to delete an account.\n\nError codes:\n- **23503** when the account still has events.\n- **28P01** when the password is invalid.';

COMMIT;
