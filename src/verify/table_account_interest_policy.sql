BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.account_interest', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.account_interest', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.account_interest', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.account_interest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.account_interest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.account_interest', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.account_interest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.account_interest', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.account_interest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.account_interest', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.account_interest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.account_interest', 'DELETE'));
END $$;

ROLLBACK;
