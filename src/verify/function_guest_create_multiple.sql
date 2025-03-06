BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.create_guests(UUID, UUID[])', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.create_guests(UUID, UUID[])', 'EXECUTE'));
END $$;

ROLLBACK;
