BEGIN;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.notification_acknowledge(UUID, BOOLEAN)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.notification_acknowledge(UUID, BOOLEAN)', 'EXECUTE'));
END $$;

ROLLBACK;
