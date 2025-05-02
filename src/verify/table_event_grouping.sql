BEGIN;

SELECT id,
       event_group_id,
       event_id
FROM vibetype.event_grouping WHERE FALSE;


\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_grouping', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_grouping', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_grouping', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_grouping', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_grouping', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_grouping', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_grouping', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_grouping', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_grouping', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_grouping', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_grouping', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.event_grouping', 'DELETE'));
END $$;

ROLLBACK;
