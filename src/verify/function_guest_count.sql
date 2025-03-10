BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.guest_count(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.guest_count(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
