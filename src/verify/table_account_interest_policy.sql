BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_interest', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_interest', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_interest', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_interest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_interest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_interest', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_interest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_interest', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account_interest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account_interest', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account_interest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.account_interest', 'DELETE'));
END $$;

ROLLBACK;
