BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`
SET local role.vibetype_username TO :'role_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_upload', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_upload', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_upload', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_upload', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_upload', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_upload', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_upload', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_upload', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_upload', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_upload', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_upload', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_upload', 'DELETE'));
END $$;

ROLLBACK;
