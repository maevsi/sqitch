BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_search_rank(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege on event_search_rank';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_search_rank(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have EXECUTE privilege on event_search_rank';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.tsquery_prefix(regconfig, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account should not have direct EXECUTE privilege on tsquery_prefix';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.tsquery_prefix(regconfig, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have direct EXECUTE privilege on tsquery_prefix';
  END IF;

  IF (SELECT pg_catalog.has_schema_privilege('vibetype_account', 'vibetype_private', 'USAGE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account should not have USAGE privilege on vibetype_private';
  END IF;

  IF (SELECT pg_catalog.has_schema_privilege('vibetype_anonymous', 'vibetype_private', 'USAGE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have USAGE privilege on vibetype_private';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

ROLLBACK;
