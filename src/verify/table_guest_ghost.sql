BEGIN;

SELECT is_ghost FROM vibetype.guest WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'is_ghost', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'is_ghost', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.trigger_guest_is_ghost()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.trigger_guest_is_ghost()', 'EXECUTE'));
END $$;

ROLLBACK;
