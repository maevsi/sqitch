BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.event', 'guest_count', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.event', 'guest_count', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.event', 'guest_count', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.event', 'name', 'UPDATE'));
END $$;

ROLLBACK;
