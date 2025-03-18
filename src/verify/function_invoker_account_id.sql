BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.invoker_account_id()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.invoker_account_id()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_tusd', 'vibetype.invoker_account_id()', 'EXECUTE'));
END $$;

ROLLBACK;
