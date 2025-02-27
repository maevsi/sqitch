BEGIN;

\set role_maevsi_username `cat /run/secrets/postgres_role_maevsi_username`
SET local role.maevsi_username TO :'role_maevsi_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_schema_privilege('maevsi_account', 'maevsi', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('maevsi_anonymous', 'maevsi', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege(current_setting('role.maevsi_username'), 'maevsi', 'USAGE'));
END $$;

ROLLBACK;
