BEGIN;

SELECT id,
       username
FROM vibetype.account WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account', 'DELETE'));
END $$;

ROLLBACK;
