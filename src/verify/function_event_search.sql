BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.tsquery_prefix(regconfig, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege on tsquery_prefix';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.tsquery_prefix(regconfig, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege on tsquery_prefix';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

ROLLBACK;
