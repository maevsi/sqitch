BEGIN;

SELECT id,
       channel,
       is_acknowledged,
       payload,
       created_by,
       created_at
FROM vibetype.notification WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.notification', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.notification', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.notification', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.notification', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.notification', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.notification', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.notification', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.notification', 'DELETE'));
END $$;

ROLLBACK;
