BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres_role_service_postgraphile_username`
SET local role.vibetype_postgraphile_username TO :'role_service_postgraphile_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('role.vibetype_postgraphile_username'), 'vibetype_anonymous', 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
