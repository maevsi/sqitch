BEGIN;

\set role_postgraphile_username `cat /run/secrets/postgres_role_postgraphile_username`
SET local role.vibetype_postgraphile_username TO :'role_postgraphile_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('role.vibetype_postgraphile_username'), 'vibetype_account', 'USAGE'));
  -- Other postgraphiles might not exist yet for a NOT-check.
END $$;

ROLLBACK;
