BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`
SET local role.vibetype_username TO :'role_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.invoker_account_id()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.invoker_account_id()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege(current_setting('role.vibetype_username'), 'vibetype.invoker_account_id()', 'EXECUTE'));
END $$;

ROLLBACK;
