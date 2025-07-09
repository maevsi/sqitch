BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

ROLLBACK;
