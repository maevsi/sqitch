BEGIN;

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`
SET local role.maevsi_tusd_username TO :'role_maevsi_tusd_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.invoker_account_id()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.invoker_account_id()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.invoker_account_id()', 'EXECUTE'));
END $$;

ROLLBACK;
