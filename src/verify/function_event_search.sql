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

  -- vibetype_private stays a black box in general (no schema USAGE for app roles), but
  -- table_contact_email_address.sql deliberately carves out one narrow, documented exception:
  -- USAGE plus a table-level SELECT grant on vibetype_private.email_address, so a guest or
  -- account holder can read the addresses they're already entitled to see through contact_email_address
  -- or account_email_address. That grant would be unreachable without USAGE, so this hardening
  -- check no longer holds and is intentionally not asserted here.
END $$;
ROLLBACK TO SAVEPOINT privileges;

ROLLBACK;
