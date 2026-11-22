BEGIN;

SELECT
  account_a_id,
  account_b_id
FROM vibetype.friendship
WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'vibetype' AND tablename = 'friendship' AND policyname IN ('friendship_delete', 'friendship_insert', 'friendship_select', 'friendship_update')) = 4;
  ASSERT NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'vibetype' AND tablename = 'friendship' AND policyname = 'friendship_existing');
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.friendship', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.friendship', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.friendship', 'account_a_id', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.friendship', 'account_b_id', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.friendship', 'created_by', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.friendship', 'status', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.friendship', 'status', 'UPDATE'));
END $$;

ROLLBACK;
