BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.event_is_existing(UUID, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.event_is_existing(UUID, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
