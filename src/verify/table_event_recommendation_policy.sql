BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_recommendation', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_recommendation', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_recommendation', 'DELETE'));
  ASSERT NOT(SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_recommendation', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_recommendation', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_recommendation', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_recommendation', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_recommendation', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_recommendation', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_recommendation', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_recommendation', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.event_recommendation', 'DELETE'));
END $$;

ROLLBACK;
