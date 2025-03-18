BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_category', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_category', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_category', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_category', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_category', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_category', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_category', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_category', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_category', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_category', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_category', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_category', 'DELETE'));
END $$;

ROLLBACK;
