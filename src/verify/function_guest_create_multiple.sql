BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.create_guests(UUID, UUID[])', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.create_guests(UUID, UUID[])', 'EXECUTE'));
END $$;

ROLLBACK;
