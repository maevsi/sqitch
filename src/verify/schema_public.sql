BEGIN;

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`
SET local role.maevsi_tusd_username TO :'role_maevsi_tusd_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_schema_privilege('maevsi_account', 'maevsi', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('maevsi_anonymous', 'maevsi', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi', 'USAGE'));
END $$;

ROLLBACK;
