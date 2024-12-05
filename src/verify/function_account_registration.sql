-- Verify maevsi:function_account_registration on pg

BEGIN;

SAVEPOINT function_privileges_for_roles;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.account_registration(TEXT, TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: maevsi_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.account_registration(TEXT, TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: maevsi_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT function_privileges_for_roles;

SAVEPOINT account_creation;
DO $$
BEGIN
  PERFORM maevsi.account_registration('username', 'e@ma.il', 'password', 'en');
END $$;
ROLLBACK TO SAVEPOINT account_creation;

ROLLBACK;
