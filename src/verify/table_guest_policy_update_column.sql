BEGIN;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.guest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.guest', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'feedback', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'feedback_paper', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'feedback', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'feedback_paper', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'contact_id', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'event_id', 'UPDATE'));
END $$;

ROLLBACK;
