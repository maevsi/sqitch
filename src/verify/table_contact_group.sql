BEGIN;

SELECT id,
       name,
       created_at,
       created_by
FROM vibetype.contact_group WHERE FALSE;

ROLLBACK;

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_group', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_group', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.contact_group', 'name', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.contact_group', 'created_by', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.contact_group', 'id', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.contact_group', 'name', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.contact_group', 'created_by', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_group', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_group', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_group', 'DELETE'));
END $$;

ROLLBACK;
