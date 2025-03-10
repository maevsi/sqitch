BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`
SET local role.vibetype_username TO :'role_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.upload', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.upload', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.upload', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.upload', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.upload', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.upload', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.upload', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.upload', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.upload', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.upload', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.upload', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.upload', 'DELETE'));
END $$;

ROLLBACK;
