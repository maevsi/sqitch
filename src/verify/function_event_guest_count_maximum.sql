BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_guest_count_maximum(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_guest_count_maximum(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
