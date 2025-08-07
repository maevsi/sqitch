BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.account_ids_blocking_the_current_account()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.account_ids_blocking_the_current_account()', 'EXECUTE'));
END $$;

ROLLBACK;
