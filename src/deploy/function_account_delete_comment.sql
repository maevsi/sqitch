BEGIN;

COMMENT ON FUNCTION vibetype.account_delete(TEXT) IS E'Allows to delete an account.\n\nError codes:\n- **28P01** when the password is invalid.\n\nDeleting an account that organizes many events can take several seconds.';

COMMIT;
