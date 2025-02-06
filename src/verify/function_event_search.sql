BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.event_search(TEXT, maevsi.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: maevsi_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.event_search(TEXT, maevsi.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: maevsi_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

ROLLBACK;
