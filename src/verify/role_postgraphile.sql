BEGIN;

\set role_maevsi_postgraphile_username `cat /run/secrets/postgres_role_maevsi-postgraphile_username`
SET local role.maevsi_postgraphile_username TO :'role_maevsi_postgraphile_username';

DO $$
BEGIN
  -- -- TODO: extract assertion checks to test function
  -- ASSERT (
  --   SELECT pg_catalog.pg_has_role(current_setting('role.maevsi_postgraphile_username'), 'USAGE')
  -- ) IS TRUE,
  -- 'Role does not have USAGE on maevsi_account';
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('role.maevsi_postgraphile_username'), 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
