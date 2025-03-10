BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`
SET local role.vibetype_username TO :'role_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('role.vibetype_username'), 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
