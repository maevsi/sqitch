BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.friend', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.friend', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.friend', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.friend', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.friend', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.friend', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.friend', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.friend', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.friend', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.friend', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.friend', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.friend', 'DELETE'));
END $$;

ROLLBACK;
