BEGIN;

SELECT contact_group_id,
       contact_id
FROM vibetype.contact_group_member WHERE FALSE;

ROLLBACK;

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_group_member', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.contact_group_member', 'contact_group_id', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.contact_group_member', 'contact_id', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_group_member', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_group_member', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_group_member', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_group_member', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_group_member', 'DELETE'));
END $$;

ROLLBACK;
