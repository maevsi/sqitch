BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.guest_create_multiple(UUID, UUID[])', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.guest_create_multiple(UUID, UUID[])', 'EXECUTE'));
END $$;

ROLLBACK;
