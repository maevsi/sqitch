BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`
SET local role.vibetype_username TO :'role_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_account', 'vibetype', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_anonymous', 'vibetype', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege(current_setting('role.vibetype_username'), 'vibetype', 'USAGE'));
END $$;

ROLLBACK;
